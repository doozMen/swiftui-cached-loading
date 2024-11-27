//
//  ContentView.swift
//  CachedLoading
//
//  Created by Stijn Willems on 27/11/2024.
//

import SwiftUI
import CachedLoading

struct CollectionViewWrapper: UIViewControllerRepresentable {
  func makeUIViewController(context: Context) -> CollectionViewController {
        return CollectionViewController()
    }
    
    func updateUIViewController(_ uiViewController: CollectionViewController, context: Context) {
        // Handle updates if needed
    }
}

struct ContentView: View {
  @State var loadingState: LoadingState<Int> = .loading
  var body: some View {
    VStack {
      Button {
        loadingState = .cancelled
      } label: {
        Text("Cancel")
      }
      .padding()
      
      LoadingView(loadingState: $loadingState, loader: loader) { value in
        Text("\(value)")
      }
    }
  }
}

#Preview {
    ContentView()
}
