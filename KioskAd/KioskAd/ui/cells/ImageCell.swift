import UIKit

class ImageCell: UICollectionViewCell {
  @IBOutlet weak var imageView: UIImageView!

  func show(image: UIImage) {
    imageView.image = image
  }
}
