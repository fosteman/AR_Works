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
    let configuration = ARWorldTrackingConfiguration()
    configuration.worldAlignment = .camera
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
        //Rotate center counterclockwise
        let rotation = SCNMatrix4MakeRotation(Float.pi / 2, 0, 0, 1)
        let rotatedCenter = plane.center * simd_float4x4(rotation)
        //place anchor in the middle of the rectangle-orientation
        let anchor = ARAnchor(transform: rotatedCenter)
        
        billboard = BillboardContainer(billboardAnchor: anchor, plane: plane)
        
        sceneView.session.add(anchor: anchor)
        print("Billboard Created")
    }
    
    func addBillboardNode() -> SCNNode? {
        guard let billboard = billboard else {return nil}
        
        let rect = SCNPlane(width: billboard.plane.width, height: billboard.plane.height)
        let node = SCNNode(geometry: rect)
        ///Node rotation
        //node.eulerAngles = SCNVector3(
        self.billboard?.billboardNode = node
        
        return node
    }
    
    func removeBillboard() {
        if let anchor = billboard?.billboardAnchor {
            sceneView.session.remove(anchor: anchor)
            billboard?.billboardNode?.removeFromParentNode()
            billboard = nil
        }
    }
    
    func setBillboardImages(_ images: [UIImage]) {
        let material = SCNMaterial()
        material.isDoubleSided = true
        
        DispatchQueue.main.async {
            let billboardViewController = BillboardViewController(nibName: "BillboardViewController", bundle: nil)
            billboardViewController.delegate = self
            billboardViewController.images = images
            //assign the view that the controller manages
            material.diffuse.contents = billboardViewController.view
            self.billboard?.viewController = billboardViewController
            self.billboard?.billboardNode?.geometry?.materials = [material]
        }
    }
    
    func createVideo() {
        guard let billboard = self.billboard else {return}
        let rotation = SCNMatrix4MakeRotation(Float.pi / 2, 0, 0, 1)
        let rotatedCenter = matrix_float4x4(rotation) * billboard.plane.center
        let anchor = ARAnchor(transform: rotatedCenter)
        sceneView.session.add(anchor: anchor)
        self.billboard?.videoAnchor = anchor
        
    }
    
    func addVideoPlayerNode() -> SCNNode? {
        guard let billboard = billboard else {return nil}
        
        let billboardSize = CGSize(width: billboard.plane.width, height: billboard.plane.height)
        let frameSize = CGSize(width: 1024, height: 512)
        let videoUrl = URL(fileURLWithPath: "data/How to Visualize and Manifest Bigger Goals.mp4")
        
        let player = AVPlayer(url: videoUrl)
        print(player.error)
        let videoPlayerNode = SKVideoNode(avPlayer: player)
        videoPlayerNode.size = frameSize
        videoPlayerNode.position = CGPoint(x: frameSize.width / 2, y: frameSize.height / 2)
        videoPlayerNode.yScale = -1.0
        
        let SKscene = SKScene(size: frameSize)
        SKscene.addChild(videoPlayerNode)
        
        let plane = SCNPlane(width: billboardSize.width, height: billboardSize.height)
        plane.firstMaterial!.isDoubleSided = true
        plane.firstMaterial!.diffuse.contents = SKscene
        let node = SCNNode(geometry: plane)
        
        self.billboard?.videoNode = node
        self.billboard?.billboardNode?.isHidden = true
        videoPlayerNode.play()
        
        return node
    }
}

// MARK: - ARSCNViewDelegate
extension AdViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let billboard = billboard else {return nil}
        var node: SCNNode? = nil
        DispatchQueue.main.sync {
        switch anchor {
            case billboard.billboardAnchor:
            node = addBillboardNode()
        case (let videoAnchor)
            where videoAnchor == billboard.videoAnchor:
            node = addVideoPlayerNode()
            default:
            break
        }
            }
        let images = ["logo_1", "logo_2", "logo_3", "logo_4"].compactMap { img in
            UIImage(named: img)
        }
        setBillboardImages(images)
        
        return node
    }
}

extension AdViewController: ARSessionDelegate {
  func session(_ session: ARSession, didFailWithError error: Error) {
  }

  func sessionWasInterrupted(_ session: ARSession) {
    removeBillboard()
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
            let req = VNDetectBarcodesRequest {(request, error) in
                ///Access the first positive rectangle observation result
                guard
                    let results = request.results?.compactMap({
                    res in
                    return res as? VNBarcodeObservation
                }),
                let r = results.first
                else {
                    print("Vision does not observe barcode in its view")
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

extension AdViewController: BillboardViewDelegate {
    func billboardViewDidSelectPlayVideo(_ view: BillboardView) {
        createVideo()
    }
}
