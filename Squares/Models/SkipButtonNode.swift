//
//  SkipButtonNode.swift
//  Squares
//
//  Created by Alan Lou on 2/6/18.
//  Copyright © 2018 Rawwr Studios. All rights reserved.
//

//
//  skipButtonNode.swift
//  Squares
//
//  Created by Alan Lou on 1/1/18.
//  Copyright © 2018 Rawwr Studios. All rights reserved.
//

import SpriteKit

protocol SkipButtonDelegate: NSObjectProtocol {
    func skipButtonWasPressed(sender: SkipButtonNode)
}

class SkipButtonNode: SKSpriteNode {
    
    // delegate
    weak var buttonDelegate: SkipButtonDelegate!
    
    // nodes
    var skipButtonNode: SKSpriteNode!
    var skipMessageNode: MessageNode!
    
    //MARK:- Initialization
    init(color: SKColor, width: CGFloat){
        let texture = SKTexture(imageNamed: "SkipButton")
        let textureSize = CGSize(width: width*0.4, height: width*texture.size().height/texture.size().width*0.4)
        
        super.init(texture: nil, color: .clear, size: CGSize(width: width*1.5, height: width*1.2))
        
        self.name = "skipbutton"
        self.anchorPoint = CGPoint(x:0.0, y:1.0)
        self.isUserInteractionEnabled = true
        self.alpha = 0.8
        
        // set up skip message node
        let messageText = NSLocalizedString("Skip", comment: "")
        skipMessageNode = MessageNode(message: messageText)
        let messageNodeFrame = CGRect(x: width*0.05,
                                      y: -width*0.80,
                                      width: width*1.0,
                                      height: width*0.5)
        skipMessageNode.adjustLabelFontSizeToFitRect(rect: messageNodeFrame)
        skipMessageNode.setHorizontalAlignment(mode: .right)
        //debugDrawArea(rect: messageNodeFrame)
        
        // set up skip button node
        skipButtonNode = SKSpriteNode(texture: texture, color: .clear, size: textureSize)
        skipButtonNode.colorBlendFactor = 1.0
        skipButtonNode.anchorPoint = CGPoint(x:0.0, y:1.0)
        skipButtonNode.position = CGPoint(x:width*1.15, y:-width*0.35)
        
        // add children
        self.addChild(skipMessageNode)
        
        self.addChild(skipButtonNode)
        
        // change color
        skipButtonNode.color = color
        skipButtonNode.colorBlendFactor = 1.0
        skipMessageNode.setFontColor(color: color)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:- Helper Functions
    func changeColor(to color: SKColor) {
        skipButtonNode.color = color
        skipButtonNode.colorBlendFactor = 1.0
        skipMessageNode.setFontColor(color: color)
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
            self.buttonDelegate.skipButtonWasPressed(sender: self)
        }
    }
    
    //MARK:- Helper Functions
    func debugDrawArea(rect drawRect: CGRect) {
        let shape = SKShapeNode(rect: drawRect)
        shape.strokeColor = SKColor.red
        shape.lineWidth = 2.0
        self.addChild(shape)
    }
    
    
    
}

