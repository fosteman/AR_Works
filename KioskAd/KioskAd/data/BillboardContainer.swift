//

import ARKit
import SceneKit

struct BillboardContainer {
    var billboardAnchor: ARAnchor
    var billboardNode: SCNNode?
    var billboardData: BillboardData
    var plane: RectangularPlane
    var viewController: BillboardViewController?
    var videoAnchor: ARAnchor?
    var videoNode: SCNNode?

    var hasBillboardNode: Bool { return billboardNode != nil }
    var hasVideoNode: Bool {return videoNode != nil}

    init(billboardData: BillboardData, billboardAnchor: ARAnchor, plane: RectangularPlane) {
        self.billboardAnchor = billboardAnchor
        self.plane = plane
        self.billboardNode = nil
        self.videoNode = nil
        self.videoAnchor = nil
        self.billboardData = billboardData
  }
}

