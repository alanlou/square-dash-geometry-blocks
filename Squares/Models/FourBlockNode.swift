//
//  FourBlockNode.swift
//  Squares
//
//  Created by Alan Lou on 12/29/17.
//  Copyright © 2017 Rawwr Studios. All rights reserved.
//

import SpriteKit

protocol FourBlockNodeDelegate: NSObjectProtocol {
    func FourBlockWasReleased(sender: FourBlockNode)
    func FourBlockWasSet(sender: FourBlockNode)
}

enum FourBlockTypes: Int {
    // x x
    // x x
    case Type1 = 0
    // x
    // x x x
    case Type2
    // x x
    // x
    // x
    case Type3
    // x x x
    //     x
    case Type4
    //   x
    //   x
    // x x
    case Type5
    //     x
    // x x x
    case Type6
    // x
    // x
    // x x
    case Type7
    // x x x
    // x
    case Type8
    // x x
    //   x
    //   x
    case Type9
    //   x
    // x x x
    case Type10
    // x
    // x x
    // x
    case Type11
    // x x x
    //   x
    case Type12
    //   x
    // x x
    //   x
    case Type13
    
    static func randomBlockType() -> FourBlockTypes {
        let randomIndex = Int(arc4random_uniform(13)) + 1
        
        switch randomIndex {
        case 1:
            return .Type1
        case 2:
            return .Type2
        case 3:
            return .Type3
        case 4:
            return .Type4
        case 5:
            return .Type5
        case 6:
            return .Type6
        case 7:
            return .Type7
        case 8:
            return .Type8
        case 9:
            return .Type9
        case 10:
            return .Type10
        case 11:
            return .Type11
        case 12:
            return .Type12
        case 13:
            return .Type13
        default:
            break
        }
        
        return .Type1 // should not happen
    }
}

class FourBlockNode: SKSpriteNode {
    
    var blockType: FourBlockTypes
    
    let lowScaleNum:CGFloat = 0.6
    let midScaleNum:CGFloat = 0.85
    let moveDuration:TimeInterval = 0.05
    
    let cellSpacing: CGFloat = 3.0
    let tileWidth: CGFloat
    let blockColorIndex: UInt32
    let bottomIndex: UInt32
    let initialPosition: CGPoint
    let blockOffset: CGFloat
    let touchYOffset: CGFloat
    
    var releasePosition = [CGPoint]()
    var isMoving:Bool = false
    
    var block1: BlockCellNode
    var block2: BlockCellNode
    var block3: BlockCellNode
    var block4: BlockCellNode
    var block1InitialPos: CGPoint!
    var block2InitialPos: CGPoint!
    var block3InitialPos: CGPoint!
    var block4InitialPos: CGPoint!
    
    weak var blockDelegate: FourBlockNodeDelegate!
    
