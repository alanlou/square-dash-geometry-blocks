//
//  PlayButtonNode.swift
//  Squares
//
//  Created by Alan Lou on 1/22/18.
//  Copyright © 2018 Rawwr Studios. All rights reserved.
//

import SpriteKit

struct PlayButtonType {
    static let PlayButton:  String = "PlayButton"
    static let RestartButton:  String = "RestartButton"
}

protocol PlayButtonDelegate: NSObjectProtocol {
    func playButtonWasPressed(sender: PlayButtonNode)
}

class PlayButtonNode: SKSpriteNode {
    
    weak var buttonDelegate: PlayButtonDelegate!
    
    //MARK:- Initialization
    init(color: SKColor, width: CGFloat, type: String) {
        let texture = SKTexture(imageNamed: type)
        let textureSize = CGSize(width: width, height: width)
        super.init(texture: texture, color: .clear, size: textureSize)
        self.name = "playbutton"
        self.isUserInteractionEnabled = true
        self.anchorPoint = CGPoint(x:0.5, y:0.5)
        self.color = color
        self.colorBlendFactor = 1.0
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:- Helper Functions
    func changeColor(to color: SKColor) {
        self.color = color
        self.colorBlendFactor = 1.0
    }
    
    //MARK:- Touch Events
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self.parent!)
        
        if self.contains(touchLocation) {
            let scaleUp = SKAction.scale(to: 1.1, duration: 0.15)
            self.run(scaleUp)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self.parent!)
        
        if self.contains(touchLocation) {
            let scaleUp = SKAction.scale(to: 1.1, duration: 0.10)
            self.run(scaleUp)
        } else {
            let scaleDown = SKAction.scale(to: 1.0, duration: 0.08)
            self.run(scaleDown)
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self.parent!)
        
        self.zRotation = 0.0
        self.removeAllActions()
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.08)
        self.run(scaleDown)
        
        if self.contains(touchLocation) {
            self.buttonDelegate.playButtonWasPressed(sender: self)
        }
    }
    
}
