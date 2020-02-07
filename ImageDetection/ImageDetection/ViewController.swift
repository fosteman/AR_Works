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

class ViewController: UIViewController, ARSCNViewDelegate {
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
        
        guard let storedImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {fatalError("")}
        
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.detectionImages = storedImages
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARImageAnchor {
            print("Recognized!")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
    func fetchDetectionTargets() {
        detectionTargetImages.append(DetectionTargetImage(title: "Extouring Business Card", info: "Founded by Bradley Heath"))
        //imageArray.append(DetectionTargetImage(title: "Saturn V rocket", info: "Apollo moon launch vehicle"))
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let imageAnchor = anchor as? ARImageAnchor else {return nil}
        
        let augmentation = detectionTargetImages.first { (DetectionTargetImage) -> Bool in
            DetectionTargetImage.title == imageAnchor.referenceImage.name
        }
        guard let found = augmentation else {return nil}
        print(found, augmentation)
        
        let foundPlane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
        
        foundPlane.firstMaterial?.diffuse.contents = UIColor.yellow
        let planeNode = SCNNode()
        planeNode.geometry = foundPlane
        let flip = GLKMathDegreesToRadians(-180)
        planeNode.eulerAngles = SCNVector3(flip, 0, 0)
        
        return planeNode
    }
}
