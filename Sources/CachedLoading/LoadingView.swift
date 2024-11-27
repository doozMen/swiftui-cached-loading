import SwiftUI

public struct LoadingView<V: Hashable & Sendable, Content: View>: View {
  @Binding public var loadingState: LoadingState<V>
  
  var content: (V) -> Content
  var loader: () async throws -> V
  
  @State var currentTask: Task<Void, Never>?
  
  public init(
    loadingState: Binding<LoadingState<V>>,
    loader: @escaping () async throws -> V,
    content: @escaping (V) -> Content
  ) {
    _loadingState = loadingState
    self.content = content
    self.loader = loader
  }
  
  public var body: some View {
    Group {
      switch loadingState {
      case .cancelled:
        Text("Cancelled")
      case .loading:
        Text("Loading")
      case .loaded(let value):
        content(value)
      case .error(let loadingError):
        Text("Error: \(loadingError.error.localizedDescription)")
      }
    }.task {
      if !loadingState.isLoaded {
        await startLoading()
      } else {
        print("Starting from cache")
      }
    }
    .onDisappear() {
      cancelCurrentTask()
    }
    .onChange(of: loadingState) { newValue in
      print("loadingState changed to: \(newValue)")
      if newValue == .cancelled {
        cancelCurrentTask()
      }
      currentTask = Task {
        switch newValue {
        case .cancelled:
          await startLoading()
        case .loaded, .error, .loading:
          return
        }
      }
      
    }
  }
  
  private func startLoading() async {
    guard loadingState != .loading || currentTask == nil else { return }
    
    loadingState = .loading
    do {
      try Task.checkCancellation()
      let value = try await loader()
      try Task.checkCancellation()
      await MainActor.run {
        loadingState = .loaded(value)
      }
    } catch is CancellationError {
      await MainActor.run {
        loadingState = .cancelled
      }
     } catch {
      await MainActor.run {
        loadingState = .error(LoadingError(error: error))
      }
    }
  }
  
  private func cancelCurrentTask() {
    currentTask?.cancel()
    currentTask = nil
  }
}

public enum LoadingState<V: Hashable & Sendable>: Equatable, Sendable {
  case loading, cancelled
  case loaded(V)
  case error(LoadingError)
  
  var isLoaded: Bool {
    switch self {
    case .loaded: return true
    default: return false
    }
  }
}

public struct LoadingError: Swift.Error, Hashable, Sendable {
  public let error: Swift.Error
  
  public init(error: Error) {
    self.error = error
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(error.localizedDescription)
  }
  
  public static func == (lhs: LoadingError, rhs: LoadingError) -> Bool {
    lhs.error.localizedDescription == rhs.error.localizedDescription
  }
}

public func loader() async throws -> Int {
  try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
  return 169
}

@available(iOS 18.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
#Preview {
  @Previewable @State var loadingState: LoadingState<Int> = .cancelled
  
  VStack {
    Button("Cancel") {
      loadingState = .cancelled
    }
    .padding()
    
    LoadingView(
      loadingState: $loadingState,
      loader: loader
    ) { value in
      Text("Loaded value: \(value)")
    }
  }
  .padding()
}
