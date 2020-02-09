import UIKit
import SceneKit
import ARKit
import Vision

class AdViewController: UIViewController {
  @IBOutlet var sceneView: ARSCNView!
  weak var targetView: TargetView!

  private var billboard: BillboardContainer?

  override func viewDidLoad() {
    super.viewDidLoad()
    sceneView.delegate = self
    sceneView.session.delegate = self
    sceneView.showsStatistics = true
    
    let scene = SCNScene()
    sceneView.scene = scene

    // Setup the target view
    let targetView = TargetView(frame: view.bounds)
    view.addSubview(targetView)
    self.targetView = targetView
    targetView.show()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    // Create a session configuration
    let configuration = ARWorldTrackingConfiguration()

    // Run the view's session
    sceneView.session.run(configuration)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    // Pause the view's session
    sceneView.session.pause()
  }
    
    
    //MARK: - Creating Nodes
    func createBillboard(topLeft: matrix_float4x4,
                         topRight: matrix_float4x4,
                         bottomRight: matrix_float4x4,
                         bottomLeft: matrix_float4x4) {
        let plane = RectangularPlane(topLeft: topLeft, topRight: topRight, bottomLeft: bottomLeft, bottomRight: bottomRight)
        //place anchor in the middle of the rectangle-orientation
        let anchor = ARAnchor(transform: plane.center)
        
        billboard = BillboardContainer(billboardAnchor: anchor, plane: plane)
        
        sceneView.session.add(anchor: anchor)
        print("Billboard Created")
    }
    
    func removeBillboard() {
        if let anchor = billboard?.billboardAnchor {
            sceneView.session.remove(anchor: anchor)
            billboard?.billboardNode?.removeFromParentNode()
            billboard = nil
        }
    }
}

// MARK: - ARSCNViewDelegate
extension AdViewController: ARSCNViewDelegate {
}

extension AdViewController: ARSessionDelegate {
  func session(_ session: ARSession, didFailWithError error: Error) {
  }

  func sessionWasInterrupted(_ session: ARSession) {
  }

  func sessionInterruptionEnded(_ session: ARSession) {
  }
}

extension AdViewController {
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    ///Ar Session carries an `ARFrame`
    guard let currentFrame = sceneView.session.currentFrame else { return}
    
    DispatchQueue.global(qos: .background).async {
        do {
            ///Create rectangle detection request with a callback
            let req = VNDetectRectanglesRequest {(request, error) in
                ///Access the first positive rectangle observation result
                guard
                    let results = request.results?.compactMap({
                    res in
                    return res as? VNRectangleObservation
                }),
                let r = results.first
                else {
                    print("Vision does not observe rectangle")
                    return
                }
                ///Use the four verticles of observation of detected rectangle
                let coordinates: [matrix_float4x4] = [
                r.topLeft,
                r.topRight,
                r.bottomRight,
                r.bottomLeft
                    ].compactMap {
                        ///unflatten the observation points getting world coordinates (transform)
                        (aim) in
                        ///Collect the nearest feature point transform, since no alignment is intended to be preserved
                        guard let hitFeature = currentFrame.hitTest(aim, types: .featurePoint).first else {return nil}
                        return hitFeature.worldTransform
                }
                ///Check for perfect detection of the rectangle
                guard coordinates.count == 4 else {return}
                
                DispatchQueue.main.async {
                    ///Cleanup the screen in case billboard was previously rendered
                    self.removeBillboard()
                    /// Destruct the array onto vectors
                    let (topLeft, topRight, bottomRight, bottomLeft) = (coordinates[0], coordinates[1], coordinates[2],
                       coordinates[3])
                    
                    self.createBillboard(topLeft: coordinates[0],topRight: coordinates[1],bottomRight: coordinates[2],bottomLeft: coordinates[3])
                    #if DEBUG
                    // Display placemarks
                    for c in coordinates {
                        let mark = SCNBox(width: 0.01, height: 0.01, length: 0.001, chamferRadius: 0)
                        let node = SCNNode(geometry: mark)
                        node.transform = SCNMatrix4(c)
                        self.sceneView.scene.rootNode.addChildNode(node)
                    }
                    #endif
                }
            }
            //Execute the Vision request
            let handler = VNImageRequestHandler(cvPixelBuffer: currentFrame.capturedImage)
            try handler.perform([req])
            
        } catch(let error) {
            print("Error occured in Vision request: \(error.localizedDescription)")
        }
    }
  }
}

private extension AdViewController {
}
