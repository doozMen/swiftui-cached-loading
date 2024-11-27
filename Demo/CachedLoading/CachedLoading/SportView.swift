import Foundation
import SwiftUI
import CachedLoading
import Files

let cacheFolder = try! Folder.home.createSubfolderIfNeeded(at: "Cache")
let cacheFileName = "content.json"

struct SportView: View {
  @State var loadingState: LoadingState<String>
  
  init() {
    if cacheFolder.containsFile(named: cacheFileName) {
      _loadingState = .init(initialValue: .loaded("SportView"))
    } else {
      _loadingState = .init(initialValue: .cancelled)
    }
  }
  
  var body: some View {
    Group {
      LoadingView(loadingState: $loadingState, loader: loader) { text in
        Text("\(text)")
      }
    }
    .frame(width: UIScreen.main.bounds.width, height: 150)
  }
}

func loader() async throws -> String {
  try Task.checkCancellation()
  try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
  try Task.checkCancellation()
  let cacheFolder = try cacheFolder
    .createFileIfNeeded(
      withName: cacheFileName,
                        
      contents: """
      {
        "response": { "success": true}
      }
      """.data(using: .utf8)!)

  return "New loaded content for sport"
}
