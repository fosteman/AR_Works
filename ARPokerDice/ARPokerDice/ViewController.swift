  
import UIKit
import SceneKit
import ARKit

// MARK: - Game State
enum GameState: Int16 {
  case detectSurface
  case pointToSurface
  case swipeToPlay
  }
  
  
class ViewController: UIViewController {
  
  // MARK: - Properties
  var trackingStatus: String = ""
  var focusNode: SCNNode!
  var diceNodes: [SCNNode] = []
  var diceCount: Int = 5
  var diceStyle: Int = 0
  var diceOffset: [SCNVector3] = [SCNVector3(0.0,0.0,0.0),
                                  SCNVector3(-0.15, 0.00, 0.0),
                                  SCNVector3(0.15, 0.00, 0.0),
                                  SCNVector3(-0.15, 0.15, 0.12),
                                  SCNVector3(0.15, 0.15, 0.12)]
  var gameState: GameState = .detectSurface
  var statusMessage: String = ""
  var focusPoint: CGPoint!
  
  // MARK: - Outlets
  
  @IBOutlet var sceneView: ARSCNView!
  @IBOutlet weak var statusLabel: UILabel!
  @IBOutlet weak var styleButton: UIButton!
  @IBOutlet weak var resetButton: UIButton!
  
  // MARK: - Actions
  
  @IBAction func styleButtonPressed(_ sender: Any) {
    diceStyle = diceStyle >= 4 ? 0 : diceStyle + 1
  }
  
  @IBAction func resetButtonPressed(_ sender: Any) {
  }
  
  @IBAction func swipeUpGestureHandler(_ sender: Any) {
    // 1
    guard let frame = self.sceneView.session.currentFrame else { return }
    // 2
    for count in 0..<diceCount {
      throwDiceNode(transform: SCNMatrix4(frame.camera.transform),
                    offset: diceOffset[count])
    }
  }
  
  // MARK: - View Management
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.initSceneView()
    self.initScene()
    self.initARSession()
    self.loadModels()
    self.initCoachingOverlayView()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    print("*** ViewWillAppear()")
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    print("*** ViewWillDisappear()")
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    print("*** DidReceiveMemoryWarning()")
  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  @objc func orientationChanged() {
    focusPoint = CGPoint(x: view.center.x, y: view.center.y * 0.25)
  }
  
  
  // MARK: - Initialization
  
  func initSceneView() {
    sceneView.delegate = self
    sceneView.showsStatistics = true
    sceneView.debugOptions = [
      //ARSCNDebugOptions.showFeaturePoints,
      //ARSCNDebugOptions.showWorldOrigin,
      //SCNDebugOptions.showBoundingBoxes,
      //SCNDebugOptions.showWireframe
    ]
    
    focusPoint = CGPoint(x: view.center.x, y: view.center.y + view.center.y)
    NotificationCenter.default.addObserver(self, selector: #selector(ViewController.orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
    
  }
  
  func initScene() {
    let scene = SCNScene()
    scene.isPaused = false
    scene.physicsWorld.speed = 1 / 60.0 // physics simulation update
    sceneView.scene = scene
    //scene.lightingEnvironment.contents = "PokerDice.scnassets/Textures/Environment_CUBE.jpg"
    //scene.lightingEnvironment.intensity = 2
    
  }
  
  func initARSession() {
    guard ARWorldTrackingConfiguration.isSupported else {
      print("*** ARConfig: AR World Tracking Not Supported")
      return
    }
    
    let config = ARWorldTrackingConfiguration()
    config.worldAlignment = .gravity
    config.providesAudioData = false
    config.environmentTexturing = .automatic
    config.planeDetection = .horizontal
    sceneView.session.run(config)
    
    
  }
  
  func initCoachingOverlayView() {
    let coachingOverlay = ARCoachingOverlayView()
    
    coachingOverlay.session = self.sceneView.session
    coachingOverlay.activatesAutomatically = true
    coachingOverlay.goal = .horizontalPlane
    coachingOverlay.delegate = self
    self.sceneView.addSubview(coachingOverlay)
    
    coachingOverlay.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      NSLayoutConstraint(item: coachingOverlay, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: coachingOverlay, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: coachingOverlay, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: coachingOverlay, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0),
      
    ])
  }
  
  // MARK: - Load Models
  
  func loadModels() {
    // 1
    let diceScene = SCNScene(
      named: "PokerDice.scnassets/Models/DiceScene.scn")!
    // 2
    for count in 0..<5 {
      // 3
      diceNodes.append(diceScene.rootNode.childNode(
        withName: "dice\(count)",
        recursively: false)!)
    }
    
    let focusScene = SCNScene(named: "PokerDice.scnassets/Models/FocusScene.scn")!
    focusNode = focusScene.rootNode.childNode( withName: "focus", recursively: false)!
    sceneView.scene.rootNode.addChildNode(focusNode)
  }
  
  // MARK: - Helper Functions
  
  func throwDiceNode(transform: SCNMatrix4, offset: SCNVector3) {
    // 1
    let position = SCNVector3(transform.m41 + offset.x,
                              transform.m42 + offset.y,
                              transform.m43 + offset.z)
    // 2
    let diceNode = diceNodes[diceStyle].clone()
    diceNode.name = "dice"
    diceNode.position = position
    //3
    sceneView.scene.rootNode.addChildNode(diceNode)
    //diceCount -= 1
  }
  
  func createPlaneNode(_ anchor: ARPlaneAnchor, color: UIColor) -> SCNNode {
    let planeGeometry = SCNPlane(
    width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
    
    let planeMaterial = SCNMaterial()
    planeMaterial.diffuse.contents = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.8470588235)
    planeGeometry.materials = [planeMaterial]
    
    let planeNode = SCNNode(geometry: planeGeometry)
    
    planeNode.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
    planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0) // pitch horizontally
    
    return planeNode
    
  }
  func updatePlaneNode(_ node: SCNNode, planeAnchor: ARPlaneAnchor) {
    let planeGeometry = node.geometry as! SCNPlane
    planeGeometry.width = CGFloat(planeAnchor.extent.x)
    planeGeometry.height = CGFloat(planeAnchor.extent.z)
    node.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z)
  }
  
  func updateFocusNode() {
    
  // Ray cast test.
    let results = self.sceneView.hitTest(self.focusPoint, types: [.existingPlaneUsingExtent])
    
    if results.count == 1 {
      if let match = results.first {
        let t = match.worldTransform
        
        self.focusNode.position = SCNVector3(x: t.columns.3.x, y: t.columns.3.y, z: t.columns.3.z)
        self.gameState = .swipeToPlay
        focusNode.isHidden = false
      }
    }
    else {
      self.gameState = .pointToSurface
      focusNode.isHidden = true
    }
  }
  
  func removePlaneNode(node: SCNNode) {
    for childNode in node.childNodes {
      childNode.removeFromParentNode()
    }
  }
  
    
  
}

