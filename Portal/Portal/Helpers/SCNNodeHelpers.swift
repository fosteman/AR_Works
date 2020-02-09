//
//  SCNNodeHelpers.swift
//  Portal
//
//  Created by Tim Fosteman on 2020-02-07.
//  Copyright © 2020 Namrata Bandekar. All rights reserved.
//

import SceneKit

//Dimensions of the floor and
let SURFACE_LENGTH: CGFloat = 3.0
let SURFACE_HEIGHT: CGFloat = 0.2 //thickness
let SURFACE_WIDTH: CGFloat = 3.0

let SCALEX: Float = 2.0
let SCALEY: Float = 2.0

let WALL_WIDTH: CGFloat = 0.2 // thickness
let WALL_HEIGHT: CGFloat = 3.0
let WALL_LENGTH: CGFloat = 3.0

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

func repeatTextures(geometry: SCNGeometry, scaleX: Float, scaleY: Float) {
// S corresponds to X, T to Y
  // Definitions for wrapping mode of all visual properties of the material
geometry.firstMaterial?.diffuse.wrapS = SCNWrapMode.repeat
geometry.firstMaterial?.selfIllumination.wrapS = SCNWrapMode.repeat
geometry.firstMaterial?.normal.wrapS = SCNWrapMode.repeat
  geometry.firstMaterial?.specular.wrapS = SCNWrapMode.repeat
  geometry.firstMaterial?.emission.wrapS = SCNWrapMode.repeat
  geometry.firstMaterial?.roughness.wrapS = SCNWrapMode.repeat
// T Dimension
geometry.firstMaterial?.diffuse.wrapT = SCNWrapMode.repeat
geometry.firstMaterial?.selfIllumination.wrapT = SCNWrapMode.repeat
geometry.firstMaterial?.normal.wrapT = SCNWrapMode.repeat
  geometry.firstMaterial?.specular.wrapT = SCNWrapMode.repeat
  geometry.firstMaterial?.emission.wrapT = SCNWrapMode.repeat
  geometry.firstMaterial?.roughness.wrapT = SCNWrapMode.repeat
// Visual properties's contentsTransform is transformed with scale
geometry.firstMaterial?.diffuse.contentsTransform = SCNMatrix4MakeScale(scaleX, scaleY, 0)
geometry.firstMaterial?.selfIllumination.contentsTransform = SCNMatrix4MakeScale(scaleX, scaleY, 0)
geometry.firstMaterial?.normal.contentsTransform = SCNMatrix4MakeScale(scaleX, scaleY, 0)
geometry.firstMaterial?.specular.contentsTransform = SCNMatrix4MakeScale(scaleX, scaleY, 0)
geometry.firstMaterial?.emission.contentsTransform = SCNMatrix4MakeScale(scaleX, scaleY, 0)
geometry.firstMaterial?.roughness.contentsTransform = SCNMatrix4MakeScale(scaleX, scaleY, 0)
}
