import Foundation
import SwiftUI
import CachedLoading
import Files


public struct SportView: View {
  @State var loadingState: LoadingState<SportData>
  public let loader: Loader
  
  public init(loader: Loader, sportData: SportData? = nil) {
    self.loader = loader
    
    if let sportData {
      _loadingState = .init(initialValue: .loaded(sportData))
    } else {
      print(cacheFolder.path)
      do {
        // To heavy on init?
        if let cacheFile = cacheFile(endoint: loader.endpoint) {
          let data = try JSONDecoder().decode(SportData.self, from: cacheFile.read())
          _loadingState = .init(initialValue: .loaded(data))
        } else {
          _loadingState = .init(initialValue: .cancelled)
        }
      } catch {
        let cacheFile = cacheFile(endoint: loader.endpoint)
        print("\((try? cacheFile?.readAsString()) ?? "No cache file found")")
        try? cacheFile?.delete()
        _loadingState = .init(initialValue: .error(.init(error: error)))
      }
    }
  }
  
  public var body: some View {
    Group {
      LoadingView(loadingState: $loadingState, loader: loader.load) { sportData in
        Text("\(prettyPrint(sportData: sportData))")
      }
    }
    .frame(width: UIScreen.main.bounds.width, height: 150)
    .onChange(of: loadingState) { newValue in
      print("on change \(newValue)")
    }
  }
  
  func prettyPrint(sportData: SportData) -> String {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    
    let data = try! encoder.encode(sportData)
    return String(data: data, encoding: .utf8) ?? "unknown"
  }
}

// MARK: - Data

public struct SportData: Codable, Hashable, Sendable {
  let endpoint: String
  let response: [String : Bool]
}

public struct Loader {
  let endpoint: String
  
  public init(endpoint: String) {
    self.endpoint = endpoint
  }
  func load() async throws -> SportData {
    try Task.checkCancellation()
    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
    try Task.checkCancellation()
    let content = """
        {
          "endpoint": "\(endpoint)",
          "response": { "success": true}
        }
        """.data(using: .utf8)!
    let cache = createCacheFile(endoint: endpoint)
    try cache.write(content)

    return try JSONDecoder().decode(SportData.self, from: try cache.read())
  }
}

// MARK: - Folders

let cacheFolder: Folder =  {
  do {
    let url = try FileManager.default.url(for: .cachesDirectory,
                                          in: .userDomainMask,
                                          appropriateFor: nil,
                                          create: false)
    return try Folder(url: url)
  } catch {
    fatalError("\(error)")
  }
  
}()

func cacheFile(endoint: String) -> File?  {
  try? cacheFolder.file(named: "content \(endoint).json")
}

func createCacheFile(endoint: String) -> File  {
  try! cacheFolder.createFileIfNeeded(withName: "content \(endoint).json")
}
