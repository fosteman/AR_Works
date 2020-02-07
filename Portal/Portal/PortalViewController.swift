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
    sceneView?.delegate = self
    
    #if DEBUG
    sceneView?.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    #endif
  }
}

extension PortalViewController: ARSCNViewDelegate {
  
  /// Is called when ARSession detects new plane, and the ARSCNView automatically adds an ARPlaneAnchor for the plane
  func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    DispatchQueue.main.async {
      if let planeAnchor = anchor as? ARPlaneAnchor {
        #if DEBUG
        let debugPlaneNode = createPlaneNode(center: planeAnchor.center, extent: planeAnchor.extent)
        node.addChildNode(debugPlaneNode)
        #endif
        self.messageLabel?.text = "Tap on the detected horizontal plane to place te portal"
      }
    }
  }
  
  func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
    DispatchQueue.main.async {
      if let planeAnchor = anchor as? ARPlaneAnchor,
      node.childNodes.count > 0 {
        updatePlaneNode(node.childNodes[0],
                        center: planeAnchor.center,
                        extent: planeAnchor.extent)
      }
    }
    
    
  }
}
