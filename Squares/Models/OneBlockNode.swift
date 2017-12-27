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
    func oneBlockWasSet(sender: OneBlockNode)
}

class OneBlockNode: SKSpriteNode {
    
    let numOfCell:Int = 1
    
    let lowScaleNum:CGFloat = 0.6
    let midScaleNum:CGFloat = 0.83
    let moveDuration:TimeInterval = 0.05
    
    let tileWidth: CGFloat
    let blockColor: SKColor
    let initialPosition: CGPoint
    let blockOffset: CGFloat
    let touchYOffset: CGFloat
    
    var releasePosition: CGPoint?
    var placedIntoBoard:Bool = false
    var isMoving:Bool = false
    
    weak var blockDelegate: OneBlockNodeDelegate!
    
    //MARK:- Initialization
    init(width: CGFloat, color: SKColor, position: CGPoint) {
        
        // set up instance variable
        tileWidth = width
        blockColor = color
        initialPosition = position
        
        blockOffset = width
        touchYOffset = tileWidth/2 + 20
        super.init(texture: nil, color: .clear, size: CGSize(width:width*3, height:width*3))
        self.name = "oneblock"
        
        // set up options
        isUserInteractionEnabled = true
        
        // add block cell nodes
        let block1 = BlockCellNode(color: color)
        block1.size = CGSize(width: tileWidth, height: tileWidth)
        block1.position = CGPoint(x:0.0, y:blockOffset)
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
    
    func setNodeAt(positionInScreen: CGPoint?) {
        // block not set at a valid position. move back to original position
        if positionInScreen == nil{
            let scaleDown = SKAction.scale(to: lowScaleNum, duration: moveDuration*2.0)
            let moveBack = SKAction.move(to: initialPosition, duration: moveDuration*2.0)
            self.run(SKAction.group([scaleDown, moveBack]))
            return
        }
        
        self.placedIntoBoard = true
        let blockPosition = CGPoint(x: positionInScreen!.x,
                                    y: positionInScreen!.y-blockOffset)
        let scaleUp = SKAction.scale(to: 1.0, duration: moveDuration)
        let moveToTarget = SKAction.move(to: blockPosition, duration: moveDuration)
        self.run(SKAction.group([scaleUp, moveToTarget]))
        
        isUserInteractionEnabled = false
        
        // post to delegate
        self.blockDelegate.oneBlockWasSet(sender: self)
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
        
        //let touch = touches.first
        //let touchLocation = touch!.location(in: self.parent!)
        
        // set release position of the block nodes
        for child in self.children {
            if let blockCellNode = child as? BlockCellNode {
                print("HEY")
                print(blockCellNode.position.x)
                print(blockCellNode.position.y)
                let blockCellPosition = CGPoint(x: blockCellNode.position.x*midScaleNum+self.position.x,
                                               y: blockCellNode.position.y*midScaleNum+self.position.y)
                self.releasePosition = blockCellPosition
            }
        }
        
        self.blockDelegate.oneBlockWasReleased(sender: self)
        
    }
    
}

