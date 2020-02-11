import UIKit
import SceneKit
import ARKit

private enum Section: Int {
  case images = 1
  case video = 0
  case webBrowser = 2
}

//Cell identifier
private enum Cell: String {
  case cellWebBrowser
  case cellVideo
  case cellImage
}

class BillboardViewController: UICollectionViewController {
    var billboard: BillboardContainer?
    var sceneView: ARSCNView?
}

extension BillboardViewController : UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return collectionView.bounds.size
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return .zero
  }
}

//MARK: Data-Source
extension BillboardViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
        // each type is a separate section
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      guard let currentSection = Section(rawValue: section) else { return 0 }

      switch currentSection {
      case .images:
        return billboard?.billboardData.images.count ?? 0
      case .video:
        return 1
      case .webBrowser:
        return 1
        }
    }
    
    //Each cell type is handeled as separate section (useful in case of sequences of images)
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let currentSection = Section(rawValue: indexPath.section) else {fatalError("Unexpected collection view section")}
        
        let cellType: Cell
        switch currentSection {
        case .images:
            cellType = .cellImage
        case .video:
            cellType = .cellVideo
        case .webBrowser:
            return 1
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellType.rawValue, for: indexPath)
        // Funky switch between the types
        switch cell {
        case let imageCell as ImageCell:
            let image = UIImage(named: billboard!.billboardData.images[indexPath.item])!
            imageCell.show(image: image)
            
        case let videoCell as VideoCell:
            let videoUrl = billboard!.billboardData.videoUrl
            if let sceneView = sceneView,
                let billboard = billboard {
                videoCell.configure(videoUrl: videoUrl, sceneView: sceneView, billboard: billboard)
            }
            break
        default:
            fatalError("unrecognized cell")
        }
        
        return cell
    }
}
