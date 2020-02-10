//

import ARKit
import SceneKit

struct BillboardContainer {
    var billboardAnchor: ARAnchor
    var billboardNode: SCNNode?
    var billboardData: BillboardData
    var plane: RectangularPlane
    var videoAnchor: ARAnchor?
    var videoNode: SCNNode?
    var viewController: BillboardViewController?
    
    var hasBillboardNode: Bool { return billboardNode != nil }
    var hasVideoNode: Bool {return videoNode != nil}

    init(billboardData: BillboardData, billboardAnchor: ARAnchor, plane: RectangularPlane) {
        self.billboardAnchor = billboardAnchor
        self.plane = plane
        self.billboardData = billboardData
        
        self.billboardNode = nil
        self.videoNode = nil
        self.videoAnchor = nil
  }
}

