//

import ARKit
import SceneKit

class BillboardContainer {
  var billboardData: BillboardData
  var billboardAnchor: ARAnchor
  var billboardNode: SCNNode?
  var videoAnchor: ARAnchor?
  var videoNode: SCNNode?
  var plane: RectangularPlane
  var viewController: BillboardViewController?

  var hasBillboardNode: Bool { return billboardNode != nil }
  var hasVideoNode: Bool { return videoNode != nil }
  
  init(billboardData: BillboardData, billboardAnchor: ARAnchor, plane: RectangularPlane) {
    self.billboardData = billboardData
    self.billboardAnchor = billboardAnchor
    self.plane = plane
    self.billboardNode = nil
    self.videoAnchor = nil
    self.videoNode = nil
  }
}

