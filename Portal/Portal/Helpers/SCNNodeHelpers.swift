//
//  SCNNodeHelpers.swift
//  Portal
//
//  Created by Tim Fosteman on 2020-02-07.

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

// show the floor and ceiling nodes inside portal
func makeOuterSurfaceNode(width: CGFloat,
                          height: CGFloat,
                          length: CGFloat) -> SCNNode {
  let outerSurface = SCNBox(width: SURFACE_WIDTH, height: SURFACE_HEIGHT, length: SURFACE_LENGTH, chamferRadius: 0)
  
  outerSurface.firstMaterial?.diffuse.contents = UIColor.white //render the object
  outerSurface.firstMaterial?.transparency = 0.1 // hide from view
  let outerSurfaceNode = SCNNode(geometry: outerSurface)
  outerSurfaceNode.renderingOrder = 10 // rendered last
  ///In order to hide the floor and ceiling outside the portal, they'll have greater `renderingOrder`
  return outerSurfaceNode
}

func makeFloorNode() -> SCNNode {
  let outerFloorNode = makeOuterSurfaceNode(width: SURFACE_WIDTH, height: SURFACE_HEIGHT, length: SURFACE_LENGTH)
  
  outerFloorNode.position = SCNVector3(SURFACE_HEIGHT * 0.5, -SURFACE_HEIGHT, 0) //lay out on the bottom side
  
  let floorNode = SCNNode() // to hold inner and outer
  floorNode.addChildNode(outerFloorNode)
  
  let innerFloor = SCNBox(width: SURFACE_WIDTH, height: SURFACE_HEIGHT, length: SURFACE_LENGTH, chamferRadius: 0)
  //set visual properties for the material
  innerFloor.firstMaterial?.lightingModel = .physicallyBased
  innerFloor.firstMaterial?.diffuse.contents = UIImage(named: "Assets.scnassets/floor/textures/Floor_Diffuse.png")
  innerFloor.firstMaterial?.normal.contents = UIImage(named: "Assets.scnassets/floor/textures/Floor_Normal.png")
  innerFloor.firstMaterial?.roughness.contents = UIImage(named: "Assets.scnassets/floor/textures/Floor_Roughness.png")
  innerFloor.firstMaterial?.specular.contents = UIImage(named: "Assets.scnassets/floor/textures/Floor_Specular.png")
  innerFloor.firstMaterial?.selfIllumination.contents = UIImage(named: "Assets.scnassets/floor/textures/Floor_Gloss.png")
  
  repeatTextures(geometry: innerFloor, scaleX: SCALEX, scaleY: SCALEY)
  
  let innerFloorNode = SCNNode(geometry: innerFloor)
  innerFloorNode.renderingOrder = 100 // ensure floor is invisible while outside of portal
  innerFloorNode.position = SCNVector3(SURFACE_HEIGHT * 0.5, 0, 0) // position to sit above the outerFloorNode
  floorNode.addChildNode(innerFloorNode)
  
  return floorNode
}

func makeCeilingNode() -> SCNNode {
  let outerCeilingNode = makeOuterSurfaceNode(width: SURFACE_WIDTH, height: SURFACE_HEIGHT, length: SURFACE_LENGTH)
  outerCeilingNode.position = SCNVector3(SURFACE_HEIGHT * 0.5, SURFACE_HEIGHT, 0) // goes on top
  
  let ceilingNode = SCNNode()
  ceilingNode.addChildNode(outerCeilingNode)
  
  let innerCeiling = SCNBox(width: SURFACE_WIDTH, height: SURFACE_HEIGHT, length: SURFACE_LENGTH, chamferRadius: 0)
  innerCeiling.firstMaterial?.lightingModel = .physicallyBased
  innerCeiling.firstMaterial?.diffuse.contents =
      UIImage(named:
  "Assets.scnassets/ceiling/textures/Ceiling_Diffuse.png")
  innerCeiling.firstMaterial?.emission.contents =
      UIImage(named:
  "Assets.scnassets/ceiling/textures/Ceiling_Emis.png")
  innerCeiling.firstMaterial?.normal.contents =
      UIImage(named:
  "Assets.scnassets/ceiling/textures/Ceiling_Normal.png")
  innerCeiling.firstMaterial?.specular.contents =
      UIImage(named:
  "Assets.scnassets/ceiling/textures/Ceiling_Specular.png")
  innerCeiling.firstMaterial?.selfIllumination.contents =
  UIImage(named: "Assets.scnassets/ceiling/textures/Ceiling_Gloss.png")

  repeatTextures(geometry: innerCeiling, scaleX: SCALEX, scaleY: SCALEY)
  
  let innerCeilingNode = SCNNode(geometry: innerCeiling)
  innerCeilingNode.renderingOrder = 100
  innerCeilingNode.position = SCNVector3(SURFACE_HEIGHT * 0.5, 0, 0)
  
  ceilingNode.addChildNode(innerCeilingNode)
  return ceilingNode
}
