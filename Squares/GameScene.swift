//
//  GameScene.swift
//  Squares
//
//  Created by Alan Lou on 12/20/17.
//  Copyright © 2017 Rawwr Studios. All rights reserved.
//

import SpriteKit
import Photos

class GameScene: SKScene, MenuButtonDelegate, PauseButtonDelegate, RecallButtonDelegate, EyeButtonDelegate, PlayButtonDelegate, OneBlockNodeDelegate, TwoBlockNodeDelegate, ThreeBlockNodeDelegate, FourBlockNodeDelegate, Alertable {
    
    // super node containing the layers
    let gameLayer = SKNode()
    let boardLayer = SKNode()
    let pauseLayer = SKNode()
    let gameOverLayer = SKNode()
    
    // board 2D array
    var boardArray = Array2D<SKColor>(columns: 9, rows: 9)
    var previousBoardArray = Array2D<SKColor>(columns: 9, rows: 9)
    
    // nodes
    let pauseButtonNode: PauseButtonNode
    let recallButtonNode: RecallButtonNode
    let gameScoreNode = GameScoreNode()
    let comboNode = ComboNode()
    let bestScoreNode = BestScoreNode()
    var newBestRibbon: NewBestRibbonNode?
    
    // numbers
    let NumColumns: Int = 9
    let NumRows: Int = 9
    var bottomBlockNum: Int = 3
    
    // variables
    let boardSpacing: CGFloat
    let sectionSpacing: CGFloat
    let cellSpacing: CGFloat
    let boardRect: CGRect!
    let boardInset: CGFloat
    var safeAreaRect: CGRect!
    let tileWidth: CGFloat
    var gameScore: Int = 0
    var combo: Int = 0
    var numMatchingThisRound: Int = 0
    var bottomBlockArray = [SKSpriteNode?](repeating: nil, count: 3)
    var bottomBlockJustPut: SKSpriteNode?
    var previousReleasePositions = Array<CGPoint>()
    var previousPoint: Int = 0
    var previousCombo: Int = 0
    var postImage: UIImage?
    
    // booleans
    var isAdReady: Bool = false
    var isGameOver: Bool = false
    var isBestScore: Bool = false
    var isGamePaused: Bool = false
    var isPhotoPermission: Bool = false
    
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
    var adsHeight: CGFloat {
        get {
            return CGFloat(UserDefaults.standard.float(forKey: "AdsHeight"))
        }
    }
    
    // sharing actions
    let findMatchingSound1: SKAction = SKAction.playSoundFileNamed(
        "findMatching1.wav", waitForCompletion: false)
    let findMatchingSound2: SKAction = SKAction.playSoundFileNamed(
        "findMatching2.mp3", waitForCompletion: false)
    let findMatchingSound3: SKAction = SKAction.playSoundFileNamed(
        "findMatching3.mp3", waitForCompletion: false)
    let findMatchingSound4: SKAction = SKAction.playSoundFileNamed(
        "findMatching4.mp3", waitForCompletion: false)
    let findMatchingSound5: SKAction = SKAction.playSoundFileNamed(
        "findMatching5.mp3", waitForCompletion: false)
    
    let addBottomBlocksSound: SKAction = SKAction.playSoundFileNamed(
        "addBottomBlocks.wav", waitForCompletion: false)
    let blockIsSetSound: SKAction = SKAction.playSoundFileNamed(
        "blockIsSet.m4a", waitForCompletion: false)
    let blockIsNotSetSound: SKAction = SKAction.playSoundFileNamed(
        "blockIsNotSet.wav", waitForCompletion: false)
    let buttonPressedSound: SKAction = SKAction.playSoundFileNamed(
        "buttonPressed.wav", waitForCompletion: false)
    
    //MARK:- Initialization
    override init(size: CGSize) {
        // pre-defined numbers
        let boardWidth = min(size.width, size.height*0.6)
        boardSpacing = boardWidth/15.0
        sectionSpacing = boardWidth/20.0
        cellSpacing = boardWidth/150.0
        boardRect = CGRect(x:0, y:size.height/2-size.width/2, width:boardWidth, height:boardWidth)
        boardInset = (size.width - boardWidth)/2.0
        tileWidth = (boardRect.size.width - boardSpacing*2.0 - sectionSpacing*2.0 - cellSpacing*6.0)/9.0
        // buttons
        let buttonWidth = min(size.width/13, size.height*0.6/13)
        pauseButtonNode = PauseButtonNode(color: ColorCategory.PauseButtonColor, width: buttonWidth)
        recallButtonNode = RecallButtonNode(color: ColorCategory.RecallButtonColor, width: buttonWidth)
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }
    
