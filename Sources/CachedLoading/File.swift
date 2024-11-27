import Foundation
import SwiftUI

#if canImport(UIKit)
import UIKit

// Custom UICollectionViewCell
@available(iOS, introduced: 15.0, deprecated: 16.0, message: "Use SwiftUI hosting configuration instead")
public class SwiftUICollectionViewCell<V: View, Data: Hashable & Sendable>: UICollectionViewCell {
  public var content: ((Data) -> V)?

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  private var hostingController: UIHostingController<V>?
  
  public func configure(with data: Data) {
    guard let content else {
      fatalError("Should have content configured")
    }
    // If the hostingController already exists, update it
    if let hostingController = hostingController {
      hostingController.rootView = content(data)
    } else {
      // Create a new hostingController and embed it
      let swiftUIView = content(data)
      let hostingController = UIHostingController(rootView: swiftUIView)
      self.hostingController = hostingController
      
      guard let hostView = hostingController.view else { return }
      hostView.translatesAutoresizingMaskIntoConstraints = false
      contentView.addSubview(hostView)
      
      // Constrain the SwiftUI view to the cell's content view
      NSLayoutConstraint.activate([
        hostView.topAnchor.constraint(equalTo: contentView.topAnchor),
        hostView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
        hostView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        hostView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
      ])
    }
  }
}
#endif