    //MARK:- Initialization
    init(width: CGFloat, colorIndex: UInt32, position: CGPoint, bottomIndex: UInt32) {
        
        // set up instance variable
        blockType = FourBlockTypes.randomBlockType()
        
        tileWidth = width
        initialPosition = position
        
        blockOffset = width
        touchYOffset = tileWidth/2 + 25
        
        block1 = BlockCellNode(colorIndex: colorIndex)
        block2 = BlockCellNode(colorIndex: colorIndex)
        block3 = BlockCellNode(colorIndex: colorIndex)
        block4 = BlockCellNode(colorIndex: colorIndex)
        blockColorIndex = colorIndex
        self.bottomIndex = bottomIndex
        
        super.init(texture: nil, color: .clear, size: CGSize(width:width*4, height:width*4))
        self.name = "fourblock"
        self.zPosition = 100
        self.anchorPoint = CGPoint(x:0.5, y:0.5+blockOffset/self.size.height)
        
        // set up options
        isUserInteractionEnabled = true
        
        // add block cell nodes
        block1.size = CGSize(width: tileWidth, height: tileWidth)
        block2.size = CGSize(width: tileWidth, height: tileWidth)
        block3.size = CGSize(width: tileWidth, height: tileWidth)
        block4.size = CGSize(width: tileWidth, height: tileWidth)
        
        switch blockType {
        // x x
        // x x
        case .Type1:
            block1.position = CGPoint(x:-tileWidth/2-cellSpacing/2, y:tileWidth/2+cellSpacing/2)
            block2.position = CGPoint(x:tileWidth/2+cellSpacing/2, y:tileWidth/2+cellSpacing/2)
            block3.position = CGPoint(x:-tileWidth/2-cellSpacing/2, y:-tileWidth/2-cellSpacing/2)
            block4.position = CGPoint(x:tileWidth/2+cellSpacing/2, y:-tileWidth/2-cellSpacing/2)
        // x
        // x x x
        case .Type2:
            block1.position = CGPoint(x:-tileWidth-cellSpacing, y:tileWidth/2+cellSpacing/2)
            block2.position = CGPoint(x:-tileWidth-cellSpacing, y:-tileWidth/2-cellSpacing/2)
            block3.position = CGPoint(x:0.0, y:-tileWidth/2-cellSpacing/2)
            block4.position = CGPoint(x:tileWidth+cellSpacing, y:-tileWidth/2-cellSpacing/2)
        // x x
        // x
        // x
        case .Type3:
            block1.position = CGPoint(x:-tileWidth/2-cellSpacing/2, y:tileWidth+cellSpacing)
            block2.position = CGPoint(x:tileWidth/2+cellSpacing/2, y:tileWidth+cellSpacing)
            block3.position = CGPoint(x:-tileWidth/2-cellSpacing/2, y:0.0)
            block4.position = CGPoint(x:-tileWidth/2-cellSpacing/2, y:-tileWidth-cellSpacing)
        // x x x
        //     x
        case .Type4:
            block1.position = CGPoint(x:-tileWidth-cellSpacing, y:tileWidth/2+cellSpacing/2)
            block2.position = CGPoint(x:0.0, y:tileWidth/2+cellSpacing/2)
            block3.position = CGPoint(x:tileWidth+cellSpacing, y:tileWidth/2+cellSpacing/2)
            block4.position = CGPoint(x:tileWidth+cellSpacing, y:-tileWidth/2-cellSpacing/2)
        //   x
        //   x
        // x x
        case .Type5:
            block1.position = CGPoint(x:tileWidth/2+cellSpacing/2, y:tileWidth+cellSpacing)
            block2.position = CGPoint(x:tileWidth/2+cellSpacing/2, y:0.0)
            block3.position = CGPoint(x:-tileWidth/2-cellSpacing/2, y:-tileWidth-cellSpacing)
            block4.position = CGPoint(x:tileWidth/2+cellSpacing/2, y:-tileWidth-cellSpacing)
        //     x
        // x x x
        case .Type6:
            block1.position = CGPoint(x:tileWidth+cellSpacing, y:tileWidth/2+cellSpacing/2)
            block2.position = CGPoint(x:-tileWidth-cellSpacing, y:-tileWidth/2-cellSpacing/2)
            block3.position = CGPoint(x:0.0, y:-tileWidth/2-cellSpacing/2)
            block4.position = CGPoint(x:tileWidth+cellSpacing, y:-tileWidth/2-cellSpacing/2)
        // x
        // x
        // x x
        case .Type7:
            block1.position = CGPoint(x:-tileWidth/2-cellSpacing/2, y:tileWidth+cellSpacing)
            block2.position = CGPoint(x:-tileWidth/2-cellSpacing/2, y:0.0)
            block3.position = CGPoint(x:-tileWidth/2-cellSpacing/2, y:-tileWidth-cellSpacing)
            block4.position = CGPoint(x:tileWidth/2+cellSpacing/2, y:-tileWidth-cellSpacing)
        // x x x
        // x
        case .Type8:
            block1.position = CGPoint(x:-tileWidth-cellSpacing, y:tileWidth/2+cellSpacing/2)
            block2.position = CGPoint(x:0.0, y:tileWidth/2+cellSpacing/2)
            block3.position = CGPoint(x:tileWidth+cellSpacing, y:tileWidth/2+cellSpacing/2)
            block4.position = CGPoint(x:-tileWidth-cellSpacing, y:-tileWidth/2-cellSpacing/2)
        // x x
        //   x
        //   x
        case .Type9:
            block1.position = CGPoint(x:-tileWidth/2-cellSpacing/2, y:tileWidth+cellSpacing)
            block2.position = CGPoint(x:tileWidth/2+cellSpacing/2, y:tileWidth+cellSpacing)
            block3.position = CGPoint(x:tileWidth/2+cellSpacing/2, y:0.0)
            block4.position = CGPoint(x:tileWidth/2+cellSpacing/2, y:-tileWidth-cellSpacing)
        //   x
        // x x x
        case .Type10:
            block1.position = CGPoint(x:0.0, y:tileWidth/2+cellSpacing/2)
            block2.position = CGPoint(x:-tileWidth-cellSpacing, y:-tileWidth/2-cellSpacing/2)
            block3.position = CGPoint(x:0.0, y:-tileWidth/2-cellSpacing/2)
            block4.position = CGPoint(x:tileWidth+cellSpacing, y:-tileWidth/2-cellSpacing/2)
        // x
        // x x
        // x
        case .Type11:
            block1.position = CGPoint(x:-tileWidth/2-cellSpacing/2, y:tileWidth+cellSpacing)
            block2.position = CGPoint(x:-tileWidth/2-cellSpacing/2, y:0.0)
            block3.position = CGPoint(x:tileWidth/2+cellSpacing/2, y:0.0)
            block4.position = CGPoint(x:-tileWidth/2-cellSpacing/2, y:-tileWidth-cellSpacing)
        // x x x
        //   x
        case .Type12:
            block1.position = CGPoint(x:-tileWidth-cellSpacing, y:tileWidth/2+cellSpacing/2)
            block2.position = CGPoint(x:0.0, y:tileWidth/2+cellSpacing/2)
            block3.position = CGPoint(x:tileWidth+cellSpacing, y:tileWidth/2+cellSpacing/2)
            block4.position = CGPoint(x:0.0, y:-tileWidth/2-cellSpacing/2)
        //   x
        // x x
        //   x
        case .Type13:
            block1.position = CGPoint(x:tileWidth/2+cellSpacing/2, y:tileWidth+cellSpacing)
            block2.position = CGPoint(x:-tileWidth/2-cellSpacing/2, y:0.0)
            block3.position = CGPoint(x:tileWidth/2+cellSpacing/2, y:0.0)
            block4.position = CGPoint(x:tileWidth/2+cellSpacing/2, y:-tileWidth-cellSpacing)
        }
        
        block1InitialPos = block1.position
        block2InitialPos = block2.position
        block3InitialPos = block3.position
        block4InitialPos = block4.position
        
        self.addChild(block1)
        self.addChild(block2)
        self.addChild(block3)
        self.addChild(block4)
    }
    
