//
//  ViewController.swift
//  ImageDetection
//
//  Created by Tim Fosteman on 2020-02-05.
//  Copyright © 2020 Fosteman's Software Solutions LLC. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Vision

class VisionController: UIViewController {
    @IBOutlet var sceneView: ARSCNView!
    var detectionTargetImages: [DetectionTargetImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchDetectionTargets()
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let storedImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.detectionImages = storedImages
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func fetchDetectionTargets() {
        detectionTargetImages.append(DetectionTargetImage(title: "VMan", info: "'Virtuvian Man' by Leonardo Da Vinci"))
    }
    
    
}

// MARK: - ARSCNViewDelegate
extension VisionController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let imageAnchor = anchor as? ARImageAnchor else {
            print("found something else... \(anchor)")
            return nil
        }
        // Fetch context for detected image
        let context = detectionTargetImages.first {
            DetectionTargetImage in
            DetectionTargetImage.title == imageAnchor.referenceImage.name
        }
        
        //Detect the four veticles of observation of detected image
        
        return SCNNode()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
           if anchor is ARImageAnchor {
               print("New node added for detected image!")
           }
       }
}

// MARK: - ARSessionDelegate
//TODO: Implement session interruption handlers

//MARK: - Auxillary functionalities
extension VisionController {
    func drawAugmentation(center: matrix_float4x4,
                            size: CGSize) {
    }
    
    func createAugmentation(topLeft: matrix_float4x4,
    topRight: matrix_float4x4,
    bottomLeft: matrix_float4x4,
    bottomRight: matrix_float4x4) {
        //Create contextual augmentation to the tracked object
        
    }
    
    func detectRectangle() {
        guard let frame = sceneView.session.currentFrame else {return}
        DispatchQueue.global(qos: .background).async {
            do {
                let rectangleDetectionRequest = VNDetectRectanglesRequest {
                    (request, error) in
                    guard let r = request.results?.first as? VNRectangleObservation else {return}
                    
                    let coordinates: [matrix_float4x4] = [
                        r.topLeft,
                        r.topRight,
                        r.bottomRight,
                        r.bottomLeft].compactMap {
                            corner in
                            guard let cornerFeatureHit = frame.hitTest(corner, types: .featurePoint).first else {return nil} //reason for compactMap
                            return cornerFeatureHit.worldTransform
                    }
                    guard coordinates.count == 4 else {return}
                    
                    DispatchQueue.main.async {
                        // Create Augmented view
                        self.createAugmentation(topLeft: coordinates[0],
                                                topRight: coordinates[1],
                                                bottomLeft: coordinates[2],
                                                bottomRight: coordinates[3])
                        #if DEBUG
                        // Artistic drawing
                        #endif
                    }
                }
                //Perform computation
                let handler = VNImageRequestHandler(cvPixelBuffer: frame.capturedImage)
                try handler.perform([rectangleDetectionRequest])
            }
            catch(let error) {
                print(error.localizedDescription)
            }
        }
    }
}
