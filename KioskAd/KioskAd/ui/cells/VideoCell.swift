import UIKit
import SpriteKit
import AVFoundation
import ARKit

class VideoCell: UICollectionViewCell {
  @IBOutlet weak var playButton: UIButton!
  @IBOutlet weak var playerContainer: UIView!

  func configure(videoUrl: String, sceneView: ARSCNView, billboard: BillboardContainer) {
  }

  @IBAction func play() {
  }
}

//extension VideoCell: VideoNodeHandler {
//  func createNode() -> SCNNode? {
//    guard let billboard = billboard else { return nil }
//
//    let frameSize = CGSize(width: 1024, height: 1024)
//    let url = URL(string: videoUrl)!
//
//    let player = AVPlayer(url: url)
//    videoNode = SKVideoNode(avPlayer: player)
//    videoNode.size = frameSize
//    videoNode.position = CGPoint(x: frameSize.width / 2, y: frameSize.height / 2)
//    videoNode.yScale = -1.0
//
//    spriteScene = SKScene(size: frameSize)
//    spriteScene.scaleMode = .aspectFit
//    spriteScene.backgroundColor = UIColor(white: 33/255, alpha: 1.0)
//    spriteScene.addChild(videoNode)
//
//    let billboardSize = CGSize(width: billboard.plane.width, height: billboard.plane.height / 2)
//    let plane = SCNPlane(width: billboardSize.width, height: billboardSize.height)
//    plane.firstMaterial!.isDoubleSided = true
//    plane.firstMaterial!.diffuse.contents = spriteScene
//    let node = SCNNode(geometry: plane)
//
//    billboard.videoNode = node
//
//    billboard.videoNodeHandler = self
//
//    videoNode.play()
//    return node
//  }
//
//  func removeNode() {
//    videoNode?.pause()
//
//    spriteScene?.removeAllChildren()
//    spriteScene = nil
//
//    if let videoAnchor = billboard?.videoAnchor {
//      sceneView?.session.remove(anchor: videoAnchor)
//    }
//
//    billboard?.videoPlayerDelegate?.didEndPlay()
//
//    billboard?.videoNode?.removeFromParentNode()
//    billboard?.videoAnchor = nil
//    billboard?.videoNode = nil
//
//    playButton.isEnabled = true
//  }
//}