    override func encode(with coder: NSCoder) {
        coder.encode(self.tileWidth, forKey: "width")
        coder.encode(self.blockColorIndex, forKey: "colorIndex")
        coder.encode(self.initialPosition, forKey: "position")
        coder.encode(self.blockType.rawValue, forKey:"blockType")
        coder.encode(self.bottomIndex, forKey: "bottomIndex")
    }
    
    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        let width = aDecoder.decodeObject(forKey: "width") as! CGFloat
        let colorIndex = aDecoder.decodeObject(forKey: "colorIndex") as! UInt32
        let position = aDecoder.decodeCGPoint(forKey: "position")
        let savedBlockType = FourBlockTypes(rawValue: aDecoder.decodeInteger(forKey:"blockType"))
        let bottomIndex = aDecoder.decodeObject(forKey: "bottomIndex") as! UInt32
        
        // set up instance variable
        blockType = savedBlockType!
        
        tileWidth = width
        initialPosition = position
        
        blockOffset = width
        touchYOffset = tileWidth/2 + 25
        
        block1 = BlockCellNode(colorIndex: colorIndex)
        block2 = BlockCellNode(colorIndex: colorIndex)
        block3 = BlockCellNode(colorIndex: colorIndex)
        block4 = BlockCellNode(colorIndex: colorIndex)
        blockColorIndex = colorIndex
        self.bottomIndex = bottomIndex
        
        super.init(texture: nil, color: .clear, size: CGSize(width:width*4, height:width*4))
        
        self.name = "fourblock"
        self.zPosition = 100
        self.anchorPoint = CGPoint(x:0.5, y:0.5+blockOffset/self.size.height)
        
        // set up options
        isUserInteractionEnabled = true
        
        // add block cell nodes
        block1.size = CGSize(width: tileWidth, height: tileWidth)
        block2.size = CGSize(width: tileWidth, height: tileWidth)
        block3.size = CGSize(width: tileWidth, height: tileWidth)
        block4.size = CGSize(width: tileWidth, height: tileWidth)
        
