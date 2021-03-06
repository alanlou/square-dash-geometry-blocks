//
//  QuarterCircleNode.swift
//  Squares
//
//  Created by Alan Lou on 1/5/18.
//  Copyright © 2018 Rawwr Studios. All rights reserved.
//

import SpriteKit

protocol EyeButtonDelegate: NSObjectProtocol {
    func eyeWasPressed(sender: QuarterCircleNode)
}

class QuarterCircleNode: SKSpriteNode {
    
    var isShowingTiles: Bool = false
    weak var buttonDelegate: EyeButtonDelegate!
    
    //MARK:- Initialization
    init(color: SKColor, width: CGFloat) {
        let texture = SKTexture(imageNamed: "QuarterCircle")
        let textureSize = CGSize(width: width, height: width*texture.size().height/texture.size().width)
           
        super.init(texture: texture, color: .clear, size: textureSize)
        
        self.name = "quartercircle"
        self.isUserInteractionEnabled = true
        
        self.colorBlendFactor = 1.0
        self.color = color
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:- Helper Functions
    func changeColor(color: SKColor) {
        self.color = color
        self.colorBlendFactor = 1.0
    }
    
    func toggleIsShowingTiles() {
        self.isShowingTiles = !self.isShowingTiles
    }
    
    func getIsShowingTiles() -> Bool {
        return self.isShowingTiles
    }
    
    // MARK:- Touch Events
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
            self.buttonDelegate.eyeWasPressed(sender: self)
        }
    }
   
}


