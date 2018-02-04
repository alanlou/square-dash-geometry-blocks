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
    init(color: SKColor, width: CGFloat) {
        let texture = SKTexture(imageNamed: "PauseButton")
        let textureSize = CGSize(width: width, height: width*texture.size().height/texture.size().width)
        
        // underlying larger area
        super.init(texture: nil, color: .clear, size: CGSize(width: width*1.5, height: width*1.5))
        
        self.name = "pausebutton"
        self.anchorPoint = CGPoint(x:0.0, y:1.0)
        self.isUserInteractionEnabled = true
        
        // set up pause button node
        pauseButtonNode = SKSpriteNode(texture: texture, color: .clear, size: textureSize)
        pauseButtonNode.colorBlendFactor = 1.0
        pauseButtonNode.color = color
        pauseButtonNode.anchorPoint = CGPoint(x:0.0, y:1.0)
        pauseButtonNode.position = CGPoint(x:width*0.25, y:-width*0.25)
        
        // add pause button
        self.addChild(pauseButtonNode)
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

