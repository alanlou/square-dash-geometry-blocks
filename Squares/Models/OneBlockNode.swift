//
//  OneBlockNode.swift
//  Squares
//
//  Created by Alan Lou on 12/23/17.
//  Copyright © 2017 Rawwr Studios. All rights reserved.
//

import SpriteKit

protocol OneBlockNodeDelegate: NSObjectProtocol {
    func oneBlockWasReleased(sender: OneBlockNode)
}

class OneBlockNode: SKSpriteNode {
    
    let numOfCell:Int = 1
    
    let lowScaleNum:CGFloat = 0.6
    let midScaleNum:CGFloat = 0.85
    let moveDuration:TimeInterval = 0.05
    
    let tileWidth: CGFloat
    let blockColor: SKColor
    let initialPosition: CGPoint
    let releasePosition: CGPoint?
    let touchYOffset: CGFloat
    
    var placedIntoBoard:Bool = false
    var isMoving:Bool = false
    
    weak var blockDelegate: OneBlockNodeDelegate!
    
    //MARK:- Initialization
    init(width: CGFloat, color: SKColor, position: CGPoint) {
        
        // set up instance variable
        tileWidth = width
        blockColor = color
        initialPosition = position
        
        touchYOffset = tileWidth/2 + 40
        super.init(texture: nil, color: SKColor.red.withAlphaComponent(0.0), size: CGSize(width:width*3, height:width*3))
        
        // set up options
        isUserInteractionEnabled = true
        
        // add block cell nodes
        let block1 = BlockCellNode(color: color)
        block1.size = CGSize(width: tileWidth, height: tileWidth)
        block1.position = CGPoint(x:0.0, y:width)
        self.addChild(block1)
        
        // scale underlying node
        self.setScale(lowScaleNum)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:- Helper Functions
    func getBlockColor() -> SKColor {
        return blockColor
    }
    
    func getBlockPosition() -> CGPoint {
        return initialPosition
    }
    
    func getReleasePosition() -> CGPoint? {
        return releasePosition
    }
    
    // MARK:- Touch Events
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first
        let touchLocation = touch!.location(in: self.parent!)
        
        if self.contains(touchLocation) {
            let targetPosition = CGPoint(x: touchLocation.x, y: touchLocation.y+touchYOffset)
            let scaleUp = SKAction.scale(to: midScaleNum, duration: moveDuration)
            let moveUp = SKAction.move(to: targetPosition, duration: moveDuration)
            
            self.run(SKAction.group([scaleUp, moveUp]), completion: {[weak self] in
                self?.isMoving = true
            })
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self.parent!)
        
        if isMoving {
            self.position = CGPoint(x: touchLocation.x, y: touchLocation.y+touchYOffset)
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        isMoving = false
        
        let touch = touches.first
        let touchLocation = touch!.location(in: self.parent!)
        releasePosition = touchLocation
        
        self.blockDelegate.blockWasReleased(sender: self)
        
        
        // back to original position
        if !placedIntoBoard {
            let scaleDown = SKAction.scale(to: lowScaleNum, duration: moveDuration)
            let moveBack = SKAction.move(to: initialPosition, duration: moveDuration)
            self.run(SKAction.group([scaleDown, moveBack]))
        }
    }
    
}

