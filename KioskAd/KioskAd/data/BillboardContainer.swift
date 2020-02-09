//

import ARKit
import SceneKit

struct BillboardContainer {
  var billboardAnchor: ARAnchor
  var billboardNode: SCNNode?
  var plane: RectangularPlane
    var viewController: BillboardViewController?

  var hasBillboardNode: Bool { return billboardNode != nil }

  init(billboardAnchor: ARAnchor, plane: RectangularPlane) {
    self.billboardAnchor = billboardAnchor
    self.plane = plane
    self.billboardNode = nil
  }
}