extension ViewController : ARSCNViewDelegate {
  
  // MARK: - SceneKit Management
  
  func renderer(_ renderer: SCNSceneRenderer,
                updateAtTime time: TimeInterval) {
    DispatchQueue.main.async {
      self.updateStatus()
      self.updateFocusNode()
    }
  }
  
  func updateStatus() {
    switch gameState {
      case .detectSurface:
      statusMessage = "Scan entire table surface..."
      case .pointToSurface:
      statusMessage = "Point at a designated surface first!"
      case .swipeToPlay:
      statusMessage = "Swipe Up to throw!\nTap die to collect."
    }
    
    self.statusLabel.text = trackingStatus != "" ? "\(trackingStatus)" : "\(statusMessage)"
  }
  
  
  // MARK: - Session State Management
  
  func session(_ session: ARSession,
               cameraDidChangeTrackingState camera: ARCamera) {
    switch camera.trackingState {
    // 1
    case .notAvailable:
      self.trackingStatus = "Tacking:  Not available!"
      break
    // 2
    case .normal:
      self.trackingStatus = ""
      break
    // 3
    case .limited(let reason):
      switch reason {
      case .excessiveMotion:
        self.trackingStatus = "Tracking: Limited due to excessive motion!"
        break
      // 3.1
      case .insufficientFeatures:
        self.trackingStatus = "Tracking: Limited due to insufficient features!"
        break
      // 3.2
      case .initializing:
        self.trackingStatus = "Tracking: Initializing..."
        break
      case .relocalizing:
        self.trackingStatus = "Tracking: Relocalizing..."
      @unknown default:
        self.trackingStatus = "Tracking: Unknown..."
      }
    }
  }
  
  // MARK: - Session Error Managent
  
  func session(_ session: ARSession,
               didFailWithError error: Error) {
    self.trackingStatus = "AR Session Failure: \(error)"
  }
  
  func sessionWasInterrupted(_ session: ARSession) {
    self.trackingStatus = "AR Session Was Interrupted!"
  }
  
  func sessionInterruptionEnded(_ session: ARSession) {
    self.trackingStatus = "AR Session Interruption Ended"
  }
  
  // MARK: - Plane Management
  func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
    
    DispatchQueue.main.async {
      let planeNode = self.createPlaneNode(planeAnchor, color: UIColor.yellow.withAlphaComponent(0.4))
      
      node.addChildNode(planeNode)
    }
  }
  
  func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
    guard let anchor = anchor as? ARPlaneAnchor else {return}
    
    DispatchQueue.main.async {
      self.updatePlaneNode(node.childNodes[0], planeAnchor: anchor)
    }
  }
  
  func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
    guard let anchor = anchor as? ARPlaneAnchor else {return}
    
    DispatchQueue.main.async {
      self.removePlaneNode(node)
    }
  }
}

extension ViewController: ARCoachingOverlayViewDelegate {
  // MARK: - AR Coaching Overlay View
  
  func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) {
    
  }
  func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
    
  }
  func coachingOverlayViewDidRequestSessionReset(_ coachingOverlayView: ARCoachingOverlayView) {
    
  }
}
