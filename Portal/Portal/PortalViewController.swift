import UIKit
import ARKit

class PortalViewController: UIViewController {

  @IBOutlet var sceneView: ARSCNView?
  @IBOutlet weak var messageLabel: UILabel?
  @IBOutlet weak var sessionStateLabel: UILabel?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    resetLabels()
    runSession()
  }
  
  func resetLabels() {
    messageLabel?.alpha = 1
    messageLabel?.text = "Move your phone around and allow the app tp find a plane."
    
    sessionStateLabel?.alpha = 1
    sessionStateLabel?.text = ""
  }
  
  func runSession() {
    let config = ARWorldTrackingConfiguration()
    config.planeDetection = .horizontal
    config.isLightEstimationEnabled = true
    sceneView?.session.run(config)
    
    #if DEBUG
    sceneView?.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    #endif
  }
}
