//
//  Label.swift
//  ImageDetection
//
//  Created by Tim Fosteman on 2020-02-11.
//  Copyright © 2020 Fosteman's Software Solutions LLC. All rights reserved.
//
import SpriteKit

/// - Tag: LabelNode
class LabelNode: SKReferenceNode {
    private let text: String
    
    init(text: String) {
        self.text = text
        // Force call to designated init(fileNamed: String?), not convenience init(fileNamed: String)
        super.init(fileNamed: Optional.some("LabelScene"))
        setScale(0.2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didLoad(_ node: SKNode?) {
        // Apply text to both labels loaded from the template.
        guard let parent = node?.childNode(withName: "LabelNode") else {
            fatalError("misconfigured SpriteKit scene")
        }
        for case let label as SKLabelNode in parent.children {
            label.name = text
            label.text = text
        }
    }
}
