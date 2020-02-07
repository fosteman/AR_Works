//
//  ViewController.swift
//  Occlusion
//
//  Created by Tim Fosteman on 2020-02-05.
//  Copyright © 2020 Fosteman's Software Solutions LLC. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    // Store location of horizontal plane to draw occlusive underneath it
    var x: Float = 0
    var y: Float = 0
    var z: Float = 0
    
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]

        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        // Run the view's session
        sceneView.session.run(configuration)
        
        let tapGest = UITapGestureRecognizer(target: self, action: #selector(tapRes))
        sceneView.addGestureRecognizer(tapGest)
    }
    
    @objc func tapRes(_ sender: UITapGestureRecognizer) {
        let boxNode = SCNNode()
        boxNode.geometry = SCNBox(width: 0.08, height: 0.08, length: 0.08, chamferRadius: 0)
        boxNode.geometry?.firstMaterial?.diffuse.contents = UIColor.green
        boxNode.position = SCNVector3(x, y, z)
        sceneView.scene.rootNode.addChildNode(boxNode)
    }
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else {return}
        
        let planeNode = detectPlane(anchor as! ARPlaneAnchor)
        node.addChildNode(planeNode)
    }
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else {return}
        
        node.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }
        
        let planeNode = detectPlane(anchor as! ARPlaneAnchor)
        node.addChildNode(planeNode)
    }
    
    func detectPlane(_ anchor: ARPlaneAnchor) -> SCNNode {
        let planeNode = SCNNode()
        planeNode.geometry = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        //planeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.yellow
        planeNode.geometry?.firstMaterial?.colorBufferWriteMask = []
        planeNode.renderingOrder = -1 //be drawn before anything else
        planeNode.position = SCNVector3(anchor.center.x, anchor.center.y, anchor.center.z)
        
        x = anchor.center.x
        y = anchor.center.y - 0.4 //underneath
        z = anchor.center.z
        
        let ninetyDegrees = GLKMathDegreesToRadians(90) // flip the plane from vertical to horizontal
        planeNode.eulerAngles = SCNVector3(ninetyDegrees, 0 ,0)
        planeNode.geometry?.firstMaterial?.isDoubleSided = true
        
        return planeNode
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