        switch blockType {
            // x x
        // x x
        case .Type1:
            block1.position = CGPoint(x:-tileWidth/2-cellSpacing/2, y:tileWidth/2+cellSpacing/2)
            block2.position = CGPoint(x:tileWidth/2+cellSpacing/2, y:tileWidth/2+cellSpacing/2)
            block3.position = CGPoint(x:-tileWidth/2-cellSpacing/2, y:-tileWidth/2-cellSpacing/2)
            block4.position = CGPoint(x:tileWidth/2+cellSpacing/2, y:-tileWidth/2-cellSpacing/2)
            // x
        // x x x
        case .Type2:
            block1.position = CGPoint(x:-tileWidth-cellSpacing, y:tileWidth/2+cellSpacing/2)
            block2.position = CGPoint(x:-tileWidth-cellSpacing, y:-tileWidth/2-cellSpacing/2)
            block3.position = CGPoint(x:0.0, y:-tileWidth/2-cellSpacing/2)
            block4.position = CGPoint(x:tileWidth+cellSpacing, y:-tileWidth/2-cellSpacing/2)
            // x x
            // x
        // x
        case .Type3:
            block1.position = CGPoint(x:-tileWidth/2-cellSpacing/2, y:tileWidth+cellSpacing)
            block2.position = CGPoint(x:tileWidth/2+cellSpacing/2, y:tileWidth+cellSpacing)
            block3.position = CGPoint(x:-tileWidth/2-cellSpacing/2, y:0.0)
            block4.position = CGPoint(x:-tileWidth/2-cellSpacing/2, y:-tileWidth-cellSpacing)
            // x x x
        //     x
        case .Type4:
            block1.position = CGPoint(x:-tileWidth-cellSpacing, y:tileWidth/2+cellSpacing/2)
            block2.position = CGPoint(x:0.0, y:tileWidth/2+cellSpacing/2)
            block3.position = CGPoint(x:tileWidth+cellSpacing, y:tileWidth/2+cellSpacing/2)
            block4.position = CGPoint(x:tileWidth+cellSpacing, y:-tileWidth/2-cellSpacing/2)
            //   x
            //   x
        // x x
        case .Type5:
            block1.position = CGPoint(x:tileWidth/2+cellSpacing/2, y:tileWidth+cellSpacing)
            block2.position = CGPoint(x:tileWidth/2+cellSpacing/2, y:0.0)
            block3.position = CGPoint(x:-tileWidth/2-cellSpacing/2, y:-tileWidth-cellSpacing)
            block4.position = CGPoint(x:tileWidth/2+cellSpacing/2, y:-tileWidth-cellSpacing)
            //     x
        // x x x
        case .Type6:
            block1.position = CGPoint(x:tileWidth+cellSpacing, y:tileWidth/2+cellSpacing/2)
            block2.position = CGPoint(x:-tileWidth-cellSpacing, y:-tileWidth/2-cellSpacing/2)
            block3.position = CGPoint(x:0.0, y:-tileWidth/2-cellSpacing/2)
            block4.position = CGPoint(x:tileWidth+cellSpacing, y:-tileWidth/2-cellSpacing/2)
            // x
            // x
        // x x
        case .Type7:
            block1.position = CGPoint(x:-tileWidth/2-cellSpacing/2, y:tileWidth+cellSpacing)
            block2.position = CGPoint(x:-tileWidth/2-cellSpacing/2, y:0.0)
            block3.position = CGPoint(x:-tileWidth/2-cellSpacing/2, y:-tileWidth-cellSpacing)
            block4.position = CGPoint(x:tileWidth/2+cellSpacing/2, y:-tileWidth-cellSpacing)
            // x x x
        // x
        case .Type8:
            block1.position = CGPoint(x:-tileWidth-cellSpacing, y:tileWidth/2+cellSpacing/2)
            block2.position = CGPoint(x:0.0, y:tileWidth/2+cellSpacing/2)
            block3.position = CGPoint(x:tileWidth+cellSpacing, y:tileWidth/2+cellSpacing/2)
            block4.position = CGPoint(x:-tileWidth-cellSpacing, y:-tileWidth/2-cellSpacing/2)
            // x x
            //   x
        //   x
        case .Type9:
            block1.position = CGPoint(x:-tileWidth/2-cellSpacing/2, y:tileWidth+cellSpacing)
            block2.position = CGPoint(x:tileWidth/2+cellSpacing/2, y:tileWidth+cellSpacing)
            block3.position = CGPoint(x:tileWidth/2+cellSpacing/2, y:0.0)
            block4.position = CGPoint(x:tileWidth/2+cellSpacing/2, y:-tileWidth-cellSpacing)
            //   x
        // x x x
        case .Type10:
            block1.position = CGPoint(x:0.0, y:tileWidth/2+cellSpacing/2)
            block2.position = CGPoint(x:-tileWidth-cellSpacing, y:-tileWidth/2-cellSpacing/2)
            block3.position = CGPoint(x:0.0, y:-tileWidth/2-cellSpacing/2)
            block4.position = CGPoint(x:tileWidth+cellSpacing, y:-tileWidth/2-cellSpacing/2)
            // x
            // x x
        // x
        case .Type11:
            block1.position = CGPoint(x:-tileWidth/2-cellSpacing/2, y:tileWidth+cellSpacing)
            block2.position = CGPoint(x:-tileWidth/2-cellSpacing/2, y:0.0)
            block3.position = CGPoint(x:tileWidth/2+cellSpacing/2, y:0.0)
            block4.position = CGPoint(x:-tileWidth/2-cellSpacing/2, y:-tileWidth-cellSpacing)
            // x x x
        //   x
        case .Type12:
            block1.position = CGPoint(x:-tileWidth-cellSpacing, y:tileWidth/2+cellSpacing/2)
            block2.position = CGPoint(x:0.0, y:tileWidth/2+cellSpacing/2)
            block3.position = CGPoint(x:tileWidth+cellSpacing, y:tileWidth/2+cellSpacing/2)
            block4.position = CGPoint(x:0.0, y:-tileWidth/2-cellSpacing/2)
            //   x
            // x x
        //   x
        case .Type13:
            block1.position = CGPoint(x:tileWidth/2+cellSpacing/2, y:tileWidth+cellSpacing)
            block2.position = CGPoint(x:-tileWidth/2-cellSpacing/2, y:0.0)
            block3.position = CGPoint(x:tileWidth/2+cellSpacing/2, y:0.0)
            block4.position = CGPoint(x:tileWidth/2+cellSpacing/2, y:-tileWidth-cellSpacing)
        }
        
