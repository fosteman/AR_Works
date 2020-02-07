import UIKit
import ARKit

class PortalViewController: UIViewController {

  @IBOutlet var sceneView: ARSCNView?
  @IBOutlet weak var messageLabel: UILabel?
  @IBOutlet weak var sessionStateLabel: UILabel?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    resetLabels()
  }
  
  func resetLabels() {
    messageLabel?.alpha = 0
    sessionStateLabel?.alpha = 0
  }
}