    override func didMove(to view: SKView) {
        self.backgroundColor = ColorCategory.BackgroundColor
        self.view?.isMultipleTouchEnabled = false
    
        let safeSets = view.safeAreaInsets
        safeAreaRect = CGRect(x: safeSets.left,
                              y: safeSets.bottom,
                              width: size.width-safeSets.right-safeSets.left,
                              height: size.height-safeSets.top-safeSets.bottom-adsHeight)
        
        /*** set up game layer ***/
        self.addChild(gameLayer)
        
        /*** set up board layer ***/
        boardLayer.position = CGPoint(x: boardInset+boardRect.minX, y: boardInset+boardRect.minY)
        boardLayer.name = "boardlayer"
        gameLayer.addChild(boardLayer)
        
        /*** add tiles and bottom blocks ***/
        addTiles()
        addBottomBlocks()
        
        /*** set up best score node ***/
        let bestScoreNodeHeightInitial = pauseButtonNode.size.height/1.5
        let bestScoreNodeHeight = bestScoreNodeHeightInitial*0.8
        let bestScoreNodeWidth = bestScoreNodeHeight*3
        let bestScoreNodeFrame = CGRect(x: safeAreaRect.width-bestScoreNodeWidth-pauseButtonNode.size.height/6, y: safeAreaRect.minY+safeAreaRect.height-bestScoreNodeHeight-pauseButtonNode.size.height/6-bestScoreNodeHeightInitial*0.1, width: bestScoreNodeWidth, height: bestScoreNodeHeight)
        bestScoreNode.adjustLabelFontSizeToFitRectRight(rect: bestScoreNodeFrame)
        //debugDrawArea(rect: bestScoreNodeFrame)
        gameLayer.addChild(bestScoreNode)
        
        /*** set up game score node ***/
        let gameScoreNodeWidth = safeAreaRect.width/3
        let gameScoreNodeHeight = (safeAreaRect.height/2-boardRect.size.height/2)*0.33
        let gameScoreNodeFrame = CGRect(x: safeAreaRect.width/2-gameScoreNodeWidth/2, y: (safeAreaRect.maxY + boardRect.maxY)/2-gameScoreNodeHeight/2+boardSpacing-gameScoreNodeHeight*0.4, width: gameScoreNodeWidth, height: gameScoreNodeHeight)
        gameScoreNode.adjustLabelFontSizeToFitRect(rect: gameScoreNodeFrame)
        //debugDrawArea(rect: gameScoreNodeFrame)
        gameLayer.addChild(gameScoreNode)
        
        /*** set up combo node ***/
        let comboNodeWidth = safeAreaRect.width/3
        let comboNodeHeight = gameScoreNodeHeight*0.3
        let comboNodeFrame = CGRect(x: safeAreaRect.width/2-comboNodeWidth/2, y:gameScoreNodeFrame.minY-comboNodeHeight - 10, width: comboNodeWidth, height: comboNodeHeight)
        comboNode.adjustLabelFontSizeToFitRect(rect: comboNodeFrame)
        //debugDrawArea(rect: comboNodeFrame)
        gameLayer.addChild(comboNode)
        
        /*** set up pause button and pause area ***/
        // set up pause button node
        pauseButtonNode.buttonDelegate = self
        pauseButtonNode.anchorPoint = CGPoint(x:0.0, y:1.0)
        pauseButtonNode.position = CGPoint(x:0, y:safeAreaRect.minY+safeAreaRect.height)
        gameLayer.addChild(pauseButtonNode)
        
        /*** set up recall button ***/
        recallButtonNode.buttonDelegate = self
        recallButtonNode.anchorPoint = CGPoint(x:0.0, y:1.0)
        recallButtonNode.position = CGPoint(x:pauseButtonNode.size.width, y:safeAreaRect.minY+safeAreaRect.height)
        recallButtonNode.isAdsRecallPossible = self.isAdReady
        gameLayer.addChild(recallButtonNode)
        
        /*** set up pause layer ***/
        // add white mask to background
        let blurBackgroundNode = SKSpriteNode(color: SKColor.white.withAlphaComponent(0.80), size: CGSize(width: safeAreaRect.width, height: safeAreaRect.height))
        blurBackgroundNode.zPosition = 5000
        blurBackgroundNode.position = CGPoint(x:safeAreaRect.width/2 ,y: safeAreaRect.height/2)
        pauseLayer.addChild(blurBackgroundNode)
        
        // add continue button
        let resumeButton = MenuButtonNode(color: ColorCategory.BlockColor1,
                                          buttonType: ButtonType.LongButton,
                                          iconType: IconType.ResumeButton,
                                          width: safeAreaRect.size.width/2)
        resumeButton.zPosition = 10000
        resumeButton.position = CGPoint(x: safeAreaRect.width/2,
                                        y: safeAreaRect.height/2 + 80)
        resumeButton.name = "resumebutton"
        resumeButton.buttonDelegate = self
        pauseLayer.addChild(resumeButton)
        
        // add restart button
        let restartButton = MenuButtonNode(color: ColorCategory.BlockColor2,
                                          buttonType: ButtonType.LongButton,
                                          iconType: IconType.RestartButton,
                                          width: safeAreaRect.size.width/2)
        restartButton.zPosition = 10000
        restartButton.position = CGPoint(x: safeAreaRect.width/2,
                                        y: safeAreaRect.height/2)
        restartButton.name = "restartbutton"
        restartButton.buttonDelegate = self
        pauseLayer.addChild(restartButton)
        
        // add home button
        let homeButton = MenuButtonNode(color: ColorCategory.BlockColor8,
                                        buttonType: ButtonType.ShortButton,
                                        iconType: IconType.HomeButton,
                                        width: safeAreaRect.size.width/4.4)
        homeButton.zPosition = 10000
        homeButton.position = CGPoint(x: safeAreaRect.width/2-resumeButton.size.width/2+homeButton.size.width/2,
                                      y: safeAreaRect.height/2 - 80)
        homeButton.name = "homebutton"
        homeButton.buttonDelegate = self
        pauseLayer.addChild(homeButton)
        
        // add sound button
        var iconTypeHere = IconType.SoundOnButton
        if let gameSoundOn = gameSoundOn {
            iconTypeHere = gameSoundOn ? IconType.SoundOnButton : IconType.SoundOffButton
        }
        let soundButton = MenuButtonNode(color: ColorCategory.BlockColor6,
                                         buttonType: ButtonType.ShortButton,
                                         iconType: iconTypeHere,
                                         width: safeAreaRect.size.width/4.4)
        soundButton.zPosition = 10000
        soundButton.position = CGPoint(x: safeAreaRect.width/2+resumeButton.size.width/2-homeButton.size.width/2,
                                       y: safeAreaRect.height/2 - 80)
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
        if let gameSoundOn = gameSoundOn, gameSoundOn {
            self.run(addBottomBlocksSound)
        }
        
        // set position
        let bottomBlockY = safeAreaRect.minY + safeAreaRect.height/4-boardRect.height/4 + boardSpacing/2
        let bottomBlockXLeft = (tileWidth+cellSpacing) + tileWidth/2 + boardSpacing
        let bottomBlockXMid = safeAreaRect.width/2
        let bottomBlockXRight = safeAreaRect.width - bottomBlockXLeft
        
        // create random index
        let randomIndex1 = CGFloat(arc4random()) / CGFloat(UInt32.max)
        let randomIndex2 = CGFloat(arc4random()) / CGFloat(UInt32.max)
        let randomIndex3 = CGFloat(arc4random()) / CGFloat(UInt32.max)
        
        
        let maxIndex: UInt32 = min(UInt32(6)+UInt32(gameScore/7), 9)
        
        let blockOneProb : CGFloat = 0.15
        let blockTwoProb : CGFloat = 0.27
        let blockThreeProb : CGFloat = 0.33
        
        // initialize block nodes
        if randomIndex1 <= blockOneProb {
            let bottomBlock1 = OneBlockNode(width: tileWidth, color: ColorCategory.randomBlockColor(maxIndex: maxIndex), position: CGPoint(x: bottomBlockXLeft, y: bottomBlockY))
            addSingleBottomBlock(bottomBlock: bottomBlock1)
            bottomBlockArray[0] = bottomBlock1
        } else if randomIndex1 <= blockOneProb + blockTwoProb{
            let bottomBlock1 = TwoBlockNode(width: tileWidth, color: ColorCategory.randomBlockColor(maxIndex: maxIndex), position: CGPoint(x: bottomBlockXLeft, y: bottomBlockY))
            addSingleBottomBlock(bottomBlock: bottomBlock1)
            bottomBlockArray[0] = bottomBlock1
        } else if randomIndex1 <= blockOneProb + blockTwoProb + blockThreeProb {
            let bottomBlock1 = ThreeBlockNode(width: tileWidth, color: ColorCategory.randomBlockColor(maxIndex: maxIndex), position: CGPoint(x: bottomBlockXLeft, y: bottomBlockY))
            addSingleBottomBlock(bottomBlock: bottomBlock1)
            bottomBlockArray[0] = bottomBlock1
        } else {
            let bottomBlock1 = FourBlockNode(width: tileWidth, color: ColorCategory.randomBlockColor(maxIndex: maxIndex), position: CGPoint(x: bottomBlockXLeft, y: bottomBlockY))
            addSingleBottomBlock(bottomBlock: bottomBlock1)
            bottomBlockArray[0] = bottomBlock1
        }
        
        if randomIndex2 <= blockOneProb {
            let bottomBlock2 = OneBlockNode(width: tileWidth, color: ColorCategory.randomBlockColor(maxIndex: maxIndex), position: CGPoint(x: bottomBlockXMid, y: bottomBlockY))
            addSingleBottomBlock(bottomBlock: bottomBlock2)
            bottomBlockArray[1] = bottomBlock2
        } else if randomIndex2 <= blockOneProb + blockTwoProb {
            let bottomBlock2 = TwoBlockNode(width: tileWidth, color: ColorCategory.randomBlockColor(maxIndex: maxIndex), position: CGPoint(x: bottomBlockXMid, y: bottomBlockY))
            addSingleBottomBlock(bottomBlock: bottomBlock2)
            bottomBlockArray[1] = bottomBlock2
        } else if randomIndex2 <= blockOneProb + blockTwoProb + blockThreeProb {
            let bottomBlock2 = ThreeBlockNode(width: tileWidth, color: ColorCategory.randomBlockColor(maxIndex: maxIndex), position: CGPoint(x: bottomBlockXMid, y: bottomBlockY))
            addSingleBottomBlock(bottomBlock: bottomBlock2)
            bottomBlockArray[1] = bottomBlock2
        } else {
            let bottomBlock2 = FourBlockNode(width: tileWidth, color: ColorCategory.randomBlockColor(maxIndex: maxIndex), position: CGPoint(x: bottomBlockXMid, y: bottomBlockY))
            addSingleBottomBlock(bottomBlock: bottomBlock2)
            bottomBlockArray[1] = bottomBlock2
        }
        
        if randomIndex3 <= blockOneProb {
            let bottomBlock3 = OneBlockNode(width: tileWidth, color: ColorCategory.randomBlockColor(maxIndex: maxIndex), position: CGPoint(x: bottomBlockXRight, y: bottomBlockY))
            addSingleBottomBlock(bottomBlock: bottomBlock3)
            bottomBlockArray[2] = bottomBlock3
        } else if randomIndex3 <= blockOneProb + blockTwoProb {
            let bottomBlock3 = TwoBlockNode(width: tileWidth, color: ColorCategory.randomBlockColor(maxIndex: maxIndex), position: CGPoint(x: bottomBlockXRight, y: bottomBlockY))
            addSingleBottomBlock(bottomBlock: bottomBlock3)
            bottomBlockArray[2] = bottomBlock3
        } else if randomIndex3 <= blockOneProb + blockTwoProb + blockThreeProb {
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
        
        // play sound
        if let gameSoundOn = gameSoundOn, gameSoundOn {
            self.run(blockIsSetSound)
        }
        
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
        
        // play sound
        if let gameSoundOn = gameSoundOn, gameSoundOn {
            self.run(blockIsSetSound)
        }
        
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
        
        // play sound
        if let gameSoundOn = gameSoundOn, gameSoundOn {
            self.run(blockIsSetSound)
        }
        
        
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
        
        // play sound
        if let gameSoundOn = gameSoundOn, gameSoundOn {
            self.run(blockIsSetSound)
        }
        
        
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
            if isGamePaused {
                unpauseGame()
                isGamePaused = false
            }
            return
        }
        if iconType == IconType.HomeButton  {
            if view != nil {
                let transition:SKTransition = SKTransition.fade(withDuration: 0.5)
                self.view?.presentScene(MenuScene(size: size), transition: transition)
            }
            return
        }
        if iconType == IconType.SoundOnButton  {
            gameSoundOn = true
            return
        }
        if iconType == IconType.SoundOffButton  {
            gameSoundOn = false
            return
        }
        if iconType == IconType.TwitterButton  {
            guard let url = URL(string: "https://mobile.twitter.com/rawwrstudios") else {
                return //be safe
            }
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
            return
        }
        if iconType == IconType.ShareButton  {
            //Photos
            let photos = PHPhotoLibrary.authorizationStatus()
            if photos == .notDetermined {
                PHPhotoLibrary.requestAuthorization({status in
                    if status == .authorized{
                        self.isPhotoPermission = true
                        self.presentShareSheet()
                        return
                    } else {}
                })
            } else if photos == .authorized {
                isPhotoPermission = true
                self.presentShareSheet()
            } else {
                showAlert(withTitle: "No Permission to Photos", message: "Giving permission will let you save and share game screenshots. This can be configured in Settings.")
            }
            
            return
        }
    }
    
