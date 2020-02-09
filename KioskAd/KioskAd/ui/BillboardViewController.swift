import UIKit

class BillboardViewController: UIViewController {
  private var _view: BillboardView { return view as! BillboardView }
  
  var delegate: BillboardViewDelegate? {
    get { return _view.delegate }
    set { _view.delegate = newValue}
  }
  
  var images: [UIImage] {
    get { return _view.images }
    set { _view.images = newValue }
  }
}

