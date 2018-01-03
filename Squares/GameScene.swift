//
//  GameScene.swift
//  Squares
//
//  Created by Alan Lou on 12/20/17.
//  Copyright © 2017 Rawwr Studios. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, MenuButtonDelegate, PauseButtonDelegate, RecallButtonDelegate, OneBlockNodeDelegate, TwoBlockNodeDelegate, ThreeBlockNodeDelegate, FourBlockNodeDelegate {
    
    // super node containing the layers
    let gameLayer = SKNode()
    let boardLayer = SKNode()
    let pauseLayer = SKNode()
    
    // board 2D array
    var boardArray = Array2D<SKColor>(columns: 9, rows: 9)
    
    // nodes
    let pauseButtonNode = PauseButtonNode(color: ColorCategory.PauseButtonColor)
    let recallButtonNode = RecallButtonNode(color: ColorCategory.RecallButtonColor)
    let bestScoreNode = BestScoreNode()
    
    // numbers
    let NumColumns: Int = 9
    let NumRows: Int = 9
    var bottomBlockNum: Int = 3
    
    let boardSpacing: CGFloat = 30.0
    let sectionSpacing: CGFloat = 23.0
    let cellSpacing: CGFloat = 3.0
    
    // variables
    let boardRect: CGRect
    let tileWidth: CGFloat
    var combo: Int = 0
    var numMatchingThisRound: Int = 0
    var bottomBlockArray = [SKSpriteNode?](repeating: nil, count: 3)
    var bottomBlockJustPut: SKSpriteNode?
    var previousReleasePositions = Array<CGPoint>()
    
    // booleans
    var isGameOver: Bool = false
    var isGamePaused: Bool = false
    
    var gameSoundOn: Bool? {
        get {
            if  UserDefaults.standard.object(forKey: "gameSoundOn") == nil {
                UserDefaults.standard.set(true, forKey: "gameSoundOn")
            }
            return UserDefaults.standard.bool(forKey: "gameSoundOn")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "gameSoundOn")
        }
    }
    
    // sharing actions
    let findMatchingSound: SKAction = SKAction.playSoundFileNamed(
        "findMatching.wav", waitForCompletion: false)
    let addBottomBlocksSound: SKAction = SKAction.playSoundFileNamed(
        "addBottomBlocks.wav", waitForCompletion: false)
    let blockIsSetSound: SKAction = SKAction.playSoundFileNamed(
        "blockIsSet.wav", waitForCompletion: false)
    let blockIsNotSetSound: SKAction = SKAction.playSoundFileNamed(
        "blockIsNotSet.wav", waitForCompletion: false)
    let buttonPressedSound: SKAction = SKAction.playSoundFileNamed(
        "buttonPressed.wav", waitForCompletion: false)
    
    //MARK:- Initialization
    override init(size: CGSize) {
        boardRect = CGRect(x:0, y:size.height/2-size.width/2, width:size.width, height:size.width)
        tileWidth = (boardRect.size.width - boardSpacing*2.0 - sectionSpacing*2.0 - cellSpacing*6.0)/9.0
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }
    
    override func didMove(to view: SKView) {
        self.backgroundColor = ColorCategory.BackgroundColor
        self.view?.isMultipleTouchEnabled = false
        
        /*** set up game layer ***/
        self.addChild(gameLayer)
        
        /*** set up board layer ***/
        boardLayer.position = CGPoint(x: boardRect.minX, y: boardRect.minY)
        gameLayer.addChild(boardLayer)
        
        /*** add tiles and bottom blocks ***/
        addTiles()
        addBottomBlocks()
        
        /*** set up best score node ***/
        let bestScoreNodeWidth = size.width/5
        let bestScoreNodeHeight = CGFloat(30.0)
        let bestScoreNodeFrame = CGRect(x: size.width-bestScoreNodeWidth-10, y: size.height-40, width: bestScoreNodeWidth, height: bestScoreNodeHeight)
        bestScoreNode.adjustLabelFontSizeToFitRect(rect: bestScoreNodeFrame)
        //debugDrawArea(rect: bestScoreNodeFrame)
        gameLayer.addChild(bestScoreNode)
        
        /*** set up pause button and pause area ***/
        // set up pause button node
        pauseButtonNode.buttonDelegate = self
        pauseButtonNode.anchorPoint = CGPoint(x:0.0, y:1.0)
        pauseButtonNode.position = CGPoint(x:0, y:size.height)
        gameLayer.addChild(pauseButtonNode)
        
        /*** set up recall button ***/
        recallButtonNode.buttonDelegate = self
        recallButtonNode.anchorPoint = CGPoint(x:0.0, y:1.0)
        recallButtonNode.position = CGPoint(x:pauseButtonNode.size.width, y:size.height)
        gameLayer.addChild(recallButtonNode)
        
        /*** set up pause layer ***/
        // add white mask to background
        let blurBackgroundNode = SKSpriteNode(color: SKColor.white.withAlphaComponent(0.80), size: CGSize(width: size.width, height: size.height))
        blurBackgroundNode.zPosition = 5000
        blurBackgroundNode.position = CGPoint(x:size.width/2 ,y: size.height/2)
        pauseLayer.addChild(blurBackgroundNode)
        
        // add continue button
        let resumeButton = MenuButtonNode(color: ColorCategory.ContinueButtonColor,
                                          buttonType: ButtonType.LongButton,
                                          iconType: IconType.ResumeButton)
        resumeButton.zPosition = 10000
        resumeButton.position = CGPoint(x: size.width/2,
                                        y: size.height/2 + 40)
        resumeButton.name = "resumebutton"
        resumeButton.buttonDelegate = self
        pauseLayer.addChild(resumeButton)
        
        // add home button
        let homeButton = MenuButtonNode(color: ColorCategory.HomeButtonColor,
                                        buttonType: ButtonType.ShortButton,
                                        iconType: IconType.HomeButton)
        homeButton.zPosition = 10000
        homeButton.position = CGPoint(x: size.width/2-resumeButton.size.width/2+homeButton.size.width/2,
                                      y: size.height/2 - 40)
        homeButton.name = "homebutton"
        homeButton.buttonDelegate = self
        pauseLayer.addChild(homeButton)
        
        // add sound button
        var iconTypeHere = IconType.SoundOnButton
        if let gameSoundOn = gameSoundOn {
            iconTypeHere = gameSoundOn ? IconType.SoundOnButton : IconType.SoundOffButton
        }
        let soundButton = MenuButtonNode(color: ColorCategory.SoundButtonColor,
                                         buttonType: ButtonType.ShortButton,
                                         iconType: iconTypeHere)
        soundButton.zPosition = 10000
        soundButton.position = CGPoint(x: size.width/2+resumeButton.size.width/2-homeButton.size.width/2,
                                       y: size.height/2 - 40)
        soundButton.name = "soundbutton"
        soundButton.buttonDelegate = self
        pauseLayer.addChild(soundButton)
        
        
    }
    
    //MARK:- Set Up Board
    func addTiles() {
        for row in 0..<NumRows {
            for col in 0..<NumColumns {
                let tileNode = TileNode(color: ColorCategory.TileColor)
                tileNode.size = CGSize(width: tileWidth, height: tileWidth)
                tileNode.position = pointInBoardLayerFor(column: col, row: row)
                tileNode.name = "tile\(col)\(row)"
                boardLayer.addChild(tileNode)
            }
        }
    }
    
    func addBottomBlocks() {
        // run sound
        self.run(addBottomBlocksSound)
        
        // set position
        let bottomBlockY = size.height/4-boardRect.height/4 + boardSpacing/2
        let bottomBlockXLeft = (tileWidth+cellSpacing) + tileWidth/2 + boardSpacing
        let bottomBlockXMid = size.width/2
        let bottomBlockXRight = size.width - bottomBlockXLeft
        
        // create random index
        let randomIndex1 = CGFloat(arc4random()) / CGFloat(UInt32.max)
        let randomIndex2 = CGFloat(arc4random()) / CGFloat(UInt32.max)
        let randomIndex3 = CGFloat(arc4random()) / CGFloat(UInt32.max)
        
        let maxIndex: UInt32 = 9
        
        // initialize block nodes
        if randomIndex1 <= 0.2 {
            let bottomBlock1 = OneBlockNode(width: tileWidth, color: ColorCategory.randomBlockColor(maxIndex: maxIndex), position: CGPoint(x: bottomBlockXLeft, y: bottomBlockY))
            addSingleBottomBlock(bottomBlock: bottomBlock1)
            bottomBlockArray[0] = bottomBlock1
        } else if randomIndex1 <= 0.45 {
            let bottomBlock1 = TwoBlockNode(width: tileWidth, color: ColorCategory.randomBlockColor(maxIndex: maxIndex), position: CGPoint(x: bottomBlockXLeft, y: bottomBlockY))
            addSingleBottomBlock(bottomBlock: bottomBlock1)
            bottomBlockArray[0] = bottomBlock1
        } else if randomIndex1 <= 0.75 {
            let bottomBlock1 = ThreeBlockNode(width: tileWidth, color: ColorCategory.randomBlockColor(maxIndex: maxIndex), position: CGPoint(x: bottomBlockXLeft, y: bottomBlockY))
            addSingleBottomBlock(bottomBlock: bottomBlock1)
            bottomBlockArray[0] = bottomBlock1
        } else {
            let bottomBlock1 = FourBlockNode(width: tileWidth, color: ColorCategory.randomBlockColor(maxIndex: maxIndex), position: CGPoint(x: bottomBlockXLeft, y: bottomBlockY))
            addSingleBottomBlock(bottomBlock: bottomBlock1)
            bottomBlockArray[0] = bottomBlock1
        }
        
        if randomIndex2 <= 0.2 {
            let bottomBlock2 = OneBlockNode(width: tileWidth, color: ColorCategory.randomBlockColor(maxIndex: maxIndex), position: CGPoint(x: bottomBlockXMid, y: bottomBlockY))
            addSingleBottomBlock(bottomBlock: bottomBlock2)
            bottomBlockArray[1] = bottomBlock2
        } else if randomIndex2 <= 0.45 {
            let bottomBlock2 = TwoBlockNode(width: tileWidth, color: ColorCategory.randomBlockColor(maxIndex: maxIndex), position: CGPoint(x: bottomBlockXMid, y: bottomBlockY))
            addSingleBottomBlock(bottomBlock: bottomBlock2)
            bottomBlockArray[1] = bottomBlock2
        } else if randomIndex2 <= 0.75 {
            let bottomBlock2 = ThreeBlockNode(width: tileWidth, color: ColorCategory.randomBlockColor(maxIndex: maxIndex), position: CGPoint(x: bottomBlockXMid, y: bottomBlockY))
            addSingleBottomBlock(bottomBlock: bottomBlock2)
            bottomBlockArray[1] = bottomBlock2
        } else {
            let bottomBlock2 = FourBlockNode(width: tileWidth, color: ColorCategory.randomBlockColor(maxIndex: maxIndex), position: CGPoint(x: bottomBlockXMid, y: bottomBlockY))
            addSingleBottomBlock(bottomBlock: bottomBlock2)
            bottomBlockArray[1] = bottomBlock2
        }
        
        if randomIndex3 <= 0.2 {
            let bottomBlock3 = OneBlockNode(width: tileWidth, color: ColorCategory.randomBlockColor(maxIndex: maxIndex), position: CGPoint(x: bottomBlockXRight, y: bottomBlockY))
            addSingleBottomBlock(bottomBlock: bottomBlock3)
            bottomBlockArray[2] = bottomBlock3
        } else if randomIndex3 <= 0.45 {
            let bottomBlock3 = TwoBlockNode(width: tileWidth, color: ColorCategory.randomBlockColor(maxIndex: maxIndex), position: CGPoint(x: bottomBlockXRight, y: bottomBlockY))
            addSingleBottomBlock(bottomBlock: bottomBlock3)
            bottomBlockArray[2] = bottomBlock3
        } else if randomIndex3 <= 0.75 {
            let bottomBlock3 = ThreeBlockNode(width: tileWidth, color: ColorCategory.randomBlockColor(maxIndex: maxIndex), position: CGPoint(x: bottomBlockXRight, y: bottomBlockY))
            addSingleBottomBlock(bottomBlock: bottomBlock3)
            bottomBlockArray[2] = bottomBlock3
        } else {
            let bottomBlock3 = FourBlockNode(width: tileWidth, color: ColorCategory.randomBlockColor(maxIndex: maxIndex), position: CGPoint(x: bottomBlockXRight, y: bottomBlockY))
            addSingleBottomBlock(bottomBlock: bottomBlock3)
            bottomBlockArray[2] = bottomBlock3
        }
        
        for index in 0..<3 {
            bottomBlockArray[index]?.name = "bottomBlock\(index)"
        }
    }
    
    func addSingleBottomBlock(bottomBlock: SKSpriteNode) {
        if let bottomBlock = bottomBlock as? OneBlockNode {
            bottomBlock.position = bottomBlock.getBlockPosition()
            bottomBlock.blockDelegate = self
        }
        if let bottomBlock = bottomBlock as? TwoBlockNode {
            bottomBlock.position = bottomBlock.getBlockPosition()
            bottomBlock.blockDelegate = self
        }
        if let bottomBlock = bottomBlock as? ThreeBlockNode {
            bottomBlock.position = bottomBlock.getBlockPosition()
            bottomBlock.blockDelegate = self
        }
        if let bottomBlock = bottomBlock as? FourBlockNode {
            bottomBlock.position = bottomBlock.getBlockPosition()
            bottomBlock.blockDelegate = self
        }
        
        bottomBlock.setScale(0.0)
        gameLayer.addChild(bottomBlock)
        
        // animation
        let scaleUp = SKAction.scale(to: 0.7, duration: 0.17) // lowScaleNum
        let scaleDown = SKAction.scale(to: 0.6, duration: 0.1) // lowScaleNum
        bottomBlock.run(SKAction.sequence([scaleUp, scaleDown]))
    }
    
    //MARK:- BlockNodeDelegate
    func oneBlockWasReleased(sender: OneBlockNode) {
        guard let releasePosition = sender.getReleasePosition() else {
            return
        }
        
        let posInBoardLayer = convert(releasePosition, to: boardLayer)
        let (rowNum, colNum) = rowAndColFor(position: posInBoardLayer)
        
        /*** put the block in board ***/
        if let colNum = colNum, let rowNum = rowNum {
            // already a block in place
            if blockCellColorAt(column: colNum, row: rowNum) != nil {
                sender.setNodeAt(positionInScreen: nil)
                // run sound
                self.run(blockIsNotSetSound)
                return
            }
            
            let positionInBoard = pointInBoardLayerFor(column: colNum, row: rowNum)
            let positionInScreen = CGPoint(x: positionInBoard.x + boardLayer.position.x - gameLayer.position.x,
                                           y: positionInBoard.y + boardLayer.position.y - gameLayer.position.y)
            sender.setNodeAt(positionInScreen: positionInScreen)
            bottomBlockNum = bottomBlockNum-1
            
            // put new blocks
            if bottomBlockNum == 0 {
                addBottomBlocks()
                bottomBlockNum = 3
            }
        } else {
            /*** put the block back to bottom ***/
            // run sound
            self.run(blockIsNotSetSound)
            sender.setNodeAt(positionInScreen: nil)
        }
    }
    
    func oneBlockWasSet(sender: OneBlockNode) {
        guard let releasePosition = sender.getReleasePosition() else {
            return
        }
        let posInBoardLayer = convert(releasePosition, to: boardLayer)
        let (rowNum, colNum) = rowAndColFor(position: posInBoardLayer)
        
        // for recalling
        previousReleasePositions.removeAll()
        previousReleasePositions.append(posInBoardLayer)
        
        /*** Update the tile color ***/
        if let colNum = colNum, let rowNum = rowNum {
            boardArray[colNum, rowNum] = sender.getBlockColor()
            updateBlockCellColorAt(column: colNum, row: rowNum)
        }
        
        bottomBlockJustPut = sender
        recallButtonNode.isRecallPossible = true
        sender.removeFromParent()
        
        checkBoardAndUpdate()
    }
    
    func TwoBlockWasReleased(sender: TwoBlockNode) {
        let nodeReleasePositions = sender.getNodeReleasePositions()
        
        var matchCount = 0
        var releasePositionsInScreen = [CGPoint]()
        
        var secRow: Int = -1
        var secCol: Int = -1
        for releasePosition in nodeReleasePositions {
            let posInBoardLayer = convert(releasePosition, to: boardLayer)
            let (rowNum, colNum) = rowAndColFor(position: posInBoardLayer)
            
            /*** if node in position ***/
            if let colNum = colNum, let rowNum = rowNum {
                // already a block in place. put back
                if blockCellColorAt(column: colNum, row: rowNum) != nil {
                    // run sound
                    self.run(blockIsNotSetSound)
                    sender.setNodeAt(positionsInScreen: nil)
                    return
                }
                
                // not in same section
                if secRow == -1 {
                    secRow = Int(rowNum/3)
                } else if secRow != Int(rowNum/3) {
                    // run sound
                    self.run(blockIsNotSetSound)
                    sender.setNodeAt(positionsInScreen: nil)
                    return
                }
                if secCol == -1 {
                    secCol = Int(colNum/3)
                } else if secCol != Int(colNum/3) {
                    // run sound
                    self.run(blockIsNotSetSound)
                    sender.setNodeAt(positionsInScreen: nil)
                    return
                }
                
                let positionInBoard = pointInBoardLayerFor(column: colNum, row: rowNum)
                let positionInScreen = CGPoint(x: positionInBoard.x + boardLayer.position.x - gameLayer.position.x,
                                               y: positionInBoard.y + boardLayer.position.y - gameLayer.position.y)
                releasePositionsInScreen.append(positionInScreen)
                
                matchCount = matchCount+1
            } else {
                // not in right position. put back
                // run sound
                self.run(blockIsNotSetSound)
                sender.setNodeAt(positionsInScreen: nil)
            }
        }
        
        // put into board!
        if matchCount == 2 {
            sender.setNodeAt(positionsInScreen: releasePositionsInScreen)
            bottomBlockNum = bottomBlockNum-1
            
            // put new blocks
            if bottomBlockNum == 0 {
                addBottomBlocks()
                bottomBlockNum = 3
            }
        }
            
    }
    
    func TwoBlockWasSet(sender: TwoBlockNode) {
        let nodeReleasePositions = sender.getNodeReleasePositions()
        
        // for recalling
        previousReleasePositions.removeAll()
        
        for releasePosition in nodeReleasePositions {
            let posInBoardLayer = convert(releasePosition, to: boardLayer)
            let (rowNum, colNum) = rowAndColFor(position: posInBoardLayer)
            
            // for recalling
            previousReleasePositions.append(posInBoardLayer)
            
            /*** Update the tile color ***/
            if let colNum = colNum, let rowNum = rowNum {
                boardArray[colNum, rowNum] = sender.getBlockColor()
                updateBlockCellColorAt(column: colNum, row: rowNum)
            }
        }
        
        bottomBlockJustPut = sender
        recallButtonNode.isRecallPossible = true
        sender.removeFromParent()
        
        checkBoardAndUpdate()
    }
    
    func ThreeBlockWasReleased(sender: ThreeBlockNode) {
        let nodeReleasePositions = sender.getNodeReleasePositions()
        
        var matchCount = 0
        var releasePositionsInScreen = [CGPoint]()
        
        var secRow: Int = -1
        var secCol: Int = -1
        for releasePosition in nodeReleasePositions {
            let posInBoardLayer = convert(releasePosition, to: boardLayer)
            let (rowNum, colNum) = rowAndColFor(position: posInBoardLayer)
            
            /*** if node in position ***/
            if let colNum = colNum, let rowNum = rowNum {
                // already a block in place. put back
                if blockCellColorAt(column: colNum, row: rowNum) != nil {
                    // run sound
                    self.run(blockIsNotSetSound)
                    sender.setNodeAt(positionsInScreen: nil)
                    return
                }
                
                // not in same section
                if secRow == -1 {
                    secRow = Int(rowNum/3)
                } else if secRow != Int(rowNum/3) {
                    // run sound
                    self.run(blockIsNotSetSound)
                    sender.setNodeAt(positionsInScreen: nil)
                    return
                }
                if secCol == -1 {
                    secCol = Int(colNum/3)
                } else if secCol != Int(colNum/3) {
                    // run sound
                    self.run(blockIsNotSetSound)
                    sender.setNodeAt(positionsInScreen: nil)
                    return
                }
                
                let positionInBoard = pointInBoardLayerFor(column: colNum, row: rowNum)
                let positionInScreen = CGPoint(x: positionInBoard.x + boardLayer.position.x - gameLayer.position.x,
                                               y: positionInBoard.y + boardLayer.position.y - gameLayer.position.y)
                releasePositionsInScreen.append(positionInScreen)
                
                matchCount = matchCount+1
            } else {
                // not in right position. put back
                // run sound
                self.run(blockIsNotSetSound)
                sender.setNodeAt(positionsInScreen: nil)
            }
        }
        
        // put into board!
        if matchCount == 3 {
            sender.setNodeAt(positionsInScreen: releasePositionsInScreen)
            bottomBlockNum = bottomBlockNum-1
            
            // put new blocks
            if bottomBlockNum == 0 {
                addBottomBlocks()
                bottomBlockNum = 3
            }
        }
    }
    
    func ThreeBlockWasSet(sender: ThreeBlockNode) {
        
        let nodeReleasePositions = sender.getNodeReleasePositions()
        
        // for recalling
        previousReleasePositions.removeAll()
        
        for releasePosition in nodeReleasePositions {
            let posInBoardLayer = convert(releasePosition, to: boardLayer)
            let (rowNum, colNum) = rowAndColFor(position: posInBoardLayer)
            
            // for recalling
            previousReleasePositions.append(posInBoardLayer)
            
            /*** Update the tile color ***/
            if let colNum = colNum, let rowNum = rowNum {
                boardArray[colNum, rowNum] = sender.getBlockColor()
                updateBlockCellColorAt(column: colNum, row: rowNum)
            }
        }
        
        bottomBlockJustPut = sender
        recallButtonNode.isRecallPossible = true
        sender.removeFromParent()
        
        // run after the block is removed
        checkBoardAndUpdate()
    }
    
    func FourBlockWasReleased(sender: FourBlockNode) {
        let nodeReleasePositions = sender.getNodeReleasePositions()
        
        var matchCount = 0
        var releasePositionsInScreen = [CGPoint]()
        
        var secRow: Int = -1
        var secCol: Int = -1
        for releasePosition in nodeReleasePositions {
            let posInBoardLayer = convert(releasePosition, to: boardLayer)
            let (rowNum, colNum) = rowAndColFor(position: posInBoardLayer)
            
            /*** if node in position ***/
            if let colNum = colNum, let rowNum = rowNum {
                // already a block in place. put back
                if blockCellColorAt(column: colNum, row: rowNum) != nil {
                    // run sound
                    self.run(blockIsNotSetSound)
                    sender.setNodeAt(positionsInScreen: nil)
                    return
                }
                
                // not in same section
                if secRow == -1 {
                    secRow = Int(rowNum/3)
                } else if secRow != Int(rowNum/3) {
                    // run sound
                    self.run(blockIsNotSetSound)
                    sender.setNodeAt(positionsInScreen: nil)
                    return
                }
                if secCol == -1 {
                    secCol = Int(colNum/3)
                } else if secCol != Int(colNum/3) {
                    // run sound
                    self.run(blockIsNotSetSound)
                    sender.setNodeAt(positionsInScreen: nil)
                    return
                }
                
                let positionInBoard = pointInBoardLayerFor(column: colNum, row: rowNum)
                let positionInScreen = CGPoint(x: positionInBoard.x + boardLayer.position.x - gameLayer.position.x,
                                               y: positionInBoard.y + boardLayer.position.y - gameLayer.position.y)
                releasePositionsInScreen.append(positionInScreen)
                
                matchCount = matchCount+1
            } else {
                // not in right position. put back
                // run sound
                self.run(blockIsNotSetSound)
                sender.setNodeAt(positionsInScreen: nil)
            }
        }
        
        // put into board!
        if matchCount == 4 {
            sender.setNodeAt(positionsInScreen: releasePositionsInScreen)
            bottomBlockNum = bottomBlockNum-1
            
            // put new blocks
            if bottomBlockNum == 0 {
                addBottomBlocks()
                bottomBlockNum = 3
            }
        }
    }
    
    func FourBlockWasSet(sender: FourBlockNode) {
        
        let nodeReleasePositions = sender.getNodeReleasePositions()
        
        // for recalling
        previousReleasePositions.removeAll()
        
        for releasePosition in nodeReleasePositions {
            let posInBoardLayer = convert(releasePosition, to: boardLayer)
            let (rowNum, colNum) = rowAndColFor(position: posInBoardLayer)
            
            // for recalling
            previousReleasePositions.append(posInBoardLayer)
            
            /*** Update the tile color ***/
            if let colNum = colNum, let rowNum = rowNum {
                boardArray[colNum, rowNum] = sender.getBlockColor()
                updateBlockCellColorAt(column: colNum, row: rowNum)
            }
        }
        
        bottomBlockJustPut = sender
        recallButtonNode.isRecallPossible = true
        sender.removeFromParent()
        
        checkBoardAndUpdate()
    }
    
    //MARK:- MenuButtonDelegate Func
    func buttonWasPressed(sender: MenuButtonNode) {
        let iconType = sender.getIconType()
        
        // play sound
        if let gameSoundOn = gameSoundOn,
            gameSoundOn,
            iconType != IconType.SoundOffButton {
            self.run(buttonPressedSound)
        }
        if let gameSoundOn = gameSoundOn,
            !gameSoundOn,
            iconType == IconType.SoundOnButton {
            self.run(buttonPressedSound)
        }
        
        if iconType == IconType.ResumeButton  {
            print("HEYYY")
            if isGamePaused {
                unpauseGame()
                isGamePaused = false
            }
            return
        }
        if iconType == IconType.HomeButton  {
            print("Go Back to Home")
        }
        if iconType == IconType.SoundOnButton  {
            //print("Sound On")
            gameSoundOn = true
            return
        }
        if iconType == IconType.SoundOffButton  {
            //print("Sound Off")
            gameSoundOn = false
            return
        }
        if iconType == IconType.RestartButton  {
            let myScene = GameScene(size: self.size)
            myScene.scaleMode = self.scaleMode
            let reveal = SKTransition.fade(withDuration: 0.5)
            self.view?.presentScene(myScene, transition: reveal)
            return
        }
        
    }
    
    //MARK:- PauseButtonDelegate Func
    func pauseButtonWasPressed(sender: PauseButtonNode) {
        isGamePaused = true
        pauseGame()
    }

    //MARK:- RecallButtonDelegate Func
    func recallButtonWasPressed(sender: RecallButtonNode) {
        
        // run sound
        self.run(addBottomBlocksSound)
        
        if let bottomBlockJustPut = bottomBlockJustPut as? FourBlockNode {
            gameLayer.addChild(bottomBlockJustPut)
            
            let targetPosition = bottomBlockJustPut.getBlockPosition()
            bottomBlockJustPut.blockDelegate = self
            
            // animation
            let moveBack = SKAction.move(to: targetPosition, duration: 0.1)
            let scaleDown = SKAction.scale(to: 0.6, duration: 0.1) // lowScaleNum

            bottomBlockJustPut.run(SKAction.group([moveBack, scaleDown]), completion: {[weak self] in
                bottomBlockJustPut.isUserInteractionEnabled = true
                self?.bottomBlockNum = (self?.bottomBlockNum)!+1
            })
        }
        
        
        // we can make a recall
        if sender.isRecallPossible {
            for previousReleasePosition in previousReleasePositions {
                let (rowNum, colNum) = rowAndColFor(position: previousReleasePosition)
                
                /*** Update the tile color back to gray ***/
                if let colNum = colNum, let rowNum = rowNum {
                    boardArray[colNum, rowNum] = nil
                    updateBlockCellColorAt(column: colNum, row: rowNum)
                }
            }
            
            // make the recall not possible (can only recall one step)
            sender.isRecallPossible = false
        }
        
    }
    
    //MARK:- Game Logic Handling
    func pointInBoardLayerFor(column: Int, row: Int) -> CGPoint {
        var xCoord = CGFloat(0.0)
        var yCoord = CGFloat(0.0)
        
        switch column {
        case (0...2):
            xCoord = CGFloat(column)*(tileWidth+cellSpacing) + tileWidth/2 + boardSpacing
        case (3...5):
            xCoord = CGFloat(column)*(tileWidth+cellSpacing) - cellSpacing + tileWidth/2 + boardSpacing + sectionSpacing
        case (6...8):
            xCoord = CGFloat(column)*(tileWidth+cellSpacing) - cellSpacing*CGFloat(2.0) + tileWidth/2 + boardSpacing + sectionSpacing*CGFloat(2.0)
        default: break
        }
        
        switch row {
        case (0...2):
            yCoord = CGFloat(row)*(tileWidth+cellSpacing) + tileWidth/2 + boardSpacing
        case (3...5):
            yCoord = CGFloat(row)*(tileWidth+cellSpacing) - cellSpacing + tileWidth/2 + boardSpacing + sectionSpacing
        case (6...8):
            yCoord = CGFloat(row)*(tileWidth+cellSpacing) - cellSpacing*CGFloat(2.0) + tileWidth/2 + boardSpacing + sectionSpacing*CGFloat(2.0)
        default: break
        }
        
        return CGPoint(x: xCoord, y: yCoord)
    }
    
    func rowAndColFor(position: CGPoint) -> (Int?, Int?) {
        let xPos = position.x
        let yPos = position.y
        
        var rowNum:Int = 0
        var colNum:Int = 0
        
        if xPos >= boardSpacing, xPos <= boardSpacing+tileWidth {
            colNum = 0
        } else if xPos >= boardSpacing+(tileWidth+cellSpacing), xPos <= boardSpacing+(tileWidth+cellSpacing)+tileWidth {
            colNum = 1
        } else if xPos >= boardSpacing+(tileWidth+cellSpacing)*CGFloat(2.0), xPos <= boardSpacing+(tileWidth+cellSpacing)*CGFloat(2.0)+tileWidth {
            colNum = 2
        } else if xPos >= boardSpacing+sectionSpacing+(tileWidth+cellSpacing)*CGFloat(2.0)+tileWidth, xPos <= boardSpacing+sectionSpacing+(tileWidth+cellSpacing)*CGFloat(2.0)+tileWidth*CGFloat(2.0) {
            colNum = 3
        } else if xPos >= boardSpacing+sectionSpacing+(tileWidth+cellSpacing)*CGFloat(3.0)+tileWidth, xPos <= boardSpacing+sectionSpacing+(tileWidth+cellSpacing)*CGFloat(3.0)+tileWidth*CGFloat(2.0) {
            colNum = 4
        } else if xPos >= boardSpacing+sectionSpacing+(tileWidth+cellSpacing)*CGFloat(4.0)+tileWidth, xPos <= boardSpacing+sectionSpacing+(tileWidth+cellSpacing)*CGFloat(4.0)+tileWidth*CGFloat(2.0) {
            colNum = 5
        } else if xPos >= boardSpacing+sectionSpacing*CGFloat(2.0)+(tileWidth+cellSpacing)*CGFloat(4.0)+tileWidth*CGFloat(2.0), xPos <= boardSpacing+sectionSpacing*CGFloat(2.0)+(tileWidth+cellSpacing)*CGFloat(4.0)+tileWidth*CGFloat(3.0) {
            colNum = 6
        } else if xPos >= boardSpacing+sectionSpacing*CGFloat(2.0)+(tileWidth+cellSpacing)*CGFloat(5.0)+tileWidth*CGFloat(2.0), xPos <= boardSpacing+sectionSpacing*CGFloat(2.0)+(tileWidth+cellSpacing)*CGFloat(5.0)+tileWidth*CGFloat(3.0) {
            colNum = 7
        } else if xPos >= boardSpacing+sectionSpacing*CGFloat(2.0)+(tileWidth+cellSpacing)*CGFloat(6.0)+tileWidth*CGFloat(2.0), xPos <= boardSpacing+sectionSpacing*CGFloat(2.0)+(tileWidth+cellSpacing)*CGFloat(6.0)+tileWidth*CGFloat(3.0) {
            colNum = 8
        } else {
            return (nil, nil)
        }
        
        
        if yPos >= boardSpacing, yPos <= boardSpacing+tileWidth {
            rowNum = 0
        } else if yPos >= boardSpacing+(tileWidth+cellSpacing), yPos <= boardSpacing+(tileWidth+cellSpacing)+tileWidth {
            rowNum = 1
        } else if yPos >= boardSpacing+(tileWidth+cellSpacing)*CGFloat(2.0), yPos <= boardSpacing+(tileWidth+cellSpacing)*CGFloat(2.0)+tileWidth {
            rowNum = 2
        } else if yPos >= boardSpacing+sectionSpacing+(tileWidth+cellSpacing)*CGFloat(2.0)+tileWidth, yPos <= boardSpacing+sectionSpacing+(tileWidth+cellSpacing)*CGFloat(2.0)+tileWidth*CGFloat(2.0) {
            rowNum = 3
        } else if yPos >= boardSpacing+sectionSpacing+(tileWidth+cellSpacing)*CGFloat(3.0)+tileWidth, yPos <= boardSpacing+sectionSpacing+(tileWidth+cellSpacing)*CGFloat(3.0)+tileWidth*CGFloat(2.0) {
            rowNum = 4
        } else if yPos >= boardSpacing+sectionSpacing+(tileWidth+cellSpacing)*CGFloat(4.0)+tileWidth, yPos <= boardSpacing+sectionSpacing+(tileWidth+cellSpacing)*CGFloat(4.0)+tileWidth*CGFloat(2.0) {
            rowNum = 5
        } else if yPos >= boardSpacing+sectionSpacing*CGFloat(2.0)+(tileWidth+cellSpacing)*CGFloat(4.0)+tileWidth*CGFloat(2.0), yPos <= boardSpacing+sectionSpacing*CGFloat(2.0)+(tileWidth+cellSpacing)*CGFloat(4.0)+tileWidth*CGFloat(3.0) {
            rowNum = 6
        } else if yPos >= boardSpacing+sectionSpacing*CGFloat(2.0)+(tileWidth+cellSpacing)*CGFloat(5.0)+tileWidth*CGFloat(2.0), yPos <= boardSpacing+sectionSpacing*CGFloat(2.0)+(tileWidth+cellSpacing)*CGFloat(5.0)+tileWidth*CGFloat(3.0) {
            rowNum = 7
        } else if yPos >= boardSpacing+sectionSpacing*CGFloat(2.0)+(tileWidth+cellSpacing)*CGFloat(6.0)+tileWidth*CGFloat(2.0), yPos <= boardSpacing+sectionSpacing*CGFloat(2.0)+(tileWidth+cellSpacing)*CGFloat(6.0)+tileWidth*CGFloat(3.0) {
            rowNum = 8
        } else {
            return (nil, nil)
        }
        
        return (rowNum, colNum)
    }
    
    func blockCellColorAt(column: Int, row: Int) -> SKColor? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return boardArray[column, row]
    }
    
    func sectionColAndRowFor(column: Int, row: Int) -> (Int, Int) {
        return (Int(column/3), Int(row/3))
    }
    
    func updateBlockCellColorAt(column: Int, row: Int) {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        
        let blockColor:SKColor? = blockCellColorAt(column: column, row: row)
        let targetTileNode: TileNode = boardLayer.childNode(withName: "tile\(column)\(row)") as! TileNode
        
        // update block cell color
        if let blockColor = blockColor {
            targetTileNode.changeColor(to: blockColor)
        } else {
            // reset block cell color
            targetTileNode.changeColor(to: ColorCategory.TileColor)
        }
    }
    
    /* this is called only when a block is set successfully in board */
    func checkBoardAndUpdate() {
        
        // play sound
        self.run(blockIsSetSound)
        
        for index in 0..<3 {
            let bottomBlock = gameLayer.childNode(withName: "bottomBlock\(index)")
            bottomBlockArray[index] = bottomBlock as? SKSpriteNode
        }
        
        print("==========")
        print(bottomBlockArray)
        
        // initiate section color array
        var sectionArray = Array2D<Set<SKColor>>(columns: 3, rows: 3)
        for secRow in 0..<3 {
            for secCol in 0..<3 {
                sectionArray[secCol,secRow] = Set<SKColor>()
            }
        }
        
        // fill the section array with colors in each section
        for row in 0..<NumRows {
            for col in 0..<NumColumns {
                let tempColor = blockCellColorAt(column: col, row: row)
                let (secCol, secRow) = sectionColAndRowFor(column: col, row: row)
                // if there's a cell (color)
                if let tempColor = tempColor {
                    sectionArray[secCol, secRow]?.insert(tempColor)
                }
            }
        }
        
        // iterate through each color
        for blockColor in ColorCategory.BlockColorArray {
            // Case 1. Row Matching
            for secRow in 0..<3 {
                var matchCount = 0
                
                for secCol in 0..<3 {
                    let isColorMatching: Bool? = sectionArray[secCol, secRow]?.contains(blockColor)
                    if let isColorMatching = isColorMatching, isColorMatching {
                        matchCount = matchCount + 1
                    }
                }
                
                // find a matching row
                if matchCount == 3 {
                    // highlight the matching row
                    highlightSecRow(secRow: secRow, color: blockColor)
                    
                    for column in 0..<NumColumns {
                        for row in secRow*3..<secRow*3+3 {
                            let matchingColor = blockCellColorAt(column: column, row: row)
                            if matchingColor == blockColor {
                                let targetTileNode: TileNode = boardLayer.childNode(withName: "tile\(column)\(row)") as! TileNode
                                boardArray[column, row] = nil
                                 removeTileNode(tileNode: targetTileNode)
                            }
                        }
                    }
                }
            }
            
            // Case 2. Column Matching
            for secCol in 0..<3 {
                var matchCount = 0
                
                for secRow in 0..<3 {
                    let isColorMatching: Bool? = sectionArray[secCol, secRow]?.contains(blockColor)
                    if let isColorMatching = isColorMatching, isColorMatching {
                        matchCount = matchCount + 1
                    }
                }
                
                // find a matching column
                if matchCount == 3 {
                    // highlight the matching row
                    highlightSecCol(secCol: secCol, color: blockColor)
                    
                    for row in 0..<NumRows {
                        for column in secCol*3..<secCol*3+3 {
                            let matchingColor = blockCellColorAt(column: column, row: row)
                            if matchingColor == blockColor {
                                let targetTileNode: TileNode = boardLayer.childNode(withName: "tile\(column)\(row)") as! TileNode
                                boardArray[column, row] = nil
                                removeTileNode(tileNode: targetTileNode)
                            }
                        }
                    }
                }
            }
            
            // Case 3. Diagonal Matching (\ Direction)
            var matchCount = 0
            for secCol in 0..<3 {
                let secRow = 2-secCol
                
                let isColorMatching: Bool? = sectionArray[secCol, secRow]?.contains(blockColor)
                if let isColorMatching = isColorMatching, isColorMatching {
                    matchCount = matchCount + 1
                }
            }
            if matchCount == 3 {
                // highlight the matching diagonal
                highlightDiag1(color: blockColor)
                
                for row in 0..<NumRows{
                    for column in 6-Int(row/3)*3..<9-Int(row/3)*3 {
                        let matchingColor = blockCellColorAt(column: column, row: row)
                        
                        if matchingColor == blockColor {
                            let targetTileNode: TileNode = boardLayer.childNode(withName: "tile\(column)\(row)") as! TileNode
                            boardArray[column, row] = nil
                            removeTileNode(tileNode: targetTileNode)
                        }
                    }
                }
            }
            
            // Case 4. Diagonal Matching (/ Direction)
            matchCount = 0
            for secCol in 0..<3 {
                let secRow = secCol
                
                let isColorMatching: Bool? = sectionArray[secCol, secRow]?.contains(blockColor)
                if let isColorMatching = isColorMatching, isColorMatching {
                    matchCount = matchCount + 1
                }
            }
            if matchCount == 3 {
                // highlight the matching diagonal
                highlightDiag2(color: blockColor)
                
                for row in 0..<NumRows{
                    for column in Int(row/3)*3..<Int(row/3)*3+3 {
                        let matchingColor = blockCellColorAt(column: column, row: row)
                        if matchingColor == blockColor {
                            let targetTileNode: TileNode = boardLayer.childNode(withName: "tile\(column)\(row)") as! TileNode
                            boardArray[column, row] = nil
                            removeTileNode(tileNode: targetTileNode)
                        }
                    }
                }
            }
            
            
            // Case 5. Section
            for secCol in 0..<3 {
                for secRow in 0..<3 {
                    matchCount = 0
                    
                    for column in secCol*3..<secCol*3+3 {
                        for row in secRow*3..<secRow*3+3 {
                            let matchingColor = blockCellColorAt(column: column, row: row)
                            
                            if matchingColor == blockColor {
                                matchCount = matchCount+1
                            }
                        }
                    }
                    
                    if matchCount == 9 {
                        // highlight the matching diagonal
                        highlightSection(secCol: secCol, secRow: secRow, color: blockColor)
                        
                        for column in secCol*3..<secCol*3+3 {
                            for row in secRow*3..<secRow*3+3 {
                                let targetTileNode: TileNode = boardLayer.childNode(withName: "tile\(column)\(row)") as! TileNode
                                boardArray[column, row] = nil
                                removeTileNode(tileNode: targetTileNode)
                            }
                        }
                    }

                }
            }
        }
        
        
        // reset combo
        if numMatchingThisRound > 0 {
            self.run(findMatchingSound)
            combo = combo+numMatchingThisRound
        } else {
            combo = 0
        }
        
        if combo > 1 {
            shakeCamera(layer: boardLayer, duration: 0.16, magnitude: CGFloat(combo))
        }
        
        numMatchingThisRound = 0
        
        checkGameOver()
    }
    
    // remove tile node with animation
    func removeTileNode(tileNode: TileNode) {
        
        let emitter = SKEmitterNode()
        let particleTexture = SKTexture(imageNamed: "Ball")
        emitter.particleTexture = particleTexture
        emitter.particleBirthRate = 150
        emitter.numParticlesToEmit = 8
        emitter.particleLifetime = 0.6
        emitter.emissionAngle = 0.0
        emitter.emissionAngleRange = CGFloat.pi*2
        emitter.particleSpeed = 350
        emitter.particleSpeedRange = 150
        emitter.particleAlpha = 1.0
        emitter.particleAlphaSpeed = -1.6
        emitter.particleAlphaRange = 0.0
        emitter.particleScale = 2.0
        emitter.particleScaleRange = 1.6
        emitter.particleScaleSpeed = -2.0
        emitter.particleColorBlendFactor = 1.0
        emitter.particleColor = tileNode.color
        emitter.particleColorBlendFactorSequence = nil
        emitter.particleBlendMode = SKBlendMode.alpha
        emitter.position = tileNode.position
        emitter.zPosition = 100
        boardLayer.addChild(emitter)
        emitter.run(SKAction.sequence([SKAction.wait(forDuration: 1.0),
                                       SKAction.removeFromParent()]))
        
        // reset the tile color
        tileNode.changeColor(to: ColorCategory.TileColor)
    }
    
    func highlightSecRow(secRow: Int, color: SKColor?) {
        numMatchingThisRound = numMatchingThisRound + 1
        
        assert(secRow >= 0 && secRow < 3)
        for column in 0..<NumColumns {
            for row in secRow*3..<secRow*3+3 {
                if boardLayer.childNode(withName: "tile\(column)\(row)") == nil {
                    continue
                }
                let targetTileNode: TileNode = boardLayer.childNode(withName: "tile\(column)\(row)") as! TileNode
                if let color = color, boardArray[column,row] == nil || boardArray[column,row] == color {
                    let changeColor = SKAction.colorize(with: color.withAlphaComponent(0.5), colorBlendFactor: 1.0, duration: 0.3)
                    let changeColorBack = SKAction.colorize(with: ColorCategory.TileColor, colorBlendFactor: 1.0, duration: 0.3)
                    if !targetTileNode.hasActions(){
                        targetTileNode.run(SKAction.sequence([changeColor,changeColorBack]))
                    }
                }
            }
        }
    }
    
    func highlightSecCol(secCol: Int, color: SKColor?) {
        numMatchingThisRound = numMatchingThisRound + 1
        
        assert(secCol >= 0 && secCol < 3)
        for row in 0..<NumRows {
            for column in secCol*3..<secCol*3+3 {
                if boardLayer.childNode(withName: "tile\(column)\(row)") == nil {
                    continue
                }
                let targetTileNode: TileNode = boardLayer.childNode(withName: "tile\(column)\(row)") as! TileNode
                if let color = color, boardArray[column,row] == nil || boardArray[column,row] == color {
                    let changeColor = SKAction.colorize(with: color.withAlphaComponent(0.5), colorBlendFactor: 1.0, duration: 0.3)
                    let changeColorBack = SKAction.colorize(with: ColorCategory.TileColor, colorBlendFactor: 1.0, duration: 0.3)
                    if !targetTileNode.hasActions(){
                        targetTileNode.run(SKAction.sequence([changeColor,changeColorBack]))
                    }
                }
            }
        }
    }
    
    func highlightDiag1(color: SKColor?) {
        numMatchingThisRound = numMatchingThisRound + 1
        
        for row in 0..<NumRows{
            for column in 6-Int(row/3)*3..<9-Int(row/3)*3 {
                if boardLayer.childNode(withName: "tile\(column)\(row)") == nil {
                    continue
                }
                let targetTileNode: TileNode = boardLayer.childNode(withName: "tile\(column)\(row)") as! TileNode
                if let color = color, boardArray[column,row] == nil || boardArray[column,row] == color {
                    let changeColor = SKAction.colorize(with: color.withAlphaComponent(0.5), colorBlendFactor: 1.0, duration: 0.3)
                    let changeColorBack = SKAction.colorize(with: ColorCategory.TileColor, colorBlendFactor: 1.0, duration: 0.3)
                    if !targetTileNode.hasActions(){
                        targetTileNode.run(SKAction.sequence([changeColor,changeColorBack]))
                    }
                }
            }
        }
    }
    
    func highlightDiag2(color: SKColor?) {
        numMatchingThisRound = numMatchingThisRound + 1
        
        for row in 0..<NumRows{
            for column in Int(row/3)*3..<Int(row/3)*3+3 {
                if boardLayer.childNode(withName: "tile\(column)\(row)") == nil {
                    continue
                }
                let targetTileNode: TileNode = boardLayer.childNode(withName: "tile\(column)\(row)") as! TileNode
                if let color = color, boardArray[column,row] == nil || boardArray[column,row] == color {
                    let changeColor = SKAction.colorize(with: color.withAlphaComponent(0.5), colorBlendFactor: 1.0, duration: 0.3)
                    let changeColorBack = SKAction.colorize(with: ColorCategory.TileColor, colorBlendFactor: 1.0, duration: 0.3)
                    if !targetTileNode.hasActions(){
                        targetTileNode.run(SKAction.sequence([changeColor,changeColorBack]))
                    }
                }
            }
        }
    }

    func highlightSection(secCol:Int, secRow:Int, color: SKColor?) {
        numMatchingThisRound = numMatchingThisRound + 1
        
        for column in secCol*3..<secCol*3+3 {
            for row in secRow*3..<secRow*3+3 {
                if boardLayer.childNode(withName: "tile\(column)\(row)") == nil {
                    continue
                }
                let targetTileNode: TileNode = boardLayer.childNode(withName: "tile\(column)\(row)") as! TileNode
                if let color = color, boardArray[column,row] == nil || boardArray[column,row] == color {
                    let changeColor = SKAction.colorize(with: color.withAlphaComponent(0.5), colorBlendFactor: 1.0, duration: 0.3)
                    let changeColorBack = SKAction.colorize(with: ColorCategory.TileColor, colorBlendFactor: 1.0, duration: 0.3)
                    if !targetTileNode.hasActions(){
                        targetTileNode.run(SKAction.sequence([changeColor,changeColorBack]))
                    }
                }
            }
        }
    }
    
    func checkGameOverInSection(secCol: Int, secRow: Int) -> Bool {
        var cellArray = Array2D<Int>(columns: 3, rows: 3)
        
        for column in secCol*3..<secCol*3+3 {
            for row in secRow*3..<secRow*3+3 {
                if boardArray[column, row] != nil {
                    cellArray[Int(column)%3, Int(row)%3] = 1
                } else {
                    cellArray[Int(column)%3, Int(row)%3] = 0
                }
            }
        }
        
        // check if there's any available slot
        for child in gameLayer.children {
            // Case 1. One Block Node
            if child is OneBlockNode {
                for column in 0..<3 {
                    for row in 0..<3 {
                        if cellArray[column, row] == 0{
                            return false
                        }
                    }
                }
            }
            
            
            // Case 2. Two Block Node
            if child is TwoBlockNode {
                let bottomBlock = child as! TwoBlockNode
                let blockType = bottomBlock.getBlockType()
                
                switch blockType {
                case TwoBlockTypes.Type1:
                    for column in 0..<3 {
                        for row in 0..<3 {
                            if cellArray[column, row] == 0, cellArray[column+1, row] == 0 {
                                return false
                            }
                        }
                    }
                case TwoBlockTypes.Type2:
                    for column in 0..<3 {
                        for row in 0..<3 {
                            if cellArray[column, row] == 0, cellArray[column, row+1] == 0 {
                                return false
                            }
                        }
                    }
                }
            }
            
            // Case 3. Three Block Node
            if child is ThreeBlockNode {
                let bottomBlock = child as! ThreeBlockNode
                let blockType = bottomBlock.getBlockType()
                
                switch blockType {
                case ThreeBlockTypes.Type1:
                    for column in 0..<3 {
                        for row in 0..<3 {
                            if cellArray[column, row] == 0, cellArray[column+1, row] == 0, cellArray[column+2, row] == 0 {
                                return false
                            }
                        }
                    }
                case ThreeBlockTypes.Type2:
                    for column in 0..<3 {
                        for row in 0..<3 {
                            if cellArray[column, row] == 0, cellArray[column, row+1] == 0, cellArray[column, row+2] == 0 {
                                return false
                            }
                        }
                    }
                case ThreeBlockTypes.Type3:
                    for column in 0..<3 {
                        for row in 0..<3 {
                            if cellArray[column, row] == 0, cellArray[column+1, row] == 0, cellArray[column, row+1] == 0 {
                                return false
                            }
                        }
                    }
                case ThreeBlockTypes.Type4:
                    for column in 0..<3 {
                        for row in 0..<3 {
                            if cellArray[column, row] == 0, cellArray[column, row+1] == 0, cellArray[column+1, row+1] == 0 {
                                return false
                            }
                        }
                    }
                case ThreeBlockTypes.Type5:
                    for column in 0..<3 {
                        for row in 0..<3 {
                            if cellArray[column, row] == 0, cellArray[column+1, row] == 0, cellArray[column+1, row+1] == 0 {
                                return false
                            }
                        }
                    }
                case ThreeBlockTypes.Type6:
                    for column in 0..<3 {
                        for row in 0..<3 {
                            if cellArray[column, row] == 0, cellArray[column-1, row+1] == 0, cellArray[column, row+1] == 0 {
                                return false
                            }
                        }
                    }
                }
            }
            
            // Case 4. Four Block Node
            if child is FourBlockNode {
                let bottomBlock = child as! FourBlockNode
                let blockType = bottomBlock.getBlockType()
                
                switch blockType {
                case FourBlockTypes.Type1:
                    for column in 0..<3 {
                        for row in 0..<3 {
                            if cellArray[column, row] == 0, cellArray[column+1, row] == 0, cellArray[column, row+1] == 0, cellArray[column+1, row+1] == 0 {
                                return false
                            }
                        }
                    }
                case FourBlockTypes.Type2:
                    for column in 0..<3 {
                        for row in 0..<3 {
                            if cellArray[column, row] == 0, cellArray[column+1, row] == 0, cellArray[column+2, row] == 0, cellArray[column, row+1] == 0 {
                                return false
                            }
                        }
                    }
                case FourBlockTypes.Type3:
                    for column in 0..<3 {
                        for row in 0..<3 {
                            if cellArray[column, row] == 0, cellArray[column, row+1] == 0, cellArray[column, row+2] == 0, cellArray[column+1, row+2] == 0 {
                                return false
                            }
                        }
                    }
                case FourBlockTypes.Type4:
                    for column in 0..<3 {
                        for row in 0..<3 {
                            if cellArray[column, row] == 0, cellArray[column-2, row+1] == 0, cellArray[column-1, row+1] == 0, cellArray[column, row+1] == 0 {
                                return false
                            }
                        }
                    }
                case FourBlockTypes.Type5:
                    for column in 0..<3 {
                        for row in 0..<3 {
                            if cellArray[column, row] == 0, cellArray[column+1, row] == 0, cellArray[column+1, row+1] == 0, cellArray[column+1, row+2] == 0 {
                                return false
                            }
                        }
                    }
                case FourBlockTypes.Type6:
                    for column in 0..<3 {
                        for row in 0..<3 {
                            if cellArray[column, row] == 0, cellArray[column+1, row] == 0, cellArray[column+2, row] == 0, cellArray[column+2, row+1] == 0 {
                                return false
                            }
                        }
                    }
                case FourBlockTypes.Type7:
                    for column in 0..<3 {
                        for row in 0..<3 {
                            if cellArray[column, row] == 0, cellArray[column+1, row] == 0, cellArray[column, row+1] == 0, cellArray[column, row+2] == 0 {
                                return false
                            }
                        }
                    }
                case FourBlockTypes.Type8:
                    for column in 0..<3 {
                        for row in 0..<3 {
                            if cellArray[column, row] == 0, cellArray[column, row+1] == 0, cellArray[column+1, row+1] == 0, cellArray[column+2, row+1] == 0 {
                                return false
                            }
                        }
                    }
                case FourBlockTypes.Type9:
                    for column in 0..<3 {
                        for row in 0..<3 {
                            if cellArray[column, row] == 0, cellArray[column, row+1] == 0, cellArray[column, row+2] == 0, cellArray[column-1, row+2] == 0 {
                                return false
                            }
                        }
                    }
                case FourBlockTypes.Type10:
                    for column in 0..<3 {
                        for row in 0..<3 {
                            if cellArray[column, row] == 0, cellArray[column+1, row] == 0, cellArray[column+1, row+1] == 0, cellArray[column+2, row] == 0 {
                                return false
                            }
                        }
                    }
                case FourBlockTypes.Type11:
                    for column in 0..<3 {
                        for row in 0..<3 {
                            if cellArray[column, row] == 0, cellArray[column, row+1] == 0, cellArray[column+1, row+1] == 0, cellArray[column, row+2] == 0 {
                                return false
                            }
                        }
                    }
                case FourBlockTypes.Type12:
                    for column in 0..<3 {
                        for row in 0..<3 {
                            if cellArray[column, row] == 0, cellArray[column-1, row+1] == 0, cellArray[column, row+1] == 0, cellArray[column+1, row+1] == 0 {
                                return false
                            }
                        }
                    }
                case FourBlockTypes.Type13:
                    for column in 0..<3 {
                        for row in 0..<3 {
                            if cellArray[column, row] == 0, cellArray[column-1, row+1] == 0, cellArray[column, row+1] == 0, cellArray[column, row+2] == 0 {
                                return false
                            }
                        }
                    }
                }
            }
        }
            
        isGameOver = true
        return true
    }
    
    func checkGameOver() {
        
        var noPossibleMatch = true
        // check if game over
        for secCol in 0..<3 {
            for secRow in 0..<3 {
                if !checkGameOverInSection(secCol: secCol, secRow: secRow) {
                    noPossibleMatch = false
                }
            }
        }
        
        if noPossibleMatch {
            print("Game Over")
            gameOver()
        }
        
    }
    
    func gameOver() {
        let myScene = GameScene(size: self.size)
        myScene.scaleMode = self.scaleMode
        let reveal = SKTransition.fade(withDuration: 0.5)
        
        self.view?.presentScene(myScene, transition: reveal)
        return
    }
    
    func shakeCamera(layer:SKNode, duration:Float, magnitude: CGFloat) {
        let amplitudeX:CGFloat = 10.0 * magnitude;
        let amplitudeY:CGFloat = 6.0 * magnitude;
        let numberOfShakes = duration / 0.04;
        var actionsArray:[SKAction] = [];
        for _ in 1...Int(numberOfShakes) {
            let moveX = CGFloat(arc4random_uniform(UInt32(amplitudeX))) - amplitudeX/2.0
            let moveY = CGFloat(arc4random_uniform(UInt32(amplitudeY))) - amplitudeY/2.0
            let shakeAction = SKAction.moveBy(x: CGFloat(moveX), y: CGFloat(moveY), duration: 0.02)
            shakeAction.timingMode = SKActionTimingMode.easeOut
            actionsArray.append(shakeAction)
            actionsArray.append(shakeAction.reversed())
        }
        
        let actionSeq = SKAction.sequence(actionsArray);
        layer.run(actionSeq);
    }
    
    //MARK:- Pause Menu Handling
    func pauseGame()
    {
        gameLayer.isPaused = true
        self.addChild(pauseLayer)
        pauseLayer.name = "pauselayer"
    }
    
    func unpauseGame()
    {
        gameLayer.isPaused = fa
        pauseLayer.removeFromParent()
    }
    
    //MARK:- Helper Functions
    func debugDrawArea(rect drawRect: CGRect) {
        let shape = SKShapeNode(rect: drawRect)
        shape.strokeColor = SKColor.red
        shape.lineWidth = 2.0
        gameLayer.addChild(shape)
    }
}
