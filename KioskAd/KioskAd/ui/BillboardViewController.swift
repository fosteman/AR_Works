import UIKit
import SceneKit
import ARKit

private enum Section: Int {
  case images = 1
  case video = 0
  case webBrowser = 2
}

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
