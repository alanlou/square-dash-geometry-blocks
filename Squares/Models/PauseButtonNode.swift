//
//  PauseButtonNode.swift
//  Squares
//
//  Created by Alan Lou on 1/1/18.
//  Copyright © 2018 Rawwr Studios. All rights reserved.
//


import SpriteKit

protocol PauseButtonDelegate: NSObjectProtocol {
    func pauseButtonWasPressed(sender: PauseButtonNode)
}

class PauseButtonNode: SKSpriteNode {
    
    weak var buttonDelegate: PauseButtonDelegate!
    var pauseButtonNode: SKSpriteNode!
    
    //MARK:- Initialization
    init() {
        super.init(texture: nil, color: .clear, size: CGSize(width: 50, height: 50))
        
        self.name = "pausebutton"
        self.anchorPoint = CGPoint(x:0.0, y:1.0)
        self.isUserInteractionEnabled = true
        
        // set up pause button node
        let texture = SKTexture(imageNamed: "PauseButton")
        pauseButtonNode = SKSpriteNode(texture: texture, color: .clear, size: texture.size())
        pauseButtonNode.colorBlendFactor = 1.0
        pauseButtonNode.anchorPoint = CGPoint(x:0.0, y:1.0)
        pauseButtonNode.position = CGPoint(x:10, y:-10)
        
        // add pause button
        self.addChild(pauseButtonNode)
    }
    
    convenience init(color: SKColor) {
        self.init()
        pauseButtonNode.color = color
        pauseButtonNode.colorBlendFactor = 1.0
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:- Helper Functions
    func changeColor(to color: SKColor) {
        pauseButtonNode.color = color
        pauseButtonNode.colorBlendFactor = 1.0
    }
    
    //MARK:- Touch Events
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self.parent!)
        
        if self.contains(touchLocation) {
            self.buttonDelegate.pauseButtonWasPressed(sender: self)
        }
    }
    
}

