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
    
    let lowScaleNum:CGFloat = 0.6
    let midScaleNum:CGFloat = 0.88
    let moveDuration:TimeInterval = 0.05
    
    let tileWidth: CGFloat
    let blockColorIndex: UInt32
    let bottomIndex: UInt32
    let initialPosition: CGPoint
    let blockOffset: CGFloat
    let touchYOffset: CGFloat
    
    var releasePosition: CGPoint?
    var isMoving:Bool = false
    
    var block1: BlockCellNode
    
    weak var blockDelegate: OneBlockNodeDelegate!
    
    //MARK:- Initialization
    init(width: CGFloat, colorIndex: UInt32, position: CGPoint, bottomIndex: UInt32) {
        
        // set up instance variable
        tileWidth = width
        initialPosition = position
        
        blockOffset = width
        touchYOffset = tileWidth/2 + 25
        
        block1 = BlockCellNode(colorIndex: colorIndex)
        blockColorIndex = colorIndex
        self.bottomIndex = bottomIndex
        
        super.init(texture: nil, color: .clear, size: CGSize(width:width*3, height:width*3))
        self.name = "oneblock"
        self.zPosition = 100
        self.anchorPoint = CGPoint(x:0.5, y:0.5+blockOffset/self.size.height)
        
        // set up options
        isUserInteractionEnabled = true
        
        // add block cell nodes
        block1.size = CGSize(width: tileWidth, height: tileWidth)
        block1.position = CGPoint(x:0.0, y:0.0)
        self.addChild(block1)
    }
    
    override func encode(with coder: NSCoder) {
        coder.encode(self.tileWidth, forKey: "width")
        coder.encode(self.blockColorIndex, forKey: "colorIndex")
        coder.encode(self.initialPosition, forKey: "position")
        coder.encode(self.bottomIndex, forKey: "bottomIndex")
    }

    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        let width = aDecoder.decodeObject(forKey: "width") as! CGFloat
        let colorIndex = aDecoder.decodeObject(forKey: "colorIndex") as! UInt32
        let position = aDecoder.decodeCGPoint(forKey: "position")
        let bottomIndex = aDecoder.decodeObject(forKey: "bottomIndex") as! UInt32
        
        // set up instance variable
        tileWidth = width
        initialPosition = position
        
        blockOffset = width
        touchYOffset = tileWidth/2 + 25
        
        block1 = BlockCellNode(colorIndex: colorIndex)
        blockColorIndex = colorIndex
        self.bottomIndex = bottomIndex
        
        super.init(texture: nil, color: .clear, size: CGSize(width:width*3, height:width*3))
        
        self.name = "oneblock"
        self.zPosition = 100
        self.anchorPoint = CGPoint(x:0.5, y:0.5+blockOffset/self.size.height)
        
        // set up options
        isUserInteractionEnabled = true
        
        // add block cell nodes
        block1.size = CGSize(width: tileWidth, height: tileWidth)
        block1.position = CGPoint(x:0.0, y:0.0)
        self.addChild(block1)
    }
    
    //MARK:- Helper Functions
    func getBlockColorIndex() -> UInt32 {
        return blockColorIndex
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
        
        isUserInteractionEnabled = false
        let blockPosition = CGPoint(x: positionInScreen!.x,
                                    y: positionInScreen!.y)
        let scaleUp = SKAction.scale(to: 1.0, duration: moveDuration)
        let moveToTarget = SKAction.move(to: blockPosition, duration: moveDuration)
        let wait = SKAction.wait(forDuration: 0.2)
        self.run(SKAction.group([scaleUp, moveToTarget, wait]), completion: {
            // post to delegate
            self.blockDelegate.oneBlockWasSet(sender: self)
        })
    }
    
    // MARK:- Touch Events
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first
        let touchLocation = touch!.location(in: self.parent!)
        
        if self.contains(touchLocation) {
            self.zPosition = 1000
            let targetPosition = CGPoint(x: touchLocation.x, y: touchLocation.y+touchYOffset+blockOffset)
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
            self.position = CGPoint(x: touchLocation.x, y: touchLocation.y+touchYOffset+blockOffset)
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.zPosition = 100
        isMoving = false
        let blockCellPosition = CGPoint(x: block1.position.x*midScaleNum+self.position.x,
                                        y: block1.position.y*midScaleNum+self.position.y)
        self.releasePosition = blockCellPosition
        
        self.blockDelegate.oneBlockWasReleased(sender: self)
    }
    
}

