import UIKit
import ARKit

class PortalViewController: UIViewController {

  @IBOutlet var sceneView: ARSCNView?
    @IBOutlet weak var crosshair: UIView!
    @IBOutlet weak var messageLabel: UILabel?
  @IBOutlet weak var sessionStateLabel: UILabel?
  var debugPlanes: [SCNNode] = []
  var viewCenter: CGPoint {
    return CGPoint(x: view.bounds.width / 2.0 , y: view.bounds.height / 2.0)
  }
  var portalNode: SCNNode? = nil
  var isPortalPlaced = false
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    resetLabels()
    runSession()
  }
  
  // MARK: Helpers
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
    self.portalNode?.removeFromParentNode()
    self.isPortalPlaced = false
  }
  
  func removeDebugPlanes() {
    for n in self.debugPlanes {
      n.removeFromParentNode()
    }
    self.debugPlanes = []
  }
  
  func makePortal() -> SCNNode {
    let portal = SCNNode()
    let box = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0)
    let boxNode = SCNNode(geometry: box)
    portal.addChildNode(boxNode)
    return portal
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let hit = sceneView?.hitTest(viewCenter, types: [.existingPlaneUsingExtent]).first {
      sceneView?.session.add(anchor: ARAnchor(transform: hit.worldTransform)) ///
    }
  }
}

extension PortalViewController: ARSCNViewDelegate {
  
  // MARK: SceneKit Mgmnt
  /// Is called when ARSession detects new plane, and the ARSCNView automatically adds an ARPlaneAnchor for the plane, and when user taps on screen having at least one detected plane rendered
  func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    DispatchQueue.main.async {
      if let planeAnchor = anchor as? ARPlaneAnchor,
        !self.isPortalPlaced {
        #if DEBUG
        let debugPlaneNode = createPlaneNode(center: planeAnchor.center, extent: planeAnchor.extent)
        node.addChildNode(debugPlaneNode)
        self.debugPlanes.append(debugPlaneNode)
        #endif
        self.messageLabel?.alpha = 1.0
        self.messageLabel?.text = "Tap on the detected horizontal plane to place te portal"
      }
      else if !self.isPortalPlaced {
        self.portalNode = self.makePortal()
        if let portal = self.portalNode {
          //place node at the location
          node.addChildNode(portal)
          self.isPortalPlaced = true
          
          //reset debug planes
          self.removeDebugPlanes()
          self.sceneView?.debugOptions = []
          
          //Update messageLabel
          DispatchQueue.main.async {
            self.messageLabel?.text = ""
            self.messageLabel?.alpha = 0
          }
        }
      }
    }
  }
  
  
  func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
    DispatchQueue.main.async {
      if let planeAnchor = anchor as? ARPlaneAnchor,
      node.childNodes.count > 0,
        !self.isPortalPlaced {
        updatePlaneNode(node.childNodes[0],
                        center: planeAnchor.center,
                        extent: planeAnchor.extent)
      }
    }
  }
  func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
    DispatchQueue.main.async {
      if let _ = self.sceneView?.hitTest(self.viewCenter, types: [.existingPlaneUsingExtent]).first {
        self.crosshair.backgroundColor = UIColor.green
        }
      else {
        self.crosshair.backgroundColor = UIColor.lightGray
      }
    }
  }
  
  // MARK: ARKit Session Mgmnt
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