        block1InitialPos = block1.position
        block2InitialPos = block2.position
        block3InitialPos = block3.position
        block4InitialPos = block4.position
        
        self.addChild(block1)
        self.addChild(block2)
        self.addChild(block3)
        self.addChild(block4)
    }
    
    //MARK:- Helper Functions
    func getBlockColorIndex() -> UInt32 {
        return blockColorIndex
    }
    
    func getBlockPosition() -> CGPoint {
        return initialPosition
    }
    
    func getBlockType() -> FourBlockTypes {
        return blockType
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
            let moveBlock3 = SKAction.move(to: block3InitialPos, duration: moveDuration*2.0)
            let moveBlock4 = SKAction.move(to: block4InitialPos, duration: moveDuration*2.0)
            block1.run(moveBlock1)
            block2.run(moveBlock2)
            block3.run(moveBlock3)
            block4.run(moveBlock4)
            self.run(SKAction.group([scaleDown, moveBack]))
            return
        }
        
        isUserInteractionEnabled = false
        
        let blockPosition: CGPoint
        switch blockType {
        case .Type1:
            var xPosSet =  Set<CGFloat>()
            var yPosSet =  Set<CGFloat>()
            for positionInScreen in positionsInScreen! {
                xPosSet.insert(positionInScreen.x)
                yPosSet.insert(positionInScreen.y)
            }
            blockPosition = CGPoint(x: xPosSet.reduce(0, +)/2.0,
                                    y: yPosSet.reduce(0, +)/2.0)
        case .Type2, .Type4, .Type6, .Type8, .Type10, .Type12:
            var xPosSet =  Set<CGFloat>()
            var yPosSet =  Set<CGFloat>()
            for positionInScreen in positionsInScreen! {
                xPosSet.insert(positionInScreen.x)
                yPosSet.insert(positionInScreen.y)
            }
            blockPosition = CGPoint(x: xPosSet.reduce(0, +)/3.0,
                                    y: yPosSet.reduce(0, +)/2.0)
        case .Type3, .Type5, .Type7, .Type9, .Type11, .Type13:
            var xPosSet =  Set<CGFloat>()
            var yPosSet =  Set<CGFloat>()
            for positionInScreen in positionsInScreen! {
                xPosSet.insert(positionInScreen.x)
                yPosSet.insert(positionInScreen.y)
            }
            blockPosition = CGPoint(x: xPosSet.reduce(0, +)/2.0,
                                    y: yPosSet.reduce(0, +)/3.0)
        }
        let scaleUp = SKAction.scale(to: 1.0, duration: moveDuration)
        let moveBlock1 = SKAction.move(to: block1InitialPos, duration: moveDuration*2.0)
        let moveBlock2 = SKAction.move(to: block2InitialPos, duration: moveDuration*2.0)
        let moveBlock3 = SKAction.move(to: block3InitialPos, duration: moveDuration*2.0)
        let moveBlock4 = SKAction.move(to: block4InitialPos, duration: moveDuration*2.0)
        let moveToTarget = SKAction.move(to: blockPosition, duration: moveDuration)
        let wait = SKAction.wait(forDuration: 0.2)
        
        block1.run(moveBlock1)
        block2.run(moveBlock2)
        block3.run(moveBlock3)
        block4.run(moveBlock4)
        
        self.run(SKAction.group([moveToTarget, scaleUp, wait]), completion: {
            // post to delegate
            self.blockDelegate.FourBlockWasSet(sender: self)
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
            // x x
            // x x
            case .Type1:
                let moveLeft = SKAction.move(by: CGVector(dx:cellSpacing/2-cellSpacing/(2*midScaleNum)-tileWidth*(1-midScaleNum)/(2*midScaleNum), dy:0.0), duration: moveDuration)
                let moveRight = SKAction.move(by: CGVector(dx:-cellSpacing/2+cellSpacing/(2*midScaleNum)+tileWidth*(1-midScaleNum)/(2*midScaleNum), dy:0.0), duration: moveDuration)
                let moveUp = SKAction.move(by: CGVector(dx:0.0, dy:-cellSpacing/2+cellSpacing/(2*midScaleNum)+tileWidth*(1-midScaleNum)/(2*midScaleNum)), duration: moveDuration)
                let moveDown = SKAction.move(by: CGVector(dx:0.0, dy:cellSpacing/2-cellSpacing/(2*midScaleNum)-tileWidth*(1-midScaleNum)/(2*midScaleNum)), duration: moveDuration)
                block1.run(SKAction.group([moveLeft, moveUp]))
                block2.run(SKAction.group([moveRight, moveUp]))
                block3.run(SKAction.group([moveLeft, moveDown]))
                block4.run(SKAction.group([moveRight, moveDown]))
            // x
            // x x x
            case .Type2:
                let moveLeft = SKAction.move(by: CGVector(dx:cellSpacing-cellSpacing/(midScaleNum)-tileWidth*(1-midScaleNum)/(midScaleNum), dy:0.0), duration: moveDuration)
                let moveRight = SKAction.move(by: CGVector(dx:-cellSpacing+cellSpacing/(midScaleNum)+tileWidth*(1-midScaleNum)/(midScaleNum), dy:0.0), duration: moveDuration)
                let moveUp = SKAction.move(by: CGVector(dx:0.0, dy:-cellSpacing/2+cellSpacing/(2*midScaleNum)+tileWidth*(1-midScaleNum)/(2*midScaleNum)), duration: moveDuration)
                let moveDown = SKAction.move(by: CGVector(dx:0.0, dy:cellSpacing/2-cellSpacing/(2*midScaleNum)-tileWidth*(1-midScaleNum)/(2*midScaleNum)), duration: moveDuration)
                block1.run(SKAction.group([moveLeft, moveUp]))
                block2.run(SKAction.group([moveLeft, moveDown]))
                block3.run(moveDown)
                block4.run(SKAction.group([moveRight, moveDown]))
            // x x
            // x
            // x
            case .Type3:
                let moveLeft = SKAction.move(by: CGVector(dx:cellSpacing/2-cellSpacing/(2*midScaleNum)-tileWidth*(1-midScaleNum)/(2*midScaleNum), dy:0.0), duration: moveDuration)
                let moveRight = SKAction.move(by: CGVector(dx:-cellSpacing/2+cellSpacing/(2*midScaleNum)+tileWidth*(1-midScaleNum)/(2*midScaleNum), dy:0.0), duration: moveDuration)
                let moveUp = SKAction.move(by: CGVector(dx:0.0, dy:-cellSpacing+cellSpacing/(midScaleNum)+tileWidth*(1-midScaleNum)/(midScaleNum)), duration: moveDuration)
                let moveDown = SKAction.move(by: CGVector(dx:0.0, dy:cellSpacing-cellSpacing/(midScaleNum)-tileWidth*(1-midScaleNum)/(midScaleNum)), duration: moveDuration)
                block1.run(SKAction.group([moveLeft, moveUp]))
                block2.run(SKAction.group([moveRight, moveUp]))
                block3.run(moveLeft)
                block4.run(SKAction.group([moveLeft, moveDown]))
            // x x x
            //     x
            case .Type4:
                let moveLeft = SKAction.move(by: CGVector(dx:cellSpacing-cellSpacing/(midScaleNum)-tileWidth*(1-midScaleNum)/(midScaleNum), dy:0.0), duration: moveDuration)
                let moveRight = SKAction.move(by: CGVector(dx:-cellSpacing+cellSpacing/(midScaleNum)+tileWidth*(1-midScaleNum)/(midScaleNum), dy:0.0), duration: moveDuration)
                let moveUp = SKAction.move(by: CGVector(dx:0.0, dy:-cellSpacing/2+cellSpacing/(2*midScaleNum)+tileWidth*(1-midScaleNum)/(2*midScaleNum)), duration: moveDuration)
                let moveDown = SKAction.move(by: CGVector(dx:0.0, dy:cellSpacing/2-cellSpacing/(2*midScaleNum)-tileWidth*(1-midScaleNum)/(2*midScaleNum)), duration: moveDuration)
                block1.run(SKAction.group([moveLeft, moveUp]))
                block2.run(moveUp)
                block3.run(SKAction.group([moveRight, moveUp]))
                block4.run(SKAction.group([moveRight, moveDown]))
            //   x
            //   x
            // x x
            case .Type5:
                let moveLeft = SKAction.move(by: CGVector(dx:cellSpacing/2-cellSpacing/(2*midScaleNum)-tileWidth*(1-midScaleNum)/(2*midScaleNum), dy:0.0), duration: moveDuration)
                let moveRight = SKAction.move(by: CGVector(dx:-cellSpacing/2+cellSpacing/(2*midScaleNum)+tileWidth*(1-midScaleNum)/(2*midScaleNum), dy:0.0), duration: moveDuration)
                let moveUp = SKAction.move(by: CGVector(dx:0.0, dy:-cellSpacing+cellSpacing/(midScaleNum)+tileWidth*(1-midScaleNum)/(midScaleNum)), duration: moveDuration)
                let moveDown = SKAction.move(by: CGVector(dx:0.0, dy:cellSpacing-cellSpacing/(midScaleNum)-tileWidth*(1-midScaleNum)/(midScaleNum)), duration: moveDuration)
                block1.run(SKAction.group([moveRight, moveUp]))
                block2.run(moveRight)
                block3.run(SKAction.group([moveLeft, moveDown]))
                block4.run(SKAction.group([moveRight, moveDown]))
            //     x
            // x x x
            case .Type6:
                let moveLeft = SKAction.move(by: CGVector(dx:cellSpacing-cellSpacing/(midScaleNum)-tileWidth*(1-midScaleNum)/(midScaleNum), dy:0.0), duration: moveDuration)
                let moveRight = SKAction.move(by: CGVector(dx:-cellSpacing+cellSpacing/(midScaleNum)+tileWidth*(1-midScaleNum)/(midScaleNum), dy:0.0), duration: moveDuration)
                let moveUp = SKAction.move(by: CGVector(dx:0.0, dy:-cellSpacing/2+cellSpacing/(2*midScaleNum)+tileWidth*(1-midScaleNum)/(2*midScaleNum)), duration: moveDuration)
                let moveDown = SKAction.move(by: CGVector(dx:0.0, dy:cellSpacing/2-cellSpacing/(2*midScaleNum)-tileWidth*(1-midScaleNum)/(2*midScaleNum)), duration: moveDuration)
                block1.run(SKAction.group([moveRight, moveUp]))
                block2.run(SKAction.group([moveLeft, moveDown]))
                block3.run(moveDown)
                block4.run(SKAction.group([moveRight, moveDown]))
            // x
            // x
            // x x
            case .Type7:
                let moveLeft = SKAction.move(by: CGVector(dx:cellSpacing/2-cellSpacing/(2*midScaleNum)-tileWidth*(1-midScaleNum)/(2*midScaleNum), dy:0.0), duration: moveDuration)
                let moveRight = SKAction.move(by: CGVector(dx:-cellSpacing/2+cellSpacing/(2*midScaleNum)+tileWidth*(1-midScaleNum)/(2*midScaleNum), dy:0.0), duration: moveDuration)
                let moveUp = SKAction.move(by: CGVector(dx:0.0, dy:-cellSpacing+cellSpacing/(midScaleNum)+tileWidth*(1-midScaleNum)/(midScaleNum)), duration: moveDuration)
                let moveDown = SKAction.move(by: CGVector(dx:0.0, dy:cellSpacing-cellSpacing/(midScaleNum)-tileWidth*(1-midScaleNum)/(midScaleNum)), duration: moveDuration)
                block1.run(SKAction.group([moveLeft, moveUp]))
                block2.run(moveLeft)
                block3.run(SKAction.group([moveLeft, moveDown]))
                block4.run(SKAction.group([moveRight, moveDown]))
            // x x x
            // x
            case .Type8:
                let moveLeft = SKAction.move(by: CGVector(dx:cellSpacing-cellSpacing/(midScaleNum)-tileWidth*(1-midScaleNum)/(midScaleNum), dy:0.0), duration: moveDuration)
                let moveRight = SKAction.move(by: CGVector(dx:-cellSpacing+cellSpacing/(midScaleNum)+tileWidth*(1-midScaleNum)/(midScaleNum), dy:0.0), duration: moveDuration)
                let moveUp = SKAction.move(by: CGVector(dx:0.0, dy:-cellSpacing/2+cellSpacing/(2*midScaleNum)+tileWidth*(1-midScaleNum)/(2*midScaleNum)), duration: moveDuration)
                let moveDown = SKAction.move(by: CGVector(dx:0.0, dy:cellSpacing/2-cellSpacing/(2*midScaleNum)-tileWidth*(1-midScaleNum)/(2*midScaleNum)), duration: moveDuration)
                block1.run(SKAction.group([moveLeft, moveUp]))
                block2.run(moveUp)
                block3.run(SKAction.group([moveRight, moveUp]))
                block4.run(SKAction.group([moveLeft, moveDown]))
            // x x
            //   x
            //   x
            case .Type9:
                let moveLeft = SKAction.move(by: CGVector(dx:cellSpacing/2-cellSpacing/(2*midScaleNum)-tileWidth*(1-midScaleNum)/(2*midScaleNum), dy:0.0), duration: moveDuration)
                let moveRight = SKAction.move(by: CGVector(dx:-cellSpacing/2+cellSpacing/(2*midScaleNum)+tileWidth*(1-midScaleNum)/(2*midScaleNum), dy:0.0), duration: moveDuration)
                let moveUp = SKAction.move(by: CGVector(dx:0.0, dy:-cellSpacing+cellSpacing/(midScaleNum)+tileWidth*(1-midScaleNum)/(midScaleNum)), duration: moveDuration)
                let moveDown = SKAction.move(by: CGVector(dx:0.0, dy:cellSpacing-cellSpacing/(midScaleNum)-tileWidth*(1-midScaleNum)/(midScaleNum)), duration: moveDuration)
                block1.run(SKAction.group([moveLeft, moveUp]))
                block2.run(SKAction.group([moveRight, moveUp]))
                block3.run(moveRight)
                block4.run(SKAction.group([moveRight, moveDown]))
            //   x
            // x x x
            case .Type10:
                let moveLeft = SKAction.move(by: CGVector(dx:cellSpacing-cellSpacing/(midScaleNum)-tileWidth*(1-midScaleNum)/(midScaleNum), dy:0.0), duration: moveDuration)
                let moveRight = SKAction.move(by: CGVector(dx:-cellSpacing+cellSpacing/(midScaleNum)+tileWidth*(1-midScaleNum)/(midScaleNum), dy:0.0), duration: moveDuration)
                let moveUp = SKAction.move(by: CGVector(dx:0.0, dy:-cellSpacing/2+cellSpacing/(2*midScaleNum)+tileWidth*(1-midScaleNum)/(2*midScaleNum)), duration: moveDuration)
                let moveDown = SKAction.move(by: CGVector(dx:0.0, dy:cellSpacing/2-cellSpacing/(2*midScaleNum)-tileWidth*(1-midScaleNum)/(2*midScaleNum)), duration: moveDuration)
                block1.run(moveUp)
                block2.run(SKAction.group([moveLeft, moveDown]))
                block3.run(moveDown)
                block4.run(SKAction.group([moveRight, moveDown]))
            // x
            // x x
            // x
            case .Type11:
                let moveLeft = SKAction.move(by: CGVector(dx:cellSpacing/2-cellSpacing/(2*midScaleNum)-tileWidth*(1-midScaleNum)/(2*midScaleNum), dy:0.0), duration: moveDuration)
                let moveRight = SKAction.move(by: CGVector(dx:-cellSpacing/2+cellSpacing/(2*midScaleNum)+tileWidth*(1-midScaleNum)/(2*midScaleNum), dy:0.0), duration: moveDuration)
                let moveUp = SKAction.move(by: CGVector(dx:0.0, dy:-cellSpacing+cellSpacing/(midScaleNum)+tileWidth*(1-midScaleNum)/(midScaleNum)), duration: moveDuration)
                let moveDown = SKAction.move(by: CGVector(dx:0.0, dy:cellSpacing-cellSpacing/(midScaleNum)-tileWidth*(1-midScaleNum)/(midScaleNum)), duration: moveDuration)
                block1.run(SKAction.group([moveLeft, moveUp]))
                block2.run(moveLeft)
                block3.run(moveRight)
                block4.run(SKAction.group([moveLeft, moveDown]))
            // x x x
            //   x
            case .Type12:
                let moveLeft = SKAction.move(by: CGVector(dx:cellSpacing-cellSpacing/(midScaleNum)-tileWidth*(1-midScaleNum)/(midScaleNum), dy:0.0), duration: moveDuration)
                let moveRight = SKAction.move(by: CGVector(dx:-cellSpacing+cellSpacing/(midScaleNum)+tileWidth*(1-midScaleNum)/(midScaleNum), dy:0.0), duration: moveDuration)
                let moveUp = SKAction.move(by: CGVector(dx:0.0, dy:-cellSpacing/2+cellSpacing/(2*midScaleNum)+tileWidth*(1-midScaleNum)/(2*midScaleNum)), duration: moveDuration)
                let moveDown = SKAction.move(by: CGVector(dx:0.0, dy:cellSpacing/2-cellSpacing/(2*midScaleNum)-tileWidth*(1-midScaleNum)/(2*midScaleNum)), duration: moveDuration)
                block1.run(SKAction.group([moveLeft, moveUp]))
                block2.run(moveUp)
                block3.run(SKAction.group([moveRight, moveUp]))
                block4.run(moveDown)
            //   x
            // x x
            //   x
            case .Type13:
                let moveLeft = SKAction.move(by: CGVector(dx:cellSpacing/2-cellSpacing/(2*midScaleNum)-tileWidth*(1-midScaleNum)/(2*midScaleNum), dy:0.0), duration: moveDuration)
                let moveRight = SKAction.move(by: CGVector(dx:-cellSpacing/2+cellSpacing/(2*midScaleNum)+tileWidth*(1-midScaleNum)/(2*midScaleNum), dy:0.0), duration: moveDuration)
                let moveUp = SKAction.move(by: CGVector(dx:0.0, dy:-cellSpacing+cellSpacing/(midScaleNum)+tileWidth*(1-midScaleNum)/(midScaleNum)), duration: moveDuration)
                let moveDown = SKAction.move(by: CGVector(dx:0.0, dy:cellSpacing-cellSpacing/(midScaleNum)-tileWidth*(1-midScaleNum)/(midScaleNum)), duration: moveDuration)
                block1.run(SKAction.group([moveRight, moveUp]))
                block2.run(moveLeft)
                block3.run(moveRight)
                block4.run(SKAction.group([moveRight, moveDown]))
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
        
        self.blockDelegate.FourBlockWasReleased(sender: self)
    }
    
}