    //MARK:- PauseButtonDelegate Func
    func pauseButtonWasPressed(sender: PauseButtonNode) {
        //isGamePaused = true
        //pauseGame()
        // for debugging
        self.postImage  = self.view!.pb_takeSnapshot()
         gameOver()
    }
    
    //MARK:- EyeButtonDelegate Func
    func eyeWasPressed(sender: QuarterCircleNode) {
        // play sound
        if let gameSoundOn = gameSoundOn, gameSoundOn {
            self.run(buttonPressedSound)
        }
        
        if !sender.getIsShowingTiles() {
            showAllTiles()
            let fadeOut = SKAction.fadeOut(withDuration: 0.5)
            for child in gameOverLayer.children {
                if child.name != "quartercircle" {
                    child.run(fadeOut)
                    child.isUserInteractionEnabled = false
                }
            }
            let fadeIn = SKAction.fadeIn(withDuration: 0.5)
            fadeIn.timingMode = .easeOut
            pauseButtonNode.run(fadeIn)
            recallButtonNode.run(fadeIn)
            bestScoreNode.run(fadeIn)
            gameScoreNode.run(fadeIn)
            comboNode.run(fadeIn)
        } else {
            hideAllTiles()
            let fadeIn = SKAction.fadeIn(withDuration: 0.5)
            for child in gameOverLayer.children {
                if child.name != "quartercircle" {
                    child.run(fadeIn)
                    child.isUserInteractionEnabled = true
                }
            }
            let fadeOut = SKAction.fadeOut(withDuration: 0.5)
            fadeOut.timingMode = .easeOut
            pauseButtonNode.run(fadeOut)
            recallButtonNode.run(fadeOut)
            bestScoreNode.run(fadeOut)
            gameScoreNode.run(fadeOut)
            comboNode.run(fadeOut)
        }
        
        sender.toggleIsShowingTiles()
    }

