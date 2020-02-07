
  import UIKit
  import SceneKit
  import ARKit

  // MARK: - Game State

  enum GameState: Int16 {
    case detectSurface  // Scan playable surface (Plane Detection On)
    case pointToSurface // Point to surface to see focus point (Plane Detection Off)
    case swipeToPlay    // Focus point visible on surface, swipe up to play
  }

  class ViewController: UIViewController {
    
    // MARK: - Properties
    var trackingStatus: String = ""
    var statusMessage: String = ""
    var gameState: GameState = .detectSurface
    var focusPoint:CGPoint!
    var focusNode: SCNNode!
    var diceNodes: [SCNNode] = []
    var lightNode: SCNNode!
    var diceCount: Int = 5
    var diceStyle: Int = 0
    var diceOffset: [SCNVector3] = [SCNVector3(0.0,0.0,0.0),
                                    SCNVector3(-0.15, 0.00, 0.0),
                                    SCNVector3(0.15, 0.00, 0.0),
                                    SCNVector3(-0.15, 0.15, 0.12),
                                    SCNVector3(0.15, 0.15, 0.12)]
      
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
      self.resetGame()
    }
    
    @IBAction func swipeUpGestureHandler(_ sender: Any) {
      guard gameState == .swipeToPlay else { return }
      guard let frame = self.sceneView.session.currentFrame else { return }
      for count in 0..<diceCount {
        throwDiceNode(transform: SCNMatrix4(frame.camera.transform),
                      offset: diceOffset[count])
      }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      DispatchQueue.main.async {
        if let touchLocation = touches.first?.location(in: self.sceneView) {
          if let hit = self.sceneView.hitTest(touchLocation, options: nil).first {
            if hit.node.name == "dice" {
              hit.node.removeFromParentNode()
              self.diceCount += 1
            }
          }
        }
      }
    }
    
    // MARK: - View Management
    
    override func viewDidLoad() {
      super.viewDidLoad()
      self.initSceneView()
      self.initCoachingOverlayView()
      self.initScene()
      self.initARSession()
      self.loadModels()
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
    
    @objc
    func orientationChanged() {
      focusPoint = CGPoint(x: view.center.x, y: view.center.y + view.center.y * 0.25)
    }
    
    // MARK: - Initialization
    
    func initSceneView() {
      sceneView.delegate = self
      //sceneView.showsStatistics = true
      sceneView.debugOptions = [
        //ARSCNDebugOptions.showFeaturePoints,
        //ARSCNDebugOptions.showWorldOrigin,
        //SCNDebugOptions.showBoundingBoxes,
        //SCNDebugOptions.showWireframe
      ]
      
      focusPoint = CGPoint(x: view.center.x, y: view.center.y + view.center.y * 0.25)
      NotificationCenter.default.addObserver(self, selector: #selector(ViewController.orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    func initScene() {
      let scene = SCNScene()
      sceneView.scene = scene
      //scene.lightingEnvironment.contents = "PokerDice.scnassets/Textures/Environment_CUBE.jpg"
      //scene.lightingEnvironment.intensity = 2
      scene.physicsWorld.speed = 1
      scene.physicsWorld.timeStep = 1.0 / 60.0
    }
    
    func initARSession() {
      guard ARWorldTrackingConfiguration.isSupported else {
        print("*** ARConfig: AR World Tracking Not Supported")
        return
      }
      
      let config = ARWorldTrackingConfiguration()
      config.worldAlignment = .gravity
      config.providesAudioData = false
      config.planeDetection = .horizontal
      config.isLightEstimationEnabled = true
      config.environmentTexturing = .automatic
      sceneView.session.run(config)
    }
      
    func initCoachingOverlayView() {
      let coachingOverlay = ARCoachingOverlayView()
      coachingOverlay.session = self.sceneView.session
      coachingOverlay.delegate = self
      coachingOverlay.translatesAutoresizingMaskIntoConstraints = false
      coachingOverlay.activatesAutomatically = true
      coachingOverlay.goal = .horizontalPlane
      self.sceneView.addSubview(coachingOverlay)
      
      NSLayoutConstraint.activate([
        NSLayoutConstraint(item:  coachingOverlay, attribute: .top, relatedBy: .equal,
          toItem: self.view, attribute: .top, multiplier: 1, constant: 0),
        NSLayoutConstraint(item:  coachingOverlay, attribute: .bottom, relatedBy: .equal,
          toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0),
        NSLayoutConstraint(item:  coachingOverlay, attribute: .leading, relatedBy: .equal,
          toItem: self.view, attribute: .leading, multiplier: 1, constant: 0),
        NSLayoutConstraint(item:  coachingOverlay, attribute: .trailing, relatedBy: .equal,
          toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0)
      ])
    }
    
    // MARK: - Load Models
    
    func loadModels() {
      let diceScene = SCNScene(
        named: "PokerDice.scnassets/Models/DiceScene.scn")!
      for count in 0..<5 {
        diceNodes.append(diceScene.rootNode.childNode(
          withName: "dice\(count)",
          recursively: false)!)
      }
      
      let focusScene = SCNScene(
        named: "PokerDice.scnassets/Models/FocusScene.scn")!
      focusNode = focusScene.rootNode.childNode(
        withName: "focus", recursively: false)!
      
      sceneView.scene.rootNode.addChildNode(focusNode)
    }
    
    // MARK: - Helper Functions
    
    func throwDiceNode(transform: SCNMatrix4, offset: SCNVector3) {
      
      let distance = simd_distance(focusNode.simdPosition,
                                   simd_make_float3(transform.m41,
                                                    transform.m42,
                                                    transform.m43))
      
      let direction = SCNVector3(-(distance * 2.5) * transform.m31,
                                 -(distance * 2.5) * (transform.m32 - Float.pi / 4),
                                 -(distance * 2.5) * transform.m33)
      
      let rotation = SCNVector3(Double.random(min: 0, max: Double.pi),
                                Double.random(min: 0, max: Double.pi),
                                Double.random(min: 0, max: Double.pi))
      
      let position = SCNVector3(transform.m41 + offset.x,
                                transform.m42 + offset.y,
                                transform.m43 + offset.z)
      
      let diceNode = diceNodes[diceStyle].clone()
      diceNode.name = "dice"
      diceNode.position = position
      diceNode.eulerAngles = rotation
      diceNode.physicsBody?.resetTransform()
      diceNode.physicsBody?.applyForce(direction, asImpulse: true)
      
      sceneView.scene.rootNode.addChildNode(diceNode)
      diceCount -= 1
    }
    
    func updateStatus() {
      // 1
      switch gameState {
      case .detectSurface:
        statusMessage = "Scan entire table surface..."
      case .pointToSurface:
        statusMessage = "Point at designated surface first!"
      case .swipeToPlay:
        statusMessage = "Swipe UP to throw!\nTap die to collect."
      }
      // 2
      self.statusLabel.text = trackingStatus != "" ?
        "\(trackingStatus)" : "\(statusMessage)"
    }
    
    func updateFocusNode() {
      
      let results = self.sceneView.hitTest(self.focusPoint, types: [.existingPlaneUsingExtent])
      
      if results.count == 1 {
        if let match = results.first {
          let t = match.worldTransform
          self.focusNode.position = SCNVector3(x: t.columns.3.x, y: t.columns.3.y, z: t.columns.3.z)
          self.gameState = .swipeToPlay
          focusNode.isHidden = false
        }
      } else {
        self.gameState = .pointToSurface
        focusNode.isHidden = true
      }
    }
    
    func createARPlaneNode(planeAnchor: ARPlaneAnchor, color: UIColor) -> SCNNode {
      
      let planeGeometry = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
      
      let planeMaterial = SCNMaterial()
      planeMaterial.diffuse.contents = "PokerDice.scnassets/Textures/Surface_DIFFUSE.png"
      //planeMaterial.colorBufferWriteMask = .init(rawValue: 0)
      planeGeometry.materials = [planeMaterial]
      
      let planeNode = SCNNode(geometry: planeGeometry)
      planeNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z)
      planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
      
      planeNode.physicsBody = createARPlanePhysics(geometry: planeGeometry)
      
      return planeNode
    }
    
    func updateARPlaneNode(planeNode: SCNNode, planeAchor: ARPlaneAnchor) {
      
      let planeGeometry = planeNode.geometry as! SCNPlane
      planeGeometry.width = CGFloat(planeAchor.extent.x)
      planeGeometry.height = CGFloat(planeAchor.extent.z)
      
      planeNode.position = SCNVector3Make(planeAchor.center.x, 0, planeAchor.center.z)
      
      planeNode.physicsBody = nil
      planeNode.physicsBody = createARPlanePhysics(geometry: planeGeometry)
    }
    
    func removeARPlaneNode(node: SCNNode) {
      for childNode in node.childNodes {
        childNode.removeFromParentNode()
      }
    }
    
    func updateDiceNodes() {
      for node in sceneView.scene.rootNode.childNodes {
        if node.name == "dice" {
          if  node.presentation.position.y < -2 {
            node.removeFromParentNode()
            diceCount += 1
          }
        }
      }
    }
    
    func createARPlanePhysics(geometry: SCNGeometry) -> SCNPhysicsBody {
      let physicsBody = SCNPhysicsBody(
        type: .kinematic,
        shape: SCNPhysicsShape(geometry: geometry, options: nil))
      physicsBody.restitution = 0.5
      physicsBody.friction = 0.5
      return physicsBody
    }
    
    func suspendARPlaneDetection() {
      let config = sceneView.session.configuration as! ARWorldTrackingConfiguration
      config.planeDetection = []
      sceneView.session.run(config)
    }
    
    func hideARPlaneNodes() {
      for anchor in (self.sceneView.session.currentFrame?.anchors)! {
        if let node = self.sceneView.node(for: anchor) {
          for child in node.childNodes {
            let material = child.geometry?.materials.first!
            material?.colorBufferWriteMask = .init(rawValue: 0)
          }
        }
      }
    }
    
    func startGame() {
      DispatchQueue.main.async {
        self.suspendARPlaneDetection()
        self.hideARPlaneNodes()
        self.gameState = .pointToSurface
      }
    }
    
    func resetARSession() {
      let config = sceneView.session.configuration as!
      ARWorldTrackingConfiguration
      config.planeDetection = .horizontal
      sceneView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func resetGame() {
      DispatchQueue.main.async {
        self.resetARSession()
        self.gameState = .detectSurface
      }
    }
  }

  extension ViewController : ARCoachingOverlayViewDelegate {
      
      // MARK: - AR Coaching Overlay View
      
      func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) {
      }
      
      func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
          self.startGame()
      }
      
      func coachingOverlayViewDidRequestSessionReset(_ coachingOverlayView: ARCoachingOverlayView) {
          self.resetGame()
      }
  }

  extension ViewController : ARSCNViewDelegate {
    
    // MARK: - SceneKit Management
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
      DispatchQueue.main.async {
        self.updateFocusNode()
        self.updateDiceNodes()
        self.updateStatus()
      }
    }
    
    // MARK: - Session State Management
    
    func session(_ session: ARSession,
                 cameraDidChangeTrackingState camera: ARCamera) {
      switch camera.trackingState {
      case .notAvailable:
        self.trackingStatus = "Tacking:  Not available!"
        break
      case .normal:
        self.trackingStatus = ""
        break
      case .limited(let reason):
        switch reason {
        case .excessiveMotion:
          self.trackingStatus = "Tracking: Limited due to excessive motion!"
          break
        case .insufficientFeatures:
          self.trackingStatus = "Tracking: Limited due to insufficient features!"
          break
        case .relocalizing:
          self.trackingStatus = "Tracking: Relocalizing..."
          break
        case .initializing:
          self.trackingStatus = "Tracking: Initializing..."
          break
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
      guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
      DispatchQueue.main.async {
        
        let planeNode = self.createARPlaneNode(planeAnchor: planeAnchor,
          color: UIColor.yellow.withAlphaComponent(0.5))
        node.addChildNode(planeNode)
      }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
      guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
      DispatchQueue.main.async {
        self.updateARPlaneNode(
          planeNode: node.childNodes[0],
          planeAchor: planeAnchor)
      }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
      guard anchor is ARPlaneAnchor else { return }
      DispatchQueue.main.async {
        self.removeARPlaneNode(node: node)
      }
    }
  }

