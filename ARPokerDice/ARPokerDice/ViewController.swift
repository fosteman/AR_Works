import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {
  
  // MARK: - Properties
  
  // MARK: - Outlets
  
  @IBOutlet var sceneView: ARSCNView!
  @IBOutlet weak var statusLabel: UILabel!
  @IBOutlet weak var styleButton: UIButton!
  @IBOutlet weak var resetButton: UIButton!
  
  // MARK: - Actions
  
  @IBAction func styleButtonPressed(_ sender: Any) {
  }
  
  @IBAction func resetButtonPressed(_ sender: Any) {
  }
  
  // MARK: - View Management
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initSceneView()
    initScene()
    initARSession()
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
  
  // MARK: - Initialization
  
  func initSceneView() {
    sceneView.delegate = self
    sceneView.showsStatistics = true
  }
  
  func initScene() {
    let scene = SCNScene(named: "art.scnassets/SimpleScene.scn")!
    scene.isPaused = false
    sceneView.scene = scene
  }
  
  func initARSession() {
  }
}

extension ViewController : ARSCNViewDelegate {
  
  // MARK: - SceneKit Management
  
  // MARK: - Session State Management
  
  // MARK: - Session Error Managent
  
  // MARK: - Plane Management
  
}

