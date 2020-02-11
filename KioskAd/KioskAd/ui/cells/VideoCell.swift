import UIKit
import SpriteKit
import AVFoundation
import ARKit

protocol VideoNodeHandler: class {
    func createNode() -> SCNNode?
    func removeNode()
}

class VideoCell: UICollectionViewCell {
    var isPLaying = false
    var videoNode: SKVideoNode!
    var spriteScene: SKScene!
    var videoUrl: String!
    var player: AVPlayer?
    
    weak var billboard: BillboardContainer?
    weak var sceneView: ARSCNView?
    weak var videoNodeHandler: VideoNodeHandler?
    
  @IBOutlet weak var playButton: UIButton!
  @IBOutlet weak var playerContainer: UIView!

  func configure(videoUrl: String, sceneView: ARSCNView, billboard: BillboardContainer) {
    self.videoUrl = videoUrl
    self.sceneView = sceneView
    self.billboard = billboard
    self.videoNodeHandler = self
  }
    
    func createVideoPlayerAnchor() {
        guard let b = billboard else {return}
        guard let s = sceneView else {return}
        //create a new anchor centered at the billboard's center and apply correct rotation
        let center = b.plane.center * matrix_float4x4(SCNMatrix4MakeRotation(Float.pi / 2, 0, 0, 1))
        let anchor = ARAnchor(transform: center)
        //add to the scene
        s.session.add(anchor: anchor)
        //keep referene
        b.videoAnchor = anchor
    }

  @IBAction func play() {
    guard let b = billboard else {return}
    if b.isFullScreen {
        
    }
    else {
        createVideoPlayerAnchor()
        //notify the delegate
        b.videoPlayerDelegate?.didStartPlay()
        // prevent double taps
        playButton.isEnabled = false
    }
  }
}

extension VideoCell: VideoNodeHandler {
  func createNode() -> SCNNode? {
    guard let billboard = billboard else { return nil }

    let frameSize = CGSize(width: 1024, height: 1024)
    let url = URL(string: videoUrl)!

    let player = AVPlayer(url: url)
    videoNode = SKVideoNode(avPlayer: player)
    videoNode.size = frameSize
    videoNode.position = CGPoint(x: frameSize.width / 2, y: frameSize.height / 2)
    videoNode.yScale = -1.0

    spriteScene = SKScene(size: frameSize)
    spriteScene.scaleMode = .aspectFit
    spriteScene.backgroundColor = UIColor(white: 33/255, alpha: 1.0)
    spriteScene.addChild(videoNode)

    let billboardSize = CGSize(width: billboard.plane.width, height: billboard.plane.height / 2)
    let plane = SCNPlane(width: billboardSize.width, height: billboardSize.height)
    plane.firstMaterial!.isDoubleSided = true
    plane.firstMaterial!.diffuse.contents = spriteScene
    let node = SCNNode(geometry: plane)

    billboard.videoNode = node

    billboard.videoNodeHandler = self

    videoNode.play()
    return node
  }

  func removeNode() {
    videoNode?.pause()

    spriteScene?.removeAllChildren()
    spriteScene = nil

    if let videoAnchor = billboard?.videoAnchor {
      sceneView?.session.remove(anchor: videoAnchor)
    }

    billboard?.videoPlayerDelegate?.didEndPlay()

    billboard?.videoNode?.removeFromParentNode()
    billboard?.videoAnchor = nil
    billboard?.videoNode = nil

    playButton.isEnabled = true
  }
}
