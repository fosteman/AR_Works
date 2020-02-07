//
//  SCNNodeHelpers.swift
//  Portal
//
//  Created by Tim Fosteman on 2020-02-07.
//  Copyright © 2020 Namrata Bandekar. All rights reserved.
//

import SceneKit


func createPlaneNode(center: vector_float3, extent: vector_float3) -> SCNNode {
  //vector_float3 is used for physics calculations
  
  let plane = SCNPlane(width: CGFloat(extent.x), height: CGFloat(extent.z))
  let planeMaterial = SCNMaterial()
  planeMaterial.diffuse.contents = UIColor.yellow.withAlphaComponent(0.3)
  plane.materials = [planeMaterial]
  
  let planeNode = SCNNode(geometry: plane)
  /// SCNPlane inherits from SCNGeometry class,
  /// Multiplie nodes may reference same geometry instance
  
  planeNode.position = SCNVector3Make(center.x, 0, center.z)
  planeNode.transform = SCNMatrix4MakeRotation(-Float.pi, 1, 0, 0)
  return planeNode
}

func updatePlaneNode(_ node: SCNNode,
                     center: vector_float3,
                     extent: vector_float3) {
  let geometry = node.geometry as? SCNPlane
  
  geometry?.width = CGFloat(extent.x)
  geometry?.height = CGFloat(extent.y)
  
  node.position = SCNVector3Make(center.x, 0, center.z)
}
