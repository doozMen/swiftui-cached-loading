import SwiftUI

#if canImport(UIKit)
import UIKit

private let numberIdentifier = "number cell"
private let genericIdentifier = "number cell"
private let sportIdentifier = "sport cell"

public final class CollectionViewController: UICollectionViewController {
  
  let items = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]
  private var sportData: SportData?
  
  public init()
  {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: 44) // Standard table row height
    
    super.init(collectionViewLayout: layout)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Register cell classes
    if #available(iOS 16.0, *) {
      self.collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: genericIdentifier)
    } else {
      self.collectionView?.register(SportUICollectionViewCell.self, forCellWithReuseIdentifier: sportIdentifier)
      self.collectionView?.register(NumberUICollectionViewCell.self, forCellWithReuseIdentifier: numberIdentifier)
    }
    
    // Do any additional setup after loading the view.
  }
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using [segue destinationViewController].
   // Pass the selected object to the new view controller.
   }
   */
  
  // MARK: UICollectionViewDataSource
  
  public override func numberOfSections(in collectionView: UICollectionView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 1
  }
  
  
  public override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of items
    return items.count
  }
  
  public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    // Configure the cell
    if #available(iOS 16.0, *) {
      if indexPath.row == 9 {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: genericIdentifier, for: indexPath)
        var sportView = SportView(sporData: sportData)
        sportView.dataLoaded = { [weak self] in
          self?.sportData = $0
        }
        cell.contentConfiguration = UIHostingConfiguration {
          sportView
        }
        return cell
      } else {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: genericIdentifier, for: indexPath)
        cell.contentConfiguration = UIHostingConfiguration {
          Text("\(indexPath.row)")
            .frame(width: UIScreen.main.bounds.width)
        }
        return cell
      }
      
    } else {
      if indexPath.row == 9 {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: sportIdentifier, for: indexPath) as! SportUICollectionViewCell
        cell.configure()
        return cell
      } else {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: numberIdentifier, for: indexPath) as! NumberUICollectionViewCell
        cell.configure(text: "\(indexPath.row)")
        return cell
      }
      
    }
    
  }
  
  // MARK: UICollectionViewDelegate
  
  /*
   // Uncomment this method to specify if the specified item should be highlighted during tracking
   override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
   return true
   }
   */
  
  /*
   // Uncomment this method to specify if the specified item should be selected
   override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
   return true
   }
   */
  
  /*
   // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
   override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
   return false
   }
   
   override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
   return false
   }
   
   override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
   
   }
   */
  
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, visionOS 1.0, watchOS 10.0, *)
#Preview {
  CollectionViewController()
}
#endif
