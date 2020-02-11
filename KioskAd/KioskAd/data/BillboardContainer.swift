//

import ARKit
import SceneKit

// send notification via a delegate method call
protocol VideoPlayerDelegate: class {
    func didStartPlay()
    func didEndPlay()
}

class BillboardContainer {
  var billboardData: BillboardData
  var billboardAnchor: ARAnchor
  var billboardNode: SCNNode?
  var videoAnchor: ARAnchor?
  var videoNode: SCNNode?
  var plane: RectangularPlane
  var viewController: BillboardViewController?
  weak var videoPlayerDelegate: VideoPlayerDelegate? //reference to target entity tat expects notifications. Set to the instance that wants to be notified.The instance is the AdViewController because it must react to changes in the video player status
    weak var videoNodeHandler: VideoNodeHandler?
  var hasBillboardNode: Bool { return billboardNode != nil }
  var hasVideoNode: Bool { return videoNode != nil }
  var isFullScreen: Bool {return false}
    
  init(billboardData: BillboardData, billboardAnchor: ARAnchor, plane: RectangularPlane) {
    self.billboardData = billboardData
    self.billboardAnchor = billboardAnchor
    self.plane = plane
    self.billboardNode = nil
    self.videoAnchor = nil
    self.videoNode = nil
  }
}

