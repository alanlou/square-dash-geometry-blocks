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

enum TwoBlockTypes {
    // x x
    case Type1
    // x
    // x
    case Type2
    
    static func randomBlockType() -> TwoBlockTypes {
        let randomIndex = Int(arc4random_uniform(2)) + 1
        
        switch randomIndex {
        case 1:
            return .Type1
        case 2:
            return .Type2
        default:
            break
        }
        
        return .Type1 // should not happen
    }
}

class TwoBlockNode: SKSpriteNode {
    
    var blockType: TwoBlockTypes
    
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
    var block1InitialPos: CGPoint!
    var block2InitialPos: CGPoint!
    
    weak var blockDelegate: TwoBlockNodeDelegate!
    
    //MARK:- Initialization
    init(width: CGFloat, color: SKColor, position: CGPoint) {
        
        // set up instance variable
        blockType = TwoBlockTypes.randomBlockType()
        
        tileWidth = width
        blockColor = color
        initialPosition = position
        
        blockOffset = width
        touchYOffset = tileWidth/2 + 20
        
        block1 = BlockCellNode(color: color)
        block2 = BlockCellNode(color: color)
        
        super.init(texture: nil, color: .clear, size: CGSize(width:width*4, height:width*4))
        self.name = "twoblock"
        self.zPosition = 100
        self.anchorPoint = CGPoint(x:0.5, y:0.5+blockOffset/self.size.height)
        
        // set up options
        isUserInteractionEnabled = true
        
        // add block cell nodes
        block1.size = CGSize(width: tileWidth, height: tileWidth)
        block2.size = CGSize(width: tileWidth, height: tileWidth)
        
        switch blockType {
        case .Type1:
            block1.position = CGPoint(x:-tileWidth/2-cellSpacing/2, y:0.0)
            block2.position = CGPoint(x:tileWidth/2+cellSpacing/2, y:0.0)
        case .Type2:
            block1.position = CGPoint(x:0.0, y:tileWidth/2+cellSpacing/2)
            block2.position = CGPoint(x:0.0, y:-tileWidth/2-cellSpacing/2)
        }
        block1InitialPos = block1.position
        block2InitialPos = block2.position
        
        self.addChild(block1)
        self.addChild(block2)
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
            let moveBlock1 = SKAction.move(to: block1InitialPos, duration: moveDuration*2.0)
            let moveBlock2 = SKAction.move(to: block2InitialPos, duration: moveDuration*2.0)
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
                                    y: yPos/2.0)
        let scaleUp = SKAction.scale(to: 1.0, duration: moveDuration)
        let moveBlock1 = SKAction.move(to: block1InitialPos, duration: moveDuration*2.0)
        let moveBlock2 = SKAction.move(to: block2InitialPos, duration: moveDuration*2.0)
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
            self.zPosition = 1000
            let targetPosition = CGPoint(x: touchLocation.x, y: touchLocation.y+touchYOffset+blockOffset)
            let scaleUp = SKAction.scale(to: midScaleNum, duration: moveDuration)
            let moveUp = SKAction.move(to: targetPosition, duration: moveDuration)
            
            // animate cell spacing
            switch blockType {
            case .Type1:
                let moveLeft = SKAction.move(by: CGVector(dx:cellSpacing/2-cellSpacing/(2*midScaleNum)-tileWidth*(1-midScaleNum)/(2*midScaleNum), dy:0.0), duration: moveDuration)
                let moveRight = SKAction.move(by: CGVector(dx:-cellSpacing/2+cellSpacing/(2*midScaleNum)+tileWidth*(1-midScaleNum)/(2*midScaleNum), dy:0.0), duration: moveDuration)
                block1.run(moveLeft)
                block2.run(moveRight)
            case .Type2:
                let moveUp = SKAction.move(by: CGVector(dx:0.0, dy:-cellSpacing/2+cellSpacing/(2*midScaleNum)+tileWidth*(1-midScaleNum)/(2*midScaleNum)), duration: moveDuration)
                let moveDown = SKAction.move(by: CGVector(dx:0.0, dy:cellSpacing/2-cellSpacing/(2*midScaleNum)-tileWidth*(1-midScaleNum)/(2*midScaleNum)), duration: moveDuration)
                block1.run(moveUp)
                block2.run(moveDown)
            }
            
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
