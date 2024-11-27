import Foundation
import SwiftUI

#if canImport(UIKit)
import UIKit

// Custom UICollectionViewCell
@available(iOS, introduced: 15.0, deprecated: 16.0, message: "Use SwiftUI hosting configuration instead")
public class SportUICollectionViewCell: UICollectionViewCell {

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  private var hostingController: UIHostingController<SportView>?
  
  public func configure(view: SportView) {
    
    // If the hostingController already exists, update it
    if let hostingController = hostingController {
      hostingController.rootView = view
    } else {
      // Create a new hostingController and embed it
      let swiftUIView = view
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

@available(iOS, introduced: 15.0, deprecated: 16.0, message: "Use SwiftUI hosting configuration instead")
public class NumberUICollectionViewCell: UICollectionViewCell {

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  private var hostingController: UIHostingController<TextView>?
  
  public func configure(text: String) {

    // If the hostingController already exists, update it
    if let hostingController = hostingController {
      hostingController.rootView = TextView(text: text)
    } else {
      // Create a new hostingController and embed it
      let swiftUIView = TextView(text: text)
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

struct TextView: View {
  let text: String
  var body: some View {
    Text("\(text)")
      .frame(width: UIScreen.main.bounds.width)
  }
}
#endif
