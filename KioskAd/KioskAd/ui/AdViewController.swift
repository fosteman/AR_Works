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
        sceneView.delegate = self // mediate AR Scene's view and SceneKit content
        sceneView.session.delegate = self //receive captured video images and tracking information, and respond to changes in session status
        sceneView.showsStatistics = true

        let scene = SCNScene()
        sceneView.scene = scene

        // Draw TargetAim drawing on view
        let targetView = TargetView(frame: view.bounds)
        view.addSubview(targetView)
        self.targetView = targetView
        targetView.show()
    }

      override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .camera
        sceneView.session.run(configuration)
      }

      override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
      }
    
    //MARK: - Auxillary
    
    func createBillboard(
        with billboardData: BillboardData,
        topLeft: matrix_float4x4,
        topRight: matrix_float4x4,
        bottomRight: matrix_float4x4,
        bottomLeft: matrix_float4x4) {
        
        let plane = RectangularPlane(topLeft: topLeft, topRight: topRight, bottomLeft: bottomLeft, bottomRight: bottomRight)
        //Rotate center counterclockwise
        let rotation = SCNMatrix4MakeRotation(Float.pi / 2, 0, 0, 1)
        let rotatedCenter = plane.center * simd_float4x4(rotation)
        //anchor in the middle of the rectangle-orientation
        let anchor = ARAnchor(transform: rotatedCenter)
        //create sized billboard container
        self.billboard = BillboardContainer(billboardData: billboardData,
                                       billboardAnchor: anchor,
                                       plane: plane)
        sceneView.session.add(anchor: anchor)
        print("Billboard Created")
    }
    
    func addBillboardNode() -> SCNNode? {
        guard let b = self.billboard else {return nil}
        let rect = SCNPlane(width: b.plane.width, height: b.plane.height)
        let node = SCNNode(geometry: rect)
        self.billboard?.billboardNode = node
        
        return node
    }
    
    func removeBillboard() {
        if let anchor = self.billboard?.billboardAnchor {
            sceneView.session.remove(anchor: anchor)
            self.billboard?.billboardNode?.removeFromParentNode()
            self.billboard = nil
        }
    }
    
    func removeVideo() {
        if let videoAnchor = self.billboard?.videoAnchor {
            sceneView.session.remove(anchor: videoAnchor)
            self.billboard?.videoNode?.removeFromParentNode()
            self.billboard?.videoAnchor = nil
            self.billboard?.videoNode = nil
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
        
        let frameSize = CGSize(width: 1280, height: 720)
        let videoUrl = URL(string: billboard.billboardData.videoUrl)!
        let player = AVPlayer(url: videoUrl)
        let videoPlayerNode = SKVideoNode(avPlayer: player)
        let SKscene = SKScene(size: frameSize)
        
        videoPlayerNode.size = frameSize
        videoPlayerNode.position = CGPoint(x: frameSize.width / 2, y: frameSize.height / 2)
        videoPlayerNode.yScale = -1.0
        SKscene.addChild(videoPlayerNode)
        
        let billboardSize = CGSize(width: billboard.plane.width, height: billboard.plane.height)
        let plane = SCNPlane(width: billboardSize.width, height: billboardSize.height)
        plane.firstMaterial!.isDoubleSided = true
        plane.firstMaterial!.diffuse.contents = SKscene
        let node = SCNNode(geometry: plane)
        
        self.billboard?.videoNode = node
        self.billboard?.billboardNode?.isHidden = true
        videoPlayerNode.play()
        
        return node
    }
    
    func createBillboardController() {
        DispatchQueue.main.async {
            // create an instance of the initial navigation view controller from Billboard.storyboard
            let navController = UIStoryboard(name: "Billboard", bundle: nil)
            .instantiateInitialViewController() as! UINavigationController
            //
            let billboardViewController = navController.visibleViewController as! BillboardViewController

            billboardViewController.sceneView = self.sceneView
            billboardViewController.billboard = self.billboard
            
            //preparations
            billboardViewController.willMove(toParent: self)
            self.addChild(billboardViewController)
            self.view.addSubview(billboardViewController.view)
            
            self.show(billboardViewController)
        }
    }
    
    func show(_ viewController: BillboardViewController) {
        let material = SCNMaterial()
        material.isDoubleSided = true
        material.cullMode = .front
        
        material.diffuse.contents = viewController.view
        
        self.billboard?.viewController = viewController
        self.billboard?.billboardNode?.geometry?.materials = [material]
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
                    self.createBillboardController()
                case billboard.videoAnchor:
                    node = addVideoPlayerNode()
                default:
                    break
            }
        }
//        let images = billboard.billboardData.images.map {
//            UIImage(named: $0)!
//        }
        
        return node
    }
}

//MARK: - ARKit Session Delegate
extension AdViewController: ARSessionDelegate {
  func session(_ session: ARSession, didFailWithError error: Error) {
  }

  func sessionWasInterrupted(_ session: ARSession) {
    removeBillboard()
  }

  func sessionInterruptionEnded(_ session: ARSession) {
  }
}

// MARK: - User Interface
extension AdViewController {
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    //Remove video node if exists
    if billboard?.hasVideoNode == true {
        billboard?.billboardNode?.isHidden = false
        removeVideo()
        return
    }
    
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
                ///Decode the QR
                guard let json = r.payloadStringValue else {return}
                guard let billboardData = BillboardData.decode(from: json) else {return}
                
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
                    
                    self.createBillboard(with: billboardData,
                                         topLeft: coordinates[0],
                                         topRight: coordinates[1],
                                         bottomRight: coordinates[2],
                                         bottomLeft: coordinates[3])
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
