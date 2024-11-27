//
//  ContentView.swift
//  CachedLoading
//
//  Created by Stijn Willems on 27/11/2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

protocol LoadedContent: View {
  associatedtype V: Hashable
  init(value: V)

  static func load() -> V
}

public enum LoadingState<V: Hashable & Sendable>: Equatable, Sendable {
  case loading
  case loaded(V)
  case error(LoadingError)
}

public struct LoadingError: Swift.Error, Hashable, Sendable {
  public let error: Swift.Error
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(error.localizedDescription)
  }
  
  public static func == (lhs: LoadingError, rhs: LoadingError) -> Bool {
    lhs.error.localizedDescription == rhs.error.localizedDescription
  }
}

struct ExampleView {
  struct Data: Hashable {
    let id: String
  }
  
  @State var data: Data?
}

struct LoadingView<V: Hashable & Sendable, Content: View>: View {
  @State var loadingState: LoadingState<V>
  
  var content: (V) -> Content
  var loader: () async throws -> V
  
  init(
    loadingState: LoadingState<V>,
    loader: @escaping () async throws -> V,
    content:  @escaping (V) -> Content) {
      _loadingState = .init(initialValue: loadingState)
      self.content = content
      self.loader = loader
    }
  
  var body: some View {
    Group {
      switch loadingState {
      case .loading:
        Text("Loading")
      case .loaded(let v):
        content(v)
      case .error(let loadingError):
        Text("Error \(loadingError)")
      }
    }.task {
      do {
        loadingState = .loaded(try await loader())
      } catch {
        loadingState = .error(.init(error: error))
      }
    }
  }
}

#Preview {
    ContentView()
}