    //MARK:- PlayButtonDelegate
    
    func playButtonWasPressed(sender: PlayButtonNode) {
        if view != nil {
            let transition:SKTransition = SKTransition.fade(withDuration: 0.5)
            let gameScene = GameScene(size: self.size)
            self.view?.presentScene(gameScene, transition: transition)
        }
        return
    }
    
    //MARK:- RecallButtonDelegate Func
    func recallButtonWasPressed(sender: RecallButtonNode) {
        
        // play sound
        if let gameSoundOn = gameSoundOn, gameSoundOn {
            self.run(addBottomBlocksSound)
        }
        
        
        // remove all bottom blocks
        if self.bottomBlockNum == 3 {
            for index in 0..<3 {
                let bottomBlock = gameLayer.childNode(withName: "bottomBlock\(index)")
                if let bottomBlock = bottomBlock {
                    bottomBlock.run(SKAction.sequence([SKAction.scale(to: 0.0, duration: 0.1),
                                                       SKAction.removeFromParent()]))
                }
            }
        }
        
        combo = previousCombo
        gameScore = previousPoint
        comboNode.recallSetCombo(to: combo)
        gameScoreNode.recallSetGameScore(to: gameScore)
        
        // remove the block back
        if let bottomBlockJustPut = bottomBlockJustPut as? OneBlockNode {
            gameLayer.addChild(bottomBlockJustPut)
            
            let targetPosition = bottomBlockJustPut.getBlockPosition()
            bottomBlockJustPut.blockDelegate = self
            
            // animation
            let moveBack = SKAction.move(to: targetPosition, duration: 0.1)
            let scaleDown = SKAction.scale(to: 0.6, duration: 0.1) // lowScaleNum
            
            bottomBlockJustPut.run(SKAction.group([moveBack, scaleDown]), completion: {[weak self] in
                bottomBlockJustPut.isUserInteractionEnabled = true
                self?.bottomBlockNum = (self?.bottomBlockNum)!+1
                if (self?.bottomBlockNum)! > 3 {
                    self?.bottomBlockNum = 1
                }
            })
        }
        if let bottomBlockJustPut = bottomBlockJustPut as? TwoBlockNode {
            gameLayer.addChild(bottomBlockJustPut)
            
            let targetPosition = bottomBlockJustPut.getBlockPosition()
            bottomBlockJustPut.blockDelegate = self
            
            // animation
            let moveBack = SKAction.move(to: targetPosition, duration: 0.1)
            let scaleDown = SKAction.scale(to: 0.6, duration: 0.1) // lowScaleNum
            
            bottomBlockJustPut.run(SKAction.group([moveBack, scaleDown]), completion: {[weak self] in
                bottomBlockJustPut.isUserInteractionEnabled = true
                self?.bottomBlockNum = (self?.bottomBlockNum)!+1
                if (self?.bottomBlockNum)! > 3 {
                    self?.bottomBlockNum = 1
                }
            })
        }
        if let bottomBlockJustPut = bottomBlockJustPut as? ThreeBlockNode {
            gameLayer.addChild(bottomBlockJustPut)
            
            let targetPosition = bottomBlockJustPut.getBlockPosition()
            bottomBlockJustPut.blockDelegate = self
            
            // animation
            let moveBack = SKAction.move(to: targetPosition, duration: 0.1)
            let scaleDown = SKAction.scale(to: 0.6, duration: 0.1) // lowScaleNum
            
            bottomBlockJustPut.run(SKAction.group([moveBack, scaleDown]), completion: {[weak self] in
                bottomBlockJustPut.isUserInteractionEnabled = true
                self?.bottomBlockNum = (self?.bottomBlockNum)!+1
                if (self?.bottomBlockNum)! > 3 {
                    self?.bottomBlockNum = 1
                }
            })
        }
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
                if (self?.bottomBlockNum)! > 3 {
                    self?.bottomBlockNum = 1
                }
            })
        }
        
        
        // we can make a recall
        if sender.isRecallPossible {
            // make the recall not possible (can only recall one step)
            sender.isRecallPossible = false
            
            for colNum in 0..<NumColumns {
                for rowNum in 0..<NumRows {
                    boardArray[colNum, rowNum] = previousBoardArray[colNum, rowNum]
                    updateBlockCellColorAt(column: colNum, row: rowNum)
                }
            }
            
            for previousReleasePosition in previousReleasePositions {
                let (rowNum, colNum) = rowAndColFor(position: previousReleasePosition)
                
                /*** Update the tile color back to gray ***/
                if let colNum = colNum, let rowNum = rowNum {
                    boardArray[colNum, rowNum] = nil
                    updateBlockCellColorAt(column: colNum, row: rowNum)
                }
            }
            
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
        
        for colNum in 0..<NumColumns {
            for rowNum in 0..<NumRows {
                previousBoardArray[colNum, rowNum] = boardArray[colNum, rowNum]
            }
        }
        
        
        for index in 0..<3 {
            let bottomBlock = gameLayer.childNode(withName: "bottomBlock\(index)")
            bottomBlockArray[index] = bottomBlock as? SKSpriteNode
        }
        
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
        
        
        previousCombo = combo
        previousPoint = gameScore
        
        // reset combo
        if numMatchingThisRound > 0 {
            
            // increment combo
            combo = combo+numMatchingThisRound
            comboNode.setCombo(to: combo)
            
            // play sound
            if let gameSoundOn = gameSoundOn, gameSoundOn {
                switch combo {
                case 1:
                    self.run(findMatchingSound1)
                case 2:
                    self.run(findMatchingSound2)
                case 3:
                    self.run(findMatchingSound3)
                case 4:
                    self.run(findMatchingSound4)
                default:
                    self.run(findMatchingSound5)
                }
            }
            
            
            // update score
            gameScore = gameScore + numMatchingThisRound*combo
            gameScoreNode.setGameScore(to: gameScore)
            
            if comboNode.getCombo() > 1 {
                comboNode.run(SKAction.fadeIn(withDuration: 0.2))
            }
        } else {
            combo = 0
            comboNode.removeAllActions()
            comboNode.run(SKAction.fadeOut(withDuration: 0.2))
        }
        
        if combo > 1 {
            shakeCamera(layer: boardLayer, duration: 0.16, magnitude: CGFloat(combo))
        }
        
        numMatchingThisRound = 0
        // check high score
        if gameScore > bestScoreNode.getBestScore(), !isBestScore{
            isBestScore = true
            
            newBestRibbon = NewBestRibbonNode()
            newBestRibbon!.position = CGPoint(x: safeAreaRect.width + newBestRibbon!.size.width/2,
                                              y: safeAreaRect.height - newBestRibbon!.size.height/2-10)
            newBestRibbon!.zPosition = 200
            gameLayer.addChild(newBestRibbon!)
            
            // play sound
            let moveAction = SKAction.move(by: CGVector(dx: -newBestRibbon!.size.width, dy: 0), duration: 0.5)
            let wait = SKAction.wait(forDuration: 3.0)
            let moveBackAction = SKAction.move(by: CGVector(dx: newBestRibbon!.size.width, dy: 0), duration: 0.5)
            if let gameSoundOn = gameSoundOn {
                if gameSoundOn{
                    let newBestScoreSound = SKAction.playSoundFileNamed(
                        "newBestScore.wav", waitForCompletion: false)
                    newBestRibbon!.run(SKAction.sequence([SKAction.group([moveAction, newBestScoreSound]),wait, moveBackAction]))
                } else {
                    newBestRibbon!.run(SKAction.sequence([moveAction, wait, moveBackAction]))
                }
            }
        }
        
        // update best score label
        if isBestScore {
            bestScoreNode.setBestScore(to: gameScore)
        }// update best score
        
        
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
            self.run(SKAction.wait(forDuration: 1.0), completion: { [weak self] in
                self?.postImage  = self?.view?.pb_takeSnapshot()
                self?.gameOver()
            })
           
        }
        
    }
    
    func gameOver() {
        
        if let gameSoundOn = gameSoundOn, gameSoundOn {
            let gameOverSound: SKAction = SKAction.playSoundFileNamed(
                "gameOver.wav", waitForCompletion: false)
            self.run(gameOverSound)
        }
        
        // update high score if current game score is higher
        if gameScore >= bestScoreNode.getBestScore(){
            UserDefaults.standard.set(gameScore, forKey: "highScore")
            if let newBestRibbon = newBestRibbon {
                let moveBackAction = SKAction.move(by: CGVector(dx: newBestRibbon.size.width, dy: 0), duration: 0.5)
                newBestRibbon.run(moveBackAction)
            }
            // ask for review
            StoreReviewHelper.incrementAppHighScoreCount()
            StoreReviewHelper.checkAndAskForReview()
        }
        
        // remove all tiles
        hideAllTiles()
        
        // disable game layer action
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        fadeOut.timingMode = .easeOut
        pauseButtonNode.run(fadeOut)
        recallButtonNode.run(fadeOut)
        bestScoreNode.run(fadeOut)
        gameScoreNode.run(fadeOut)
        comboNode.run(fadeOut)
        
        pauseButtonNode.isUserInteractionEnabled = false
        recallButtonNode.isUserInteractionEnabled = false
        
        // present game over layer
        self.addChild(gameOverLayer)
        gameOverLayer.alpha = 0.0
       
        // set up game over node
        self.setUpGameOverNode()
        
        gameOverLayer.run(SKAction.fadeIn(withDuration: 1.0))
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
        
        let actionSeq = SKAction.sequence(actionsArray)
        layer.run(actionSeq)
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
        gameLayer.isPaused = false
        pauseLayer.removeFromParent()
    }
    
    func setUpGameOverNode() {
        
        let buttonFadeOut = SKAction.fadeAlpha(to: 0.2, duration: 1.0)
        buttonFadeOut.timingMode = .easeIn
        
        // add gameover title
        let gameOverTitleWidth = safeAreaRect.width*0.75
        let gameOverTitleHeight = gameOverTitleWidth*0.3
        let gameOverTitleFrame = CGRect(x: safeAreaRect.width/2 - gameOverTitleWidth/2, y: (view?.safeAreaInsets.bottom)!+safeAreaRect.height*0.8-gameOverTitleHeight/2, width: gameOverTitleWidth, height: gameOverTitleHeight)
        let gameOverTitle = MessageNode(message: "GAME OVER")
        gameOverTitle.adjustLabelFontSizeToFitRect(rect: gameOverTitleFrame)
        //debugDrawArea(rect: gameOverTitleFrame)
        gameOverLayer.addChild(gameOverTitle)
        
        // add restart button
        let restartButtonWidth = min(safeAreaRect.width/3,safeAreaRect.height/5)
        let restartButton = PlayButtonNode(color: ColorCategory.ContinueButtonColor, width: restartButtonWidth, type: PlayButtonType.RestartButton)
        restartButton.buttonDelegate = self
        restartButton.position = CGPoint(x: safeAreaRect.width/2,
                                      y: safeAreaRect.height/2-restartButton.size.height/2)
        gameOverLayer.addChild(restartButton)
        
        // Add eye node
        let quarterCircleNode = QuarterCircleNode(color: ColorCategory.HomeButtonColor, width: restartButtonWidth*0.6)
        quarterCircleNode.position = CGPoint(x: size.width-quarterCircleNode.size.width/2, y: quarterCircleNode.size.height/2)
        quarterCircleNode.buttonDelegate = self
        gameOverLayer.addChild(quarterCircleNode)
        
        /*** add best score node ***/
        // add best score boarder
        let bestScoreBarNode = BestScoreBarNode(color: ColorCategory.BestScoreFontColor.withAlphaComponent(0.55), width: restartButtonWidth*1.8)
        bestScoreBarNode.position = CGPoint(x: gameOverTitle.position.x,
                                            y: gameOverTitle.frame.minY - bestScoreBarNode.size.height*0.75)
        gameOverLayer.addChild(bestScoreBarNode)
        
        // add trophy
        let trophy = TrophyNode(color: ColorCategory.TrophyColor, height: bestScoreBarNode.size.height*0.63)
        trophy.anchorPoint = CGPoint(x:0.0, y:0.5)
        trophy.position = CGPoint(x: -bestScoreBarNode.size.width/2.0+bestScoreBarNode.size.height*0.16,
                                  y: 0.0)
        bestScoreBarNode.addChild(trophy)
        
        // add best score label
        let bestScoreNodeWidth = bestScoreBarNode.size.width/3.0
        let bestScoreNodeHeight = bestScoreBarNode.size.height/3.0
        let bestScoreLabelNodeFrame = CGRect(x: bestScoreBarNode.size.height*0.16-bestScoreNodeWidth/2, y: bestScoreBarNode.size.height/18.0, width: bestScoreNodeWidth, height: bestScoreNodeHeight)
        let bestScoreLabelNode = MessageNode(message: "BEST")
        bestScoreLabelNode.adjustLabelFontSizeToFitRect(rect: bestScoreLabelNodeFrame)
        bestScoreBarNode.addChild(bestScoreLabelNode)
        
        // add best score
        let bestScoreNodeFrame = CGRect(x: bestScoreBarNode.size.height*0.16-bestScoreNodeWidth/2, y: -bestScoreBarNode.size.height/18.0-bestScoreNodeHeight, width: bestScoreNodeWidth, height: bestScoreNodeHeight)
        let bestScoreNode = MessageNode(message: "\(self.bestScoreNode.getBestScore())")
        bestScoreNode.adjustLabelFontSizeToFitRect(rect: bestScoreNodeFrame)
        bestScoreBarNode.addChild(bestScoreNode)
        
        
        /*** add score label ***/
        let scoreNodeWidth = bestScoreBarNode.size.width
        let scoreNodeHeight = (bestScoreBarNode.frame.minY - restartButton.frame.maxY)*0.6
        let scoreLabelNodeFrame = CGRect(x: safeAreaRect.width/2-scoreNodeWidth/2, y: (bestScoreBarNode.frame.minY + restartButton.frame.maxY)/2 - scoreNodeHeight/2, width: scoreNodeWidth, height: scoreNodeHeight)
        let scoreLabelNode = MessageNode(message: "\(gameScore)")
        scoreLabelNode.adjustLabelFontSizeToFitRect(rect: scoreLabelNodeFrame)
        gameOverLayer.addChild(scoreLabelNode)
        
        /*** add buttons ***/
        let buttonWidth = restartButtonWidth/2.5
        let positionArmRadius = min(safeAreaRect.width/(2.0*cos(CGFloat.pi/6.0)) * 0.8 - buttonWidth*0.5, restartButtonWidth*1.2)
        
        // 1. Add Home button
        let homeButton = MenuButtonNode(color: ColorCategory.SoundButtonColor,
                                         buttonType: ButtonType.RoundButton,
                                         iconType: IconType.HomeButton,
                                         width: buttonWidth)
        homeButton.position = CGPoint(x: safeAreaRect.width/2-positionArmRadius*sin(CGFloat.pi*1/3),
                                       y: restartButton.position.y-positionArmRadius*cos(CGFloat.pi*1/3))
        homeButton.buttonDelegate = self
        gameOverLayer.addChild(homeButton)
        homeButton.removeAllActions()
        
        // 2. Add LeaderBoard button
        let leaderBoardButton = MenuButtonNode(color: ColorCategory.SoundButtonColor,
                                               buttonType: ButtonType.RoundButton,
                                               iconType: IconType.LeaderBoardButton,
                                               width: buttonWidth)
        leaderBoardButton.position = CGPoint(x: safeAreaRect.width/2-positionArmRadius*sin(CGFloat.pi/6.0),
                                             y: restartButton.position.y-positionArmRadius*cos(CGFloat.pi/6.0))
        leaderBoardButton.buttonDelegate = self
        gameOverLayer.addChild(leaderBoardButton)
        leaderBoardButton.removeAllActions()
        
        // 3. Add Share button
        let shareButton = MenuButtonNode(color: ColorCategory.SoundButtonColor,
                                               buttonType: ButtonType.RoundButton,
                                               iconType: IconType.ShareButton,
                                               width: buttonWidth)
        shareButton.position = CGPoint(x: safeAreaRect.width/2,
                                             y: restartButton.position.y-positionArmRadius)
        shareButton.buttonDelegate = self
        gameOverLayer.addChild(shareButton)
        
        // 4. Add twitter button
        let twitterButton = MenuButtonNode(color: ColorCategory.SoundButtonColor,
                                         buttonType: ButtonType.RoundButton,
                                         iconType: IconType.TwitterButton,
                                         width: buttonWidth)
        twitterButton.position = CGPoint(x: safeAreaRect.width/2+positionArmRadius*sin(CGFloat.pi/6.0),
                                       y: restartButton.position.y-positionArmRadius*cos(CGFloat.pi/6.0))
        twitterButton.buttonDelegate = self
        gameOverLayer.addChild(twitterButton)
        twitterButton.removeAllActions()
        
        // 5. Add NoAds button
        let noAdsButton = MenuButtonNode(color: ColorCategory.SoundButtonColor,
                                         buttonType: ButtonType.RoundButton,
                                         iconType: IconType.NoAdsButton,
                                         width: buttonWidth)
        noAdsButton.position = CGPoint(x: safeAreaRect.width/2+positionArmRadius*sin(CGFloat.pi*1/3),
                                       y: restartButton.position.y-positionArmRadius*cos(CGFloat.pi*1/3))
        noAdsButton.buttonDelegate = self
        gameOverLayer.addChild(noAdsButton)
        noAdsButton.removeAllActions()
        
        
        
    }
    
    func hideAllTiles() {
        let waitDuration: CGFloat = 0.05
        
        // top-left
        for column in 0..<NumColumns {
            let numNodes = column+1
            
            for row in numNodes-1 ..< NumRows {
                let targetTileNode: TileNode = boardLayer.childNode(withName: "tile\(column)\(row)") as! TileNode
                
                let waitMult = 8 - abs(row - column)
                let wait = SKAction.wait(forDuration: TimeInterval(CGFloat(waitMult)*waitDuration))
                let fadeOut = SKAction.fadeOut(withDuration: 0.15)
                targetTileNode.removeAllActions()
                targetTileNode.run(SKAction.sequence([wait, fadeOut]))
            }
        }
        // bottom-right
        for column in 1..<NumColumns {
            
            for row in 0 ..< column {
                let targetTileNode: TileNode = boardLayer.childNode(withName: "tile\(column)\(row)") as! TileNode
                
                let waitMult = abs(row - column)
                let wait = SKAction.wait(forDuration: TimeInterval(CGFloat(waitMult)*waitDuration+waitDuration*8.0))
                let fadeOut = SKAction.fadeOut(withDuration: 0.15)
                targetTileNode.removeAllActions()
                targetTileNode.run(SKAction.sequence([wait, fadeOut]))
            }
        }
        
        // remove blocks
        for index in 0..<3 {
            let bottomBlock = gameLayer.childNode(withName: "bottomBlock\(index)")
            let fadeOut = SKAction.fadeOut(withDuration: 0.2)
            let wait = SKAction.wait(forDuration: TimeInterval(CGFloat(10+index*3)*waitDuration))
            bottomBlock?.removeAllActions()
            bottomBlock?.isUserInteractionEnabled = false
            bottomBlock?.run(SKAction.sequence([wait, fadeOut]))
        }
    }
    
    func showAllTiles() {
        let waitDuration: CGFloat = 0.05
        
        // bottom-right
        for column in 1..<NumColumns {
            
            for row in 0 ..< column {
                let targetTileNode: TileNode = boardLayer.childNode(withName: "tile\(column)\(row)") as! TileNode
                
                let waitMult = 8 - abs(row - column)
                let wait = SKAction.wait(forDuration: TimeInterval(CGFloat(waitMult)*waitDuration))
                let fadeIn = SKAction.fadeIn(withDuration: 0.15)
                targetTileNode.removeAllActions()
                targetTileNode.run(SKAction.sequence([wait, fadeIn]))
            }
        }
        
        // top-left
        for column in 0..<NumColumns {
            let numNodes = column+1
            
            for row in numNodes-1 ..< NumRows {
                let targetTileNode: TileNode = boardLayer.childNode(withName: "tile\(column)\(row)") as! TileNode
                
                let waitMult = abs(row - column)
                let wait = SKAction.wait(forDuration: TimeInterval(CGFloat(waitMult)*waitDuration+waitDuration*8.0))
                let fadeIn = SKAction.fadeIn(withDuration: 0.15)
                targetTileNode.removeAllActions()
                targetTileNode.run(SKAction.sequence([wait, fadeIn]))
            }
        }
        
        // show blocks
        for index in 0..<3 {
            let bottomBlock = gameLayer.childNode(withName: "bottomBlock\(index)")
            let fadeIn = SKAction.fadeIn(withDuration: 0.2)
            let wait = SKAction.wait(forDuration: TimeInterval(CGFloat(6-index*3)*waitDuration))
            bottomBlock?.removeAllActions()
            bottomBlock?.run(SKAction.sequence([wait, fadeIn]))
        }
    }
    
    //MARK:- Helper Functions
    func debugDrawArea(rect drawRect: CGRect) {
        let shape = SKShapeNode(rect: drawRect)
        shape.strokeColor = SKColor.red
        shape.lineWidth = 2.0
        gameLayer.addChild(shape)
    }
    
    func presentShareSheet()
    {
        let postText: String = "Check out my score! I got \(gameScore) points in Squares! #Squares! #RawwrStudios"
        // append h ttps://itunes.apple.com/app/circle/id911152486
        var activityItems : [Any]
        if let postImage = postImage, isPhotoPermission{
            activityItems = [postText, postImage] as [Any]
        } else {
            activityItems = [postText]
        }
        
        let activityController = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        
        UIApplication.topViewController()?.present(
            activityController,
            animated: true,
            completion: nil
        )
    }
}
