import Foundation
import SwiftUI
import CachedLoading
import Files

let cacheFolder = try! Folder.home.createSubfolderIfNeeded(at: "Cache")
let cacheFileName = "content.json"

struct SportView: View {
  @State var loadingState: LoadingState<SportData>
  var dataLoaded: ((SportData) -> Void)?
  
  init(sporData: SportData? = nil) {
    if let sporData {
      _loadingState = .init(initialValue: .loaded(sporData))
    } else {      
      do {
        // To heavy on init?
        if cacheFolder.containsFile(named: cacheFileName) {
          let data = try JSONDecoder().decode(SportData.self, from: cacheFolder.file(named: cacheFileName).read())
          _loadingState = .init(initialValue: .loaded(data))
        } else {
          _loadingState = .init(initialValue: .cancelled)
        }
      } catch {
        _loadingState = .init(initialValue: .error(.init(error: error)))
      }
    }
  }
  
  var body: some View {
    Group {
      LoadingView(loadingState: $loadingState, loader: loader) { text in
        Text("\(text)")
      }
    }
    .frame(width: UIScreen.main.bounds.width, height: 150)
    .onChange(of: loadingState) { newValue in
      if case .loaded(let data) = newValue {
        dataLoaded?(data)
      }
    }
  }
}

public struct SportData: Codable, Hashable, Sendable {
  let response: [String : Bool]
}

func loader() async throws -> SportData {
  try Task.checkCancellation()
  try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
  try Task.checkCancellation()
  let cache = try cacheFolder
    .createFileIfNeeded(
      withName: cacheFileName,
                        
      contents: """
      {
        "response": { "success": true}
      }
      """.data(using: .utf8)!)

  return try JSONDecoder().decode(SportData.self, from: try cache.read())
}
