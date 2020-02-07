import UIKit
import ARKit

class PortalViewController: UIViewController {

  @IBOutlet var sceneView: ARSCNView?
  @IBOutlet weak var messageLabel: UILabel?
  @IBOutlet weak var sessionStateLabel: UILabel?
  var debugPlanes: [SCNNode] = []
  
  
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
  
  func showMessage(_ message: String, label: UILabel, seconds: Double) {
    label.text = message
    label.alpha = 1
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
      if label.text == message {
        label.text = ""
        label.alpha = 0
      }
    }
  }
  
  func removeAllNodes() {
    removeDebugPlanes()
  }
  
  func removeDebugPlanes() {
    for n in self.debugPlanes {
      n.removeFromParentNode()
    }
    self.debugPlanes = []
  }
  
  func runSession() {
    let config = ARWorldTrackingConfiguration()
    config.planeDetection = .horizontal
    config.isLightEstimationEnabled = true
    sceneView?.session.run(config, options: [.resetTracking,
    .removeExistingAnchors]) ///session does not continue device position and motion tracking from previous configuration. And any objects associated with the session in its previius configuration are removed
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
        self.debugPlanes.append(debugPlaneNode)
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
  
  func sessionWasInterrupted(_ session: ARSession) {
    guard let label = self.sessionStateLabel else {return}
    
    showMessage("Session interrupted", label: label, seconds: 3)
  }
  
  func sessionInterruptionEnded(_ session: ARSession) {
    guard let label = self.sessionStateLabel else {return}
    
    showMessage("Session resumed!", label: label, seconds: 3)
    
    DispatchQueue.main.async {
      self.removeAllNodes()
      self.resetLabels()
    }
    
    runSession()
  }
  
  func session(_ session: ARSession, didFailWithError error: Error) {
    guard let label = self.sessionStateLabel else {return}
    showMessage(error.localizedDescription, label: label, seconds: 3)
  }
}
