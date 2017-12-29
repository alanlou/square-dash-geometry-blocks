//
//  TwoBlockNode.swift
//  Squares
//
//  Created by Alan Lou on 12/28/17.
//  Copyright © 2017 Rawwr Studios. All rights reserved.
//

import SpriteKit

protocol TwoBlockNodeDelegate: NSObjectProtocol {
    func TwoBlockWasReleased(sender: TwoBlockNode)
    func TwoBlockWasSet(sender: TwoBlockNode)
}

class TwoBlockNode: SKSpriteNode {
    
    let lowScaleNum:CGFloat = 0.6
    let midScaleNum:CGFloat = 0.85
    let moveDuration:TimeInterval = 0.05
    
    let cellSpacing: CGFloat = 3.0
    let tileWidth: CGFloat
    let blockColor: SKColor
    let initialPosition: CGPoint
    let blockOffset: CGFloat
    let touchYOffset: CGFloat
    
    var releasePosition = [CGPoint]()
    var isMoving:Bool = false
    
    var block1: BlockCellNode
    var block2: BlockCellNode
    
    weak var blockDelegate: TwoBlockNodeDelegate!
    
    //MARK:- Initialization
    init(width: CGFloat, color: SKColor, position: CGPoint) {
        
        // set up instance variable
        tileWidth = width
        blockColor = color
        initialPosition = position
        
        blockOffset = width
        touchYOffset = tileWidth/2 + 20
        
        block1 = BlockCellNode(color: color)
        block2 = BlockCellNode(color: color)
        super.init(texture: nil, color: .clear, size: CGSize(width:width*3, height:width*3))
        self.name = "twoblock"
        
        // set up options
        isUserInteractionEnabled = true
        
        // add block cell nodes
        block1.size = CGSize(width: tileWidth, height: tileWidth)
        block1.position = CGPoint(x:-tileWidth/2-cellSpacing/2, y:blockOffset)
        self.addChild(block1)
        block2.size = CGSize(width: tileWidth, height: tileWidth)
        block2.position = CGPoint(x:tileWidth/2+cellSpacing/2, y:blockOffset)
        self.addChild(block2)
        
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
    
    func getNodeReleasePositions() -> Array<CGPoint> {
        return releasePosition
    }
    
    func setNodeAt(positionsInScreen:  Array<CGPoint>?) {
        // block not set at a valid position. move back to original position
        if positionsInScreen == nil{
            let scaleDown = SKAction.scale(to: lowScaleNum, duration: moveDuration*2.0)
            let moveBack = SKAction.move(to: initialPosition, duration: moveDuration*2.0)
            
            // animate cell spacing
            let moveBlock1 = SKAction.move(to: CGPoint(x:-tileWidth/2-cellSpacing/2, y:blockOffset), duration: moveDuration*2.0)
            let moveBlock2 = SKAction.move(to: CGPoint(x:tileWidth/2+cellSpacing/2, y:blockOffset), duration: moveDuration*2.0)
            block1.run(moveBlock1)
            block2.run(moveBlock2)
            self.run(SKAction.group([scaleDown, moveBack]))
            return
        }
        
        isUserInteractionEnabled = false
        
        var xPos: CGFloat = CGFloat(0.0)
        var yPos: CGFloat = CGFloat(0.0)
        for positionInScreen in positionsInScreen! {
            xPos = xPos + positionInScreen.x
            yPos = yPos + positionInScreen.y
        }
        
        
        let blockPosition = CGPoint(x: xPos/2.0,
                                    y: yPos/2.0-blockOffset)
        let scaleUp = SKAction.scale(to: 1.0, duration: moveDuration)
        let moveBlock1 = SKAction.move(to: CGPoint(x:-tileWidth/2-cellSpacing/2, y:blockOffset), duration: moveDuration*2.0)
        let moveBlock2 = SKAction.move(to: CGPoint(x:tileWidth/2+cellSpacing/2, y:blockOffset), duration: moveDuration*2.0)
        let moveToTarget = SKAction.move(to: blockPosition, duration: moveDuration)
        let wait = SKAction.wait(forDuration: 0.2)
        
        block1.run(moveBlock1)
        block2.run(moveBlock2)
        
        self.run(SKAction.group([moveToTarget, scaleUp, wait]), completion: {
            // post to delegate
            self.blockDelegate.TwoBlockWasSet(sender: self)
        })
        
    }
    
    // MARK:- Touch Events
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first
        let touchLocation = touch!.location(in: self.parent!)
        
        if self.contains(touchLocation) {
            let targetPosition = CGPoint(x: touchLocation.x, y: touchLocation.y+touchYOffset)
            let scaleUp = SKAction.scale(to: midScaleNum, duration: moveDuration)
            let moveUp = SKAction.move(to: targetPosition, duration: moveDuration)
            
            // animate cell spacing
            let moveLeft = SKAction.move(by: CGVector(dx:cellSpacing/2-cellSpacing/(2*midScaleNum)-tileWidth*(1-midScaleNum)/(2*midScaleNum), dy:0), duration: moveDuration)
            let moveRight = SKAction.move(by: CGVector(dx:-cellSpacing/2+cellSpacing/(2*midScaleNum)+tileWidth*(1-midScaleNum)/(2*midScaleNum), dy:0), duration: moveDuration)
            block1.run(moveLeft)
            block2.run(moveRight)
            
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
        
        // set release position of the block nodes
        releasePosition.removeAll()
        for child in self.children {
            if let blockCellNode = child as? BlockCellNode {
                let blockCellPosition = CGPoint(x: blockCellNode.position.x*midScaleNum+self.position.x,
                                                y: blockCellNode.position.y*midScaleNum+self.position.y)
                releasePosition.append(blockCellPosition)
            }
        }
        
        self.blockDelegate.TwoBlockWasReleased(sender: self)
    }
    
}
