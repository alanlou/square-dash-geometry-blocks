//
//  GameScene.swift
//  Squares
//
//  Created by Alan Lou on 12/20/17.
//  Copyright © 2017 Rawwr Studios. All rights reserved.
//

import SpriteKit
import GameKit
import Photos
import Firebase

class GameScene: SKScene, MenuButtonDelegate, PauseButtonDelegate, RecallButtonDelegate, EyeButtonDelegate, DismissButtonDelegate, SkinItemNodeDelegate, PlayButtonDelegate, OneBlockNodeDelegate, TwoBlockNodeDelegate, ThreeBlockNodeDelegate, FourBlockNodeDelegate, Alertable {
    
    // super node containing the layers
    let gameLayer = SKNode()
    let boardLayer = SKNode()
    let pauseLayer = SKNode()
    let gameOverLayer = SKNode()
    
    // board 2D array
    var boardArray: [[UInt32?]] = Array(repeating: Array(repeating: 0, count: 9), count: 9)
    var previousBoardArray: [[UInt32?]] = Array(repeating: Array(repeating: 0, count: 9), count: 9)
    
    // nodes
    let pauseButtonNode: PauseButtonNode
    let recallButtonNode: RecallButtonNode
    let gameScoreNode = GameScoreNode()
    let comboNode = ComboNode()
    let bestScoreNode = BestScoreNode()
    var newBestRibbon: NewBestRibbonNode?
    var orangeBackgroundBox: SKSpriteNode?
    
    // numbers
    let NumColumns: Int = 9
    let NumRows: Int = 9
    var bottomBlockNum: Int = 3
    let skinItemOffset:CGFloat = 7.5
    
    // variables
    let boardSpacing: CGFloat
    let sectionSpacing: CGFloat
    let cellSpacing: CGFloat
    let boardInset: CGFloat
    var boardRect: CGRect!
    var safeAreaRect: CGRect!
    var tileWidth: CGFloat!
    var bottomSafeSets: CGFloat!
    var gameScore: Int = 0
    var combo: Int = 0
    var numMatchingThisRound: Int = 0
    var bottomBlockArray = [SKSpriteNode?](repeating: nil, count: 3)
    var bottomBlockJustPut: SKSpriteNode?
    var previousReleasePositions = Array<CGPoint>()
    var previousPoint: Int = 0
    var previousCombo: Int = 0
    var postImage: UIImage?
    var isButtonEnabled = true
    
    // booleans
    var isAdReady: Bool = false
    var isGameOver: Bool = false
    var isBestScore: Bool = false
    var isGamePaused: Bool = false
    var isPhotoPermission: Bool = false
    
    // IAP Product
    var products = [SKProduct]()
    
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
        "Merge_matching_1.wav", waitForCompletion: false)
    let findMatchingSound2: SKAction = SKAction.playSoundFileNamed(
        "Merge_matching_2.wav", waitForCompletion: false)
    let findMatchingSound3: SKAction = SKAction.playSoundFileNamed(
        "Merge_matching_3.wav", waitForCompletion: false)
    let findMatchingSound4: SKAction = SKAction.playSoundFileNamed(
        "Merge_matching_4.wav", waitForCompletion: false)
    let findMatchingSound5: SKAction = SKAction.playSoundFileNamed(
        "Merge_matching_5.wav", waitForCompletion: false)
    let findMatchingSound6: SKAction = SKAction.playSoundFileNamed(
        "Merge_matching_6.wav", waitForCompletion: false)
    let findMatchingSound7: SKAction = SKAction.playSoundFileNamed(
        "Merge_matching_7.wav", waitForCompletion: false)
    let findMatchingSound8: SKAction = SKAction.playSoundFileNamed(
        "Merge_matching_8.wav", waitForCompletion: false)
    let findMatchingSound9: SKAction = SKAction.playSoundFileNamed(
        "Merge_matching_9.wav", waitForCompletion: false)
    
    let addBottomBlocksSound: SKAction = SKAction.playSoundFileNamed(
        "addBottomBlocks.wav", waitForCompletion: false)
    let blockIsSetSound: SKAction = SKAction.playSoundFileNamed(
        "blockIsSet.m4a", waitForCompletion: false)
    let blockIsNotSetSound: SKAction = SKAction.playSoundFileNamed(
        "blockIsNotSet.wav", waitForCompletion: false)
    let buttonPressedSound: SKAction = SKAction.playSoundFileNamed(
        "buttonPressed.wav", waitForCompletion: false)
    
    let comboVoiceSound1: SKAction = SKAction.playSoundFileNamed(
        "Aha.wav", waitForCompletion: false)
    let comboVoiceSound2: SKAction = SKAction.playSoundFileNamed(
        "Nice.wav", waitForCompletion: false)
    let comboVoiceSound3: SKAction = SKAction.playSoundFileNamed(
        "Fantastic.wav", waitForCompletion: false)
    let comboVoiceSound4: SKAction = SKAction.playSoundFileNamed(
        "Woohoo.wav", waitForCompletion: false)
    
    //MARK:- Initialization
    override init(size: CGSize) {
        // pre-defined numbers
        let boardWidth = min(size.width, size.height*0.6)
        boardSpacing = boardWidth/15.0
        sectionSpacing = boardWidth/20.0
        cellSpacing = boardWidth/150.0
        boardInset = (size.width - boardWidth)/2.0
        // buttons
        let buttonWidth = min(size.width/13, size.height*0.6/13)
        pauseButtonNode = PauseButtonNode(color: ColorCategory.getBestScoreFontColor(), width: buttonWidth)
        recallButtonNode = RecallButtonNode(color: ColorCategory.getBestScoreFontColor(), width: buttonWidth)
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }
    
    override func didMove(to view: SKView) {
        self.backgroundColor = ColorCategory.getBackgroundColor()
        self.view?.isMultipleTouchEnabled = false
    
        var safeSets:UIEdgeInsets
        if #available(iOS 11.0, *) {
            safeSets = view.safeAreaInsets
        } else {
            safeSets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        }
        safeAreaRect = CGRect(x: safeSets.left,
                              y: 0.0,
                              width: size.width-safeSets.right-safeSets.left,
                              height: size.height-safeSets.top-safeSets.bottom-adsHeight)
        //debugDrawArea(rect: safeAreaRect)
        
        // define board area
        let boardWidth = min(safeAreaRect.width, safeAreaRect.height*0.6)
        boardRect = CGRect(x:0, y:(safeAreaRect.height-boardWidth)*0.5, width:boardWidth, height:boardWidth)
        tileWidth = (CGFloat(boardRect.size.width) - boardSpacing*2.0 - sectionSpacing*2.0 - cellSpacing*6.0)/9.0
        //debugDrawArea(rect: boardRect)
        
        
        /*** set up game layer ***/
        bottomSafeSets = safeSets.bottom
        gameLayer.position = CGPoint(x: 0.0, y: bottomSafeSets)
        self.addChild(gameLayer)
        
        /*** set up board layer ***/
        boardLayer.position = CGPoint(x: (safeAreaRect.width-boardWidth)*0.5, y: boardRect.minY-bottomSafeSets)
        boardLayer.name = "boardlayer"
        gameLayer.addChild(boardLayer)
        
        /*** add tiles and bottom blocks ***/
        addTiles()
        
        /*** set up best score node ***/
        let bestScoreNodeHeightInitial = pauseButtonNode.size.height/1.5
        let bestScoreNodeHeight = bestScoreNodeHeightInitial*0.8
        let bestScoreNodeWidth = bestScoreNodeHeight*3.2
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
        
        /*** set up skin selection box ***/
        // add orangeBackgroundBox
        let skinNodeHeight:CGFloat = (safeAreaRect.height-skinItemOffset*5.0)*0.25
        orangeBackgroundBox = SKSpriteNode(texture: nil,
                                           color: ColorCategory.BlockColor9_Colorblind.withAlphaComponent(0.8),
                                           size: CGSize(width:safeAreaRect.width, height:skinNodeHeight+skinItemOffset*2))
        orangeBackgroundBox!.name = "orangeBackgroundBox"
        orangeBackgroundBox!.zPosition = 0
        orangeBackgroundBox!.anchorPoint = CGPoint(x:0.0, y:0.0)
        
        // add pin icon on top of orangeBackgroundBox
        let dismissButtionWidth = skinNodeHeight*0.25
        let pinIconNode = PinIconNode(color: ColorCategory.BlockColor9_Colorblind.withAlphaComponent(0.8),
                                      width: dismissButtionWidth*0.8)
        pinIconNode.zPosition = 20000
        pinIconNode.anchorPoint = CGPoint(x:1.0, y:1.0)
        pinIconNode.position = CGPoint(x:orangeBackgroundBox!.size.width-skinItemOffset-dismissButtionWidth*0.1,
                                       y:orangeBackgroundBox!.size.height-skinItemOffset-dismissButtionWidth*0.1)
        orangeBackgroundBox!.addChild(pinIconNode)
        
        /*** set up pause layer ***/
        // add white mask to background
        let blurBackgroundNode = SKSpriteNode(color: SKColor.white.withAlphaComponent(0.70), size: CGSize(width: size.width, height: size.height*1.2))
        blurBackgroundNode.zPosition = 5000
        blurBackgroundNode.position = CGPoint(x:size.width/2 ,y: size.height/2)
        pauseLayer.addChild(blurBackgroundNode)
        
        let verticleDistance = min(safeAreaRect.size.width*0.1818,safeAreaRect.size.height*0.1213)
        let buttonWidth = min(safeAreaRect.size.width*0.5,safeAreaRect.size.height*0.333)
        
        // add continue button
        let resumeButton = MenuButtonNode(color: ColorCategory.getBlockColorAtIndex(index: 1).withAlphaComponent(0.9),
                                          buttonType: ButtonType.LongButton,
                                          iconType: IconType.ResumeButton,
                                          width: buttonWidth)
        resumeButton.zPosition = 10000
        resumeButton.position = CGPoint(x: safeAreaRect.width/2,
                                        y: safeAreaRect.height/2 + verticleDistance*2.0)
        resumeButton.name = "resumebutton"
        resumeButton.buttonDelegate = self
        pauseLayer.addChild(resumeButton)
        
        // add restart button
        let restartButton = MenuButtonNode(color: ColorCategory.getBlockColorAtIndex(index: 2).withAlphaComponent(0.9),
                                          buttonType: ButtonType.LongButton,
                                          iconType: IconType.SmallRestartButton,
                                          width: buttonWidth)
        restartButton.zPosition = 10000
        restartButton.position = CGPoint(x: safeAreaRect.width/2,
                                        y: safeAreaRect.height/2 + verticleDistance)
        restartButton.name = "restartbutton"
        restartButton.buttonDelegate = self
        pauseLayer.addChild(restartButton)
        
        // add stop button
        let stopButton = MenuButtonNode(color: ColorCategory.getBlockColorAtIndex(index: 3).withAlphaComponent(0.9),
                                           buttonType: ButtonType.LongButton,
                                           iconType: IconType.StopButton,
                                           width: buttonWidth)
        stopButton.zPosition = 10000
        stopButton.position = CGPoint(x: safeAreaRect.width/2,
                                         y: safeAreaRect.height/2)
        stopButton.name = "stopbutton"
        stopButton.buttonDelegate = self
        pauseLayer.addChild(stopButton)
        
        // add skin button
        let skinButton = MenuButtonNode(color: ColorCategory.getBlockColorAtIndex(index: 4).withAlphaComponent(0.9),
                                        buttonType: ButtonType.LongButton,
                                        iconType: IconType.SkinButton,
                                        width: buttonWidth)
        skinButton.zPosition = 10000
        skinButton.position = CGPoint(x: safeAreaRect.width/2,
                                      y: safeAreaRect.height/2 - verticleDistance)
        skinButton.name = "skinbutton"
        skinButton.buttonDelegate = self
        pauseLayer.addChild(skinButton)
        
        
        // add home button
        let homeButton = MenuButtonNode(color: ColorCategory.getBlockColorAtIndex(index: 8).withAlphaComponent(0.9),
                                        buttonType: ButtonType.ShortButton,
                                        iconType: IconType.HomeButton,
                                        width: buttonWidth*0.4545)
        homeButton.zPosition = 10000
        homeButton.position = CGPoint(x: safeAreaRect.width/2-resumeButton.size.width/2+homeButton.size.width/2,
                                      y: safeAreaRect.height/2 - verticleDistance*2.0)
        homeButton.name = "homebutton"
        homeButton.buttonDelegate = self
        pauseLayer.addChild(homeButton)
        
        // add sound button
        var iconTypeHere = IconType.SoundOnButton
        if let gameSoundOn = gameSoundOn {
            iconTypeHere = gameSoundOn ? IconType.SoundOnButton : IconType.SoundOffButton
        }
        let soundButton = MenuButtonNode(color: ColorCategory.getBlockColorAtIndex(index: 6).withAlphaComponent(0.9),
                                         buttonType: ButtonType.ShortButton,
                                         iconType: iconTypeHere,
                                         width: buttonWidth*0.4545)
        soundButton.zPosition = 10000
        soundButton.position = CGPoint(x: safeAreaRect.width/2+resumeButton.size.width/2-homeButton.size.width/2,
                                       y: safeAreaRect.height/2 - verticleDistance*2.0)
        soundButton.name = "soundbutton"
        soundButton.buttonDelegate = self
        pauseLayer.addChild(soundButton)
        
        
        // add background color for dark theme
        let selectedSkin = UserDefaults.standard.object(forKey: "skin") as! String
        if selectedSkin == "Night" {
            resumeButton.changeIconNodeColor(to: ColorCategory.getBestScoreFontColor())
            restartButton.changeIconNodeColor(to: ColorCategory.getBestScoreFontColor())
            stopButton.changeIconNodeColor(to: ColorCategory.getBestScoreFontColor())
            skinButton.changeIconNodeColor(to: ColorCategory.getBestScoreFontColor())
            homeButton.changeIconNodeColor(to: ColorCategory.getBestScoreFontColor())
            soundButton.changeIconNodeColor(to: ColorCategory.getBestScoreFontColor())
        }
        
        // load saved game
        loadSavedGame()
        
        let isGameInProgress = UserDefaults.standard.bool(forKey: "gameInProgress")
        if isGameInProgress {
            //print("GAME IN PROGRESS!")
            addSavedBottomBlocks()
        } else {
            addBottomBlocks()
        }
        
        // Log Event
        Analytics.logEvent("start_game", parameters: [:])
        
    }
    
    //MARK:- Set Up Board
    func addTiles() {
        for row in 0..<NumRows {
            for col in 0..<NumColumns {
                let tileNode = TileNode(color: ColorCategory.getTileColor(), width:tileWidth)
                tileNode.position = pointInBoardLayerFor(column: col, row: row)
                tileNode.name = "tile\(col)\(row)"
                boardLayer.addChild(tileNode)
                boardArray[col][row] = nil
                previousBoardArray[col][row] = nil
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
        
        let blockOneProb : CGFloat = 0.12
        let blockTwoProb : CGFloat = 0.29
        let blockThreeProb : CGFloat = 0.34 // 1-0.12-0.29-0.34 = 0.25
        
        // initialize block nodes
        let randomColorIndex1 = UInt32(arc4random_uniform(maxIndex)) + 1
        if randomIndex1 <= blockOneProb {
            let bottomBlock1 = OneBlockNode(width: tileWidth, colorIndex: randomColorIndex1, position: CGPoint(x: bottomBlockXLeft, y: bottomBlockY), bottomIndex: 0)
            addSingleBottomBlock(bottomBlock: bottomBlock1)
            bottomBlockArray[0] = bottomBlock1
        } else if randomIndex1 <= blockOneProb + blockTwoProb{
            let bottomBlock1 = TwoBlockNode(width: tileWidth, colorIndex: randomColorIndex1, position: CGPoint(x: bottomBlockXLeft, y: bottomBlockY), bottomIndex: 0)
            addSingleBottomBlock(bottomBlock: bottomBlock1)
            bottomBlockArray[0] = bottomBlock1
        } else if randomIndex1 <= blockOneProb + blockTwoProb + blockThreeProb {
            let bottomBlock1 = ThreeBlockNode(width: tileWidth, colorIndex: randomColorIndex1, position: CGPoint(x: bottomBlockXLeft, y: bottomBlockY), bottomIndex: 0)
            addSingleBottomBlock(bottomBlock: bottomBlock1)
            bottomBlockArray[0] = bottomBlock1
        } else {
            let bottomBlock1 = FourBlockNode(width: tileWidth, colorIndex: randomColorIndex1, position: CGPoint(x: bottomBlockXLeft, y: bottomBlockY), bottomIndex: 0)
            addSingleBottomBlock(bottomBlock: bottomBlock1)
            bottomBlockArray[0] = bottomBlock1
        }
        
        let randomColorIndex2 = UInt32(arc4random_uniform(maxIndex)) + 1
        if randomIndex2 <= blockOneProb {
            let bottomBlock2 = OneBlockNode(width: tileWidth, colorIndex: randomColorIndex2, position: CGPoint(x: bottomBlockXMid, y: bottomBlockY), bottomIndex: 1)
            addSingleBottomBlock(bottomBlock: bottomBlock2)
            bottomBlockArray[1] = bottomBlock2
        } else if randomIndex2 <= blockOneProb + blockTwoProb {
            let bottomBlock2 = TwoBlockNode(width: tileWidth, colorIndex: randomColorIndex2, position: CGPoint(x: bottomBlockXMid, y: bottomBlockY), bottomIndex: 1)
            addSingleBottomBlock(bottomBlock: bottomBlock2)
            bottomBlockArray[1] = bottomBlock2
        } else if randomIndex2 <= blockOneProb + blockTwoProb + blockThreeProb {
            let bottomBlock2 = ThreeBlockNode(width: tileWidth, colorIndex: randomColorIndex2, position: CGPoint(x: bottomBlockXMid, y: bottomBlockY), bottomIndex: 1)
            addSingleBottomBlock(bottomBlock: bottomBlock2)
            bottomBlockArray[1] = bottomBlock2
        } else {
            let bottomBlock2 = FourBlockNode(width: tileWidth, colorIndex: randomColorIndex2, position: CGPoint(x: bottomBlockXMid, y: bottomBlockY), bottomIndex: 1)
            addSingleBottomBlock(bottomBlock: bottomBlock2)
            bottomBlockArray[1] = bottomBlock2
        }
        
        let randomColorIndex3 = UInt32(arc4random_uniform(maxIndex)) + 1
        if randomIndex3 <= blockOneProb {
            let bottomBlock3 = OneBlockNode(width: tileWidth, colorIndex: randomColorIndex3, position: CGPoint(x: bottomBlockXRight, y: bottomBlockY), bottomIndex: 2)
            addSingleBottomBlock(bottomBlock: bottomBlock3)
            bottomBlockArray[2] = bottomBlock3
        } else if randomIndex3 <= blockOneProb + blockTwoProb {
            let bottomBlock3 = TwoBlockNode(width: tileWidth, colorIndex: randomColorIndex3, position: CGPoint(x: bottomBlockXRight, y: bottomBlockY), bottomIndex: 2)
            addSingleBottomBlock(bottomBlock: bottomBlock3)
            bottomBlockArray[2] = bottomBlock3
        } else if randomIndex3 <= blockOneProb + blockTwoProb + blockThreeProb {
            let bottomBlock3 = ThreeBlockNode(width: tileWidth, colorIndex: randomColorIndex3, position: CGPoint(x: bottomBlockXRight, y: bottomBlockY), bottomIndex: 2)
            addSingleBottomBlock(bottomBlock: bottomBlock3)
            bottomBlockArray[2] = bottomBlock3
        } else {
            let bottomBlock3 = FourBlockNode(width: tileWidth, colorIndex: randomColorIndex3, position: CGPoint(x: bottomBlockXRight, y: bottomBlockY), bottomIndex: 2)
            addSingleBottomBlock(bottomBlock: bottomBlock3)
            bottomBlockArray[2] = bottomBlock3
        }
        
        for index in 0..<3 {
            bottomBlockArray[index]?.name = "bottomBlock\(index)"
        }
    }
    
    func addSavedBottomBlocks() {
        //print("addSavedBottomBlocks")
        // run sound
        if let gameSoundOn = gameSoundOn, gameSoundOn {
            self.run(addBottomBlocksSound)
        }
        
        // initialize block nodes
        let bottomBlock1 = bottomBlockArray[0]
        let bottomBlock2 = bottomBlockArray[1]
        let bottomBlock3 = bottomBlockArray[2]
        
        if let bottomBlock1 = bottomBlock1 {
            addSingleBottomBlock(bottomBlock: bottomBlock1)
        }
        if let bottomBlock2 = bottomBlock2 {
            addSingleBottomBlock(bottomBlock: bottomBlock2)
        }
        if let bottomBlock3 = bottomBlock3 {
            addSingleBottomBlock(bottomBlock: bottomBlock3)
        }
        
        for index in 0..<3 {
            if bottomBlockArray[index] != nil {
                bottomBlockArray[index]?.name = "bottomBlock\(index)"
            }
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
            if blockCellColorIndexAt(column: colNum, row: rowNum) != nil {
                // run sound
                if let gameSoundOn = gameSoundOn, gameSoundOn {
                    self.run(blockIsNotSetSound)
                }
                sender.setNodeAt(positionInScreen: nil)
                return
            }
            let positionInBoard = pointInBoardLayerFor(column: colNum, row: rowNum)
            let positionInScreen = CGPoint(x: positionInBoard.x + boardLayer.position.x - gameLayer.position.x,
                                           y: positionInBoard.y + boardLayer.position.y - gameLayer.position.y + bottomSafeSets)
            sender.setNodeAt(positionInScreen: positionInScreen)
            bottomBlockNum = bottomBlockNum-1
            
            // put new blocks
            //print("ADD BOTTOM BLOCK?")
            //print(bottomBlockNum)
            if bottomBlockNum == 0 {
                addBottomBlocks()
                bottomBlockNum = 3
            }
        } else {
            /*** put the block back to bottom ***/
            // run sound
            if let gameSoundOn = gameSoundOn, gameSoundOn {
                self.run(blockIsNotSetSound)
            }
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
            boardArray[colNum][rowNum] = sender.getBlockColorIndex()
            updateBlockCellColorAt(column: colNum, row: rowNum)
        }
        
        bottomBlockJustPut = sender
        recallButtonNode.setIsRecallPossibleNoFade(to: false)
        let wait = SKAction.wait(forDuration: 0.1)
        self.run(wait, completion: { [weak self] in
            self?.recallButtonNode.isRecallPossible = true
        })
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
                if blockCellColorIndexAt(column: colNum, row: rowNum) != nil {
                    // run sound
                    if let gameSoundOn = gameSoundOn, gameSoundOn {
                        self.run(blockIsNotSetSound)
                    }
                    sender.setNodeAt(positionsInScreen: nil)
                    return
                }
                
                // not in same section
                if secRow == -1 {
                    secRow = Int(rowNum/3)
                } else if secRow != Int(rowNum/3) {
                    // run sound
                    if let gameSoundOn = gameSoundOn, gameSoundOn {
                        self.run(blockIsNotSetSound)
                    }
                    sender.setNodeAt(positionsInScreen: nil)
                    return
                }
                if secCol == -1 {
                    secCol = Int(colNum/3)
                } else if secCol != Int(colNum/3) {
                    // run sound
                    if let gameSoundOn = gameSoundOn, gameSoundOn {
                        self.run(blockIsNotSetSound)
                    }
                    sender.setNodeAt(positionsInScreen: nil)
                    return
                }
                
                let positionInBoard = pointInBoardLayerFor(column: colNum, row: rowNum)
                let positionInScreen = CGPoint(x: positionInBoard.x + boardLayer.position.x - gameLayer.position.x,
                                               y: positionInBoard.y + boardLayer.position.y - gameLayer.position.y + bottomSafeSets)
                releasePositionsInScreen.append(positionInScreen)
                
                matchCount = matchCount+1
            } else {
                // not in right position. put back
                // run sound
                if let gameSoundOn = gameSoundOn, gameSoundOn {
                    self.run(blockIsNotSetSound)
                }
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
                boardArray[colNum][rowNum] = sender.getBlockColorIndex()
                updateBlockCellColorAt(column: colNum, row: rowNum)
            }
        }
        
        bottomBlockJustPut = sender
        recallButtonNode.setIsRecallPossibleNoFade(to: false)
        let wait = SKAction.wait(forDuration: 0.1)
        self.run(wait, completion: { [weak self] in
            self?.recallButtonNode.isRecallPossible = true
        })
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
                if blockCellColorIndexAt(column: colNum, row: rowNum) != nil {
                    // run sound
                    if let gameSoundOn = gameSoundOn, gameSoundOn {
                        self.run(blockIsNotSetSound)
                    }
                    sender.setNodeAt(positionsInScreen: nil)
                    return
                }
                
                // not in same section
                if secRow == -1 {
                    secRow = Int(rowNum/3)
                } else if secRow != Int(rowNum/3) {
                    // run sound
                    if let gameSoundOn = gameSoundOn, gameSoundOn {
                        self.run(blockIsNotSetSound)
                    }
                    sender.setNodeAt(positionsInScreen: nil)
                    return
                }
                if secCol == -1 {
                    secCol = Int(colNum/3)
                } else if secCol != Int(colNum/3) {
                    // run sound
                    if let gameSoundOn = gameSoundOn, gameSoundOn {
                        self.run(blockIsNotSetSound)
                    }
                    sender.setNodeAt(positionsInScreen: nil)
                    return
                }
                
                let positionInBoard = pointInBoardLayerFor(column: colNum, row: rowNum)
                let positionInScreen = CGPoint(x: positionInBoard.x + boardLayer.position.x - gameLayer.position.x,
                                               y: positionInBoard.y + boardLayer.position.y - gameLayer.position.y + bottomSafeSets)
                releasePositionsInScreen.append(positionInScreen)
                
                matchCount = matchCount+1
            } else {
                // not in right position. put back
                // run sound
                if let gameSoundOn = gameSoundOn, gameSoundOn {
                    self.run(blockIsNotSetSound)
                }
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
                boardArray[colNum][rowNum] = sender.getBlockColorIndex()
                updateBlockCellColorAt(column: colNum, row: rowNum)
            }
        }
        
        bottomBlockJustPut = sender
        recallButtonNode.setIsRecallPossibleNoFade(to: false)
        let wait = SKAction.wait(forDuration: 0.1)
        self.run(wait, completion: { [weak self] in
            self?.recallButtonNode.isRecallPossible = true
        })
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
                if blockCellColorIndexAt(column: colNum, row: rowNum) != nil {
                    // run sound
                    if let gameSoundOn = gameSoundOn, gameSoundOn {
                        self.run(blockIsNotSetSound)
                    }
                    sender.setNodeAt(positionsInScreen: nil)
                    return
                }
                
                // not in same section
                if secRow == -1 {
                    secRow = Int(rowNum/3)
                } else if secRow != Int(rowNum/3) {
                    // run sound
                    if let gameSoundOn = gameSoundOn, gameSoundOn {
                        self.run(blockIsNotSetSound)
                    }
                    sender.setNodeAt(positionsInScreen: nil)
                    return
                }
                if secCol == -1 {
                    secCol = Int(colNum/3)
                } else if secCol != Int(colNum/3) {
                    // run sound
                    if let gameSoundOn = gameSoundOn, gameSoundOn {
                        self.run(blockIsNotSetSound)
                    }
                    sender.setNodeAt(positionsInScreen: nil)
                    return
                }
                
                let positionInBoard = pointInBoardLayerFor(column: colNum, row: rowNum)
                let positionInScreen = CGPoint(x: positionInBoard.x + boardLayer.position.x - gameLayer.position.x,
                                               y: positionInBoard.y + boardLayer.position.y - gameLayer.position.y + bottomSafeSets)
                releasePositionsInScreen.append(positionInScreen)
                
                matchCount = matchCount+1
            } else {
                // not in right position. put back
                // run sound
                if let gameSoundOn = gameSoundOn, gameSoundOn {
                    self.run(blockIsNotSetSound)
                }
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
                boardArray[colNum][rowNum] = sender.getBlockColorIndex()
                updateBlockCellColorAt(column: colNum, row: rowNum)
            }
        }
        
        bottomBlockJustPut = sender
        recallButtonNode.setIsRecallPossibleNoFade(to: false)
        let wait = SKAction.wait(forDuration: 0.1)
        self.run(wait, completion: { [weak self] in
            self?.recallButtonNode.isRecallPossible = true
        })
        sender.removeFromParent()
        
        checkBoardAndUpdate()
    }
    
    //MARK:- MenuButtonDelegate Func
    func buttonWasPressed(sender: MenuButtonNode) {
        
        if !isButtonEnabled {
            return
        }
        
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
                saveBoard()
                let scene = MenuScene(size: size)
                scene.isAdReady = self.isAdReady
                let transition:SKTransition = SKTransition.fade(withDuration: 0.5)
                self.view?.presentScene(scene, transition: transition)
            }
            return
        }
        if iconType == IconType.SmallRestartButton  {
            if view != nil {
                clearSavedBoard()
                let scene = GameScene(size: size)
                scene.isAdReady = self.isAdReady
                let transition:SKTransition = SKTransition.fade(withDuration: 0.5)
                self.view?.presentScene(scene, transition: transition)
            }
            return
        }
        if iconType == IconType.StopButton  {
            unpauseGame()
            gameOver()
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
        if iconType == IconType.LikeButton {
            let userInfoDict:[String: String] = ["forButton": "like"]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "displayAlertMessage"), object: nil, userInfo: userInfoDict)
            return
        }
        if iconType == IconType.LeaderBoardButton {
            let userInfoDict:[String: String] = ["forButton": "leaderboard"]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "displayAlertMessage"), object: nil, userInfo: userInfoDict)
            return
        }
        if iconType == IconType.NoAdsButton  {
//            print("NoAdsButton")
            
            if !IAPHelper.canMakePayments() {
                let userInfoDict:[String: String] = ["forButton": "iapfail"]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "displayAlertMessage"), object: nil, userInfo: userInfoDict)
            }
            
            products = []
            IAPProducts.store.requestProducts{success, products in
                if success {
//                    print("NoAdsButton Success")
                    self.products = products!
                    let firstProduct = self.products[0] as SKProduct
                    IAPProducts.store.buyProduct(firstProduct)
                }
            }
            return
        }
        if iconType == IconType.SkinButton  {
            showSkinSelectionView()
            return
        }
            
    }
    
    //MARK:- PauseButtonDelegate Func
    func pauseButtonWasPressed(sender: PauseButtonNode) {
        isGamePaused = true
        pauseGame()
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
            gameScene.isAdReady = self.isAdReady
            self.view?.presentScene(gameScene, transition: transition)
        }
        return
    }
    
    //MARK:- DismissButtonNode Delegate
    func dismissButtonWasPressed(sender: DismissButtonNode) {
        // play sound
        if let gameSoundOn = gameSoundOn,
            gameSoundOn {
            self.run(buttonPressedSound)
        }
        
        let skinSelectionBackgroundNode = pauseLayer.childNode(withName: "skinSelectionBackgroundNode")
        
        if let skinSelectionBackgroundNode = skinSelectionBackgroundNode {
            // animate
            let moveUp = SKAction.move(to: CGPoint(x: 0.0, y: safeAreaRect.height*1.1-adsHeight), duration: 0.15)
            let moveDown = SKAction.move(to: CGPoint(x: 0.0, y: 0.0), duration: 0.32)
            moveDown.timingMode = .easeIn
            skinSelectionBackgroundNode.run(SKAction.sequence([moveUp,moveDown]), completion: { [weak self] in
                skinSelectionBackgroundNode.removeFromParent()
                self?.isButtonEnabled = true
                self?.orangeBackgroundBox?.removeFromParent()
            })
        }
        
        return
    }
    
    //MARK:- SkinItemNode Delegate
    func skinItemNodeWasReleased(sender: SkinItemNode, skinItem: String) {
        // play sound
        if let gameSoundOn = gameSoundOn,
            gameSoundOn {
            self.run(buttonPressedSound)
        }
        
        // select skin
        UserDefaults.standard.set(skinItem, forKey: "skin")
        
        // update color
        // 1. background
        self.backgroundColor = ColorCategory.getBackgroundColor()
        // 2. menu buttons
        for childNode in pauseLayer.children {
            if let menuButton = childNode as? MenuButtonNode {
                switch menuButton.name {
                case "resumebutton":
                    menuButton.changeColor(to: ColorCategory.getBlockColorAtIndex(index: 1))
                case "restartbutton":
                    menuButton.changeColor(to: ColorCategory.getBlockColorAtIndex(index: 2))
                case "stopbutton":
                    menuButton.changeColor(to: ColorCategory.getBlockColorAtIndex(index: 3))
                case "skinbutton":
                    menuButton.changeColor(to: ColorCategory.getBlockColorAtIndex(index: 4))
                case "homebutton":
                    menuButton.changeColor(to: ColorCategory.getBlockColorAtIndex(index: 8))
                case "soundbutton":
                    menuButton.changeColor(to: ColorCategory.getBlockColorAtIndex(index: 6))
                default:
                    menuButton.changeColor(to: .black)
                }
                menuButton.updateColor()
                if skinItem == "Night" {
                    menuButton.changeIconNodeColor(to: ColorCategory.getBestScoreFontColor())
                }
            }
        }
        //3. top nodes
        pauseButtonNode.changeColor(to: ColorCategory.getBestScoreFontColor())
        recallButtonNode.changeColor(to: ColorCategory.getBestScoreFontColor())
        bestScoreNode.setFontColor(color: ColorCategory.getBestScoreFontColor())
        gameScoreNode.setFontColor(color: ColorCategory.getBestScoreFontColor())
        comboNode.setFontColor(color: ColorCategory.getBestScoreFontColor())
        //4. tiles
        for colNum in 0..<NumColumns {
            for rowNum in 0..<NumRows {
                updateBlockCellColorAt(column: colNum, row: rowNum)
            }
        }
        //5. bottom blocks
        for index in 0..<3 {
            if let bottomBlock = gameLayer.childNode(withName: "bottomBlock\(index)")  as? SKSpriteNode {
                for childNode in bottomBlock.children {
                    if let blockCell = childNode as? BlockCellNode {
                        blockCell.updateCellColor()
                    }
                }
            }
        }
        
        // Update Selection Frame
        updateSkinItemFrame(skinItem: skinItem)
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
                self.bottomBlockArray[index] = nil
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
                let bottomBlockIndex = Int(bottomBlockJustPut.bottomIndex)
                self?.bottomBlockArray[bottomBlockIndex] = bottomBlockJustPut
                self?.bottomBlockArray[bottomBlockIndex]?.name = "bottomBlock\(bottomBlockIndex)"
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
                let bottomBlockIndex = Int(bottomBlockJustPut.bottomIndex)
                self?.bottomBlockArray[bottomBlockIndex] = bottomBlockJustPut
                self?.bottomBlockArray[bottomBlockIndex]?.name = "bottomBlock\(bottomBlockIndex)"
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
                let bottomBlockIndex = Int(bottomBlockJustPut.bottomIndex)
                self?.bottomBlockArray[bottomBlockIndex] = bottomBlockJustPut
                self?.bottomBlockArray[bottomBlockIndex]?.name = "bottomBlock\(bottomBlockIndex)"
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
                let bottomBlockIndex = Int(bottomBlockJustPut.bottomIndex)
                self?.bottomBlockArray[bottomBlockIndex] = bottomBlockJustPut
                self?.bottomBlockArray[bottomBlockIndex]?.name = "bottomBlock\(bottomBlockIndex)"
            })
        }
        
        
        // we can make a recall
        if sender.isRecallPossible {
            // make the recall not possible (can only recall one step)
            sender.isRecallPossible = false
            
            for colNum in 0..<NumColumns {
                for rowNum in 0..<NumRows {
                    boardArray[colNum][rowNum] = previousBoardArray[colNum][rowNum]
                    updateBlockCellColorAt(column: colNum, row: rowNum)
                }
            }
            
            for previousReleasePosition in previousReleasePositions {
                let (rowNum, colNum) = rowAndColFor(position: previousReleasePosition)
                
                /*** Update the tile color back to gray ***/
                if let colNum = colNum, let rowNum = rowNum {
                    boardArray[colNum][rowNum] = nil
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
            xCoord = CGFloat(column)*(tileWidth+cellSpacing) - cellSpacing + tileWidth*CGFloat(0.5) + boardSpacing + sectionSpacing
        case (6...8):
            xCoord = CGFloat(column)*(tileWidth+cellSpacing) - cellSpacing*CGFloat(2.0) + tileWidth*CGFloat(0.5) + boardSpacing + sectionSpacing*CGFloat(2.0)
        default: break
        }
        
        switch row {
        case (0...2):
            yCoord = CGFloat(row)*(tileWidth+cellSpacing) + tileWidth/2 + boardSpacing
        case (3...5):
            yCoord = CGFloat(row)*(tileWidth+cellSpacing) - cellSpacing + tileWidth*0.5 + boardSpacing + sectionSpacing
        case (6...8):
            yCoord = CGFloat(row)*(tileWidth+cellSpacing) - cellSpacing*CGFloat(2.0) + tileWidth*CGFloat(0.5) + boardSpacing + sectionSpacing*CGFloat(2.0)
        default: break
        }
        
        yCoord = yCoord+bottomSafeSets
        
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
    
    func blockCellColorIndexAt(column: Int, row: Int) -> UInt32? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return boardArray[column][row]
    }
    
    func sectionColAndRowFor(column: Int, row: Int) -> (Int, Int) {
        return (Int(column/3), Int(row/3))
    }
    
    func updateBlockCellColorAt(column: Int, row: Int) {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        
        // cell not filled
        if blockCellColorIndexAt(column: column, row: row) == nil {
            let targetTileNode: TileNode = boardLayer.childNode(withName: "tile\(column)\(row)") as! TileNode
            // update tile color
            targetTileNode.changeColor(to: ColorCategory.getTileColor())
            return
        }
        
        if let colorIndex = blockCellColorIndexAt(column: column, row: row) {
            let blockColor:SKColor? = ColorCategory.getBlockColorAtIndex(index: colorIndex)
            let targetTileNode: TileNode = boardLayer.childNode(withName: "tile\(column)\(row)") as! TileNode
            
            // update block cell color
            if let blockColor = blockColor {
                targetTileNode.changeColor(to: blockColor)
            } else {
                // reset block cell color
                targetTileNode.changeColor(to: ColorCategory.getTileColor())
            }
        }
    }
    
    /* this is called only when a block is set successfully in board */
    func checkBoardAndUpdate() {
        for colNum in 0..<NumColumns {
            for rowNum in 0..<NumRows {
                previousBoardArray[colNum][rowNum] = boardArray[colNum][rowNum]
            }
        }
        
        for index in 0..<3 {
            let bottomBlock = gameLayer.childNode(withName: "bottomBlock\(index)")
            bottomBlockArray[index] = bottomBlock as? SKSpriteNode
        }
        
        // initiate section color array
        var sectionArray = SetArray2D<Set<UInt32>>(columns: 3, rows: 3)
        for secRow in 0..<3 {
            for secCol in 0..<3 {
                sectionArray[secCol,secRow] = Set<UInt32>()
            }
        }
        
        // fill the section array with colors in each section
        for row in 0..<NumRows {
            for col in 0..<NumColumns {
                let tempColorIndex = blockCellColorIndexAt(column: col, row: row)
                let (secCol, secRow) = sectionColAndRowFor(column: col, row: row)
                // if there's a cell (color)
                if let tempColorIndex = tempColorIndex {
                    sectionArray[secCol, secRow]?.insert(tempColorIndex)
                }
            }
        }
        
        // iterate through each color index
        var matchedColorIndex: UInt32 = 0
        for blockColorIndex in ColorCategory.getBlockColorIndexArray() {
            // Case 1. Row Matching
            for secRow in 0..<3 {
                var matchCount = 0
                
                for secCol in 0..<3 {
                    let isColorMatching: Bool? = sectionArray[secCol, secRow]?.contains(blockColorIndex)
                    if let isColorMatching = isColorMatching, isColorMatching {
                        matchCount = matchCount + 1
                    }
                }
                
                // find a matching row
                if matchCount == 3 {
                    // highlight the matching row
                    highlightSecRow(secRow: secRow, colorIndex: blockColorIndex)
                    matchedColorIndex = blockColorIndex
                    
                    for column in 0..<NumColumns {
                        for row in secRow*3..<secRow*3+3 {
                            let matchingColorIndex = blockCellColorIndexAt(column: column, row: row)
                            if matchingColorIndex == blockColorIndex {
                                let targetTileNode: TileNode = boardLayer.childNode(withName: "tile\(column)\(row)") as! TileNode
                                boardArray[column][row] = nil
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
                    let isColorMatching: Bool? = sectionArray[secCol, secRow]?.contains(blockColorIndex)
                    if let isColorMatching = isColorMatching, isColorMatching {
                        matchCount = matchCount + 1
                    }
                }
                
                // find a matching column
                if matchCount == 3 {
                    // highlight the matching row
                    highlightSecCol(secCol: secCol, colorIndex: blockColorIndex)
                    matchedColorIndex = blockColorIndex
                    
                    for row in 0..<NumRows {
                        for column in secCol*3..<secCol*3+3 {
                            let matchingColorIndex = blockCellColorIndexAt(column: column, row: row)
                            if matchingColorIndex == blockColorIndex {
                                let targetTileNode: TileNode = boardLayer.childNode(withName: "tile\(column)\(row)") as! TileNode
                                boardArray[column][row] = nil
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
                
                let isColorMatching: Bool? = sectionArray[secCol, secRow]?.contains(blockColorIndex)
                if let isColorMatching = isColorMatching, isColorMatching {
                    matchCount = matchCount + 1
                }
            }
            if matchCount == 3 {
                // highlight the matching diagonal
                highlightDiag1(colorIndex: blockColorIndex)
                matchedColorIndex = blockColorIndex
                
                for row in 0..<NumRows{
                    for column in 6-Int(row/3)*3..<9-Int(row/3)*3 {
                        let matchingColorIndex = blockCellColorIndexAt(column: column, row: row)
                        
                        if matchingColorIndex == blockColorIndex {
                            let targetTileNode: TileNode = boardLayer.childNode(withName: "tile\(column)\(row)") as! TileNode
                            boardArray[column][row] = nil
                            removeTileNode(tileNode: targetTileNode)
                        }
                    }
                }
            }
            
            // Case 4. Diagonal Matching (/ Direction)
            matchCount = 0
            for secCol in 0..<3 {
                let secRow = secCol
                
                let isColorMatching: Bool? = sectionArray[secCol, secRow]?.contains(blockColorIndex)
                if let isColorMatching = isColorMatching, isColorMatching {
                    matchCount = matchCount + 1
                }
            }
            if matchCount == 3 {
                // highlight the matching diagonal
                highlightDiag2(colorIndex: blockColorIndex)
                matchedColorIndex = blockColorIndex
                
                for row in 0..<NumRows{
                    for column in Int(row/3)*3..<Int(row/3)*3+3 {
                        let matchingColorIndex = blockCellColorIndexAt(column: column, row: row)
                        if matchingColorIndex == blockColorIndex {
                            let targetTileNode: TileNode = boardLayer.childNode(withName: "tile\(column)\(row)") as! TileNode
                            boardArray[column][row] = nil
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
                            let matchingColorIndex = blockCellColorIndexAt(column: column, row: row)
                            
                            if matchingColorIndex == blockColorIndex {
                                matchCount = matchCount+1
                            }
                        }
                    }
                    
                    if matchCount == 9 {
                        // highlight the matching diagonal
                        highlightSection(secCol: secCol, secRow: secRow, colorIndex: blockColorIndex)
                        matchedColorIndex = blockColorIndex
                        
                        for column in secCol*3..<secCol*3+3 {
                            for row in secRow*3..<secRow*3+3 {
                                let targetTileNode: TileNode = boardLayer.childNode(withName: "tile\(column)\(row)") as! TileNode
                                boardArray[column][row] = nil
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
            let waitSound = SKAction.wait(forDuration: 0.1)
            if let gameSoundOn = gameSoundOn, gameSoundOn {
                switch combo {
                case 1:
                    self.run(findMatchingSound1)
                case 2:
                    self.run(SKAction.sequence([findMatchingSound2,waitSound,comboVoiceSound1]))
                case 3:
                    self.run(SKAction.sequence([findMatchingSound3,waitSound,comboVoiceSound2]))
                case 4:
                    self.run(SKAction.sequence([findMatchingSound4,waitSound,comboVoiceSound3]))
                case 5:
                    self.run(SKAction.sequence([findMatchingSound5,waitSound,comboVoiceSound4]))
                case 6:
                    self.run(SKAction.sequence([findMatchingSound6,waitSound,comboVoiceSound4]))
                case 7:
                    self.run(SKAction.sequence([findMatchingSound7,waitSound,comboVoiceSound4]))
                case 8:
                    self.run(SKAction.sequence([findMatchingSound8,waitSound,comboVoiceSound4]))
                default:
                    self.run(SKAction.sequence([findMatchingSound9,waitSound,comboVoiceSound4]))
                }
            }
            
            // display expression text
            var expressionText = ""
            switch combo {
            case 1:
                expressionText = ""
            case 2:
                expressionText = "Aha!"
            case 3:
                expressionText = "Nice!"
            case 4:
                expressionText = "Fantastic!"
            default:
                expressionText = "Woohoo!"
            }
            
            if combo >= 2 {
                let expressionTextNodeWidth = safeAreaRect.width/2
                let expressionTextNodeHeight = min((comboNode.frame.minY-boardRect.maxY+boardSpacing)*0.5,tileWidth*0.8)
                let expressionTextNodeFrame = CGRect(x: safeAreaRect.width/2-expressionTextNodeWidth/2,
                                                     y: (comboNode.frame.minY+boardRect.maxY-boardSpacing)/2-expressionTextNodeHeight/2,
                                                     width: expressionTextNodeWidth,
                                                     height: expressionTextNodeHeight)
                let expressionTextNode = MessageNode(message: expressionText)
                expressionTextNode.setFontColor(color: ColorCategory.getBlockColorAtIndex(index: matchedColorIndex))
                expressionTextNode.adjustLabelFontSizeToFitRect(rect: expressionTextNodeFrame)
                expressionTextNode.setScale(0.0)
                //debugDrawArea(rect: expressionTextNodeFrame)
                gameLayer.addChild(expressionTextNode)
                
                let duration1 = 0.3
                let duration2 = 0.1
                let duration3 = 0.3
                let scaleUp1 = SKAction.scale(to: 1.1, duration: duration1)
                let scaleDown1 = SKAction.scale(to: 1.0, duration: duration2)
                let wait = SKAction.wait(forDuration: duration3)
                let scaleUp2 = SKAction.scale(to: 1.1, duration: duration2)
                let scaleDown2 = SKAction.scale(to: 0.0, duration: duration1)
                scaleUp1.timingMode = .easeOut
                scaleDown2.timingMode = .easeIn
                expressionTextNode.run(SKAction.sequence([scaleUp1,scaleDown1,wait,scaleUp2,scaleDown2]), completion: {
                    expressionTextNode.removeFromParent()
                    })
                
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
            
            newBestRibbon = NewBestRibbonNode(height: bestScoreNode.frame.height*1.7)
            newBestRibbon!.position = CGPoint(x: safeAreaRect.width + newBestRibbon!.size.width/2,
                                              y: bestScoreNode.position.y)
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
        tileNode.changeColor(to: ColorCategory.getTileColor())
    }
    
    func highlightSecRow(secRow: Int, colorIndex: UInt32) {
        numMatchingThisRound = numMatchingThisRound + 1
        
        assert(secRow >= 0 && secRow < 3)
        for column in 0..<NumColumns {
            for row in secRow*3..<secRow*3+3 {
                if boardLayer.childNode(withName: "tile\(column)\(row)") == nil {
                    continue
                }
                let targetTileNode: TileNode = boardLayer.childNode(withName: "tile\(column)\(row)") as! TileNode
                if boardArray[column][row] == nil || boardArray[column][row] == colorIndex {
                    let changeColor = SKAction.colorize(with: ColorCategory.getBlockColorAtIndex(index: colorIndex).withAlphaComponent(0.5), colorBlendFactor: 1.0, duration: 0.3)
                    let changeColorBack = SKAction.colorize(with: ColorCategory.getTileColor(), colorBlendFactor: 1.0, duration: 0.3)
                    if !targetTileNode.hasActions(){
                        targetTileNode.run(SKAction.sequence([changeColor,changeColorBack]))
                    }
                }
            }
        }
    }
    
    func highlightSecCol(secCol: Int, colorIndex: UInt32) {
        numMatchingThisRound = numMatchingThisRound + 1
        
        assert(secCol >= 0 && secCol < 3)
        for row in 0..<NumRows {
            for column in secCol*3..<secCol*3+3 {
                if boardLayer.childNode(withName: "tile\(column)\(row)") == nil {
                    continue
                }
                let targetTileNode: TileNode = boardLayer.childNode(withName: "tile\(column)\(row)") as! TileNode
                if boardArray[column][row] == nil || boardArray[column][row] == colorIndex {
                    let changeColor = SKAction.colorize(with: ColorCategory.getBlockColorAtIndex(index: colorIndex).withAlphaComponent(0.5), colorBlendFactor: 1.0, duration: 0.3)
                    let changeColorBack = SKAction.colorize(with: ColorCategory.getTileColor(), colorBlendFactor: 1.0, duration: 0.3)
                    if !targetTileNode.hasActions(){
                        targetTileNode.run(SKAction.sequence([changeColor,changeColorBack]))
                    }
                }
            }
        }
    }
    
    func highlightDiag1(colorIndex: UInt32) {
        numMatchingThisRound = numMatchingThisRound + 1
        
        for row in 0..<NumRows{
            for column in 6-Int(row/3)*3..<9-Int(row/3)*3 {
                if boardLayer.childNode(withName: "tile\(column)\(row)") == nil {
                    continue
                }
                let targetTileNode: TileNode = boardLayer.childNode(withName: "tile\(column)\(row)") as! TileNode
                if boardArray[column][row] == nil || boardArray[column][row] == colorIndex {
                    let changeColor = SKAction.colorize(with: ColorCategory.getBlockColorAtIndex(index: colorIndex).withAlphaComponent(0.5), colorBlendFactor: 1.0, duration: 0.3)
                    let changeColorBack = SKAction.colorize(with: ColorCategory.getTileColor(), colorBlendFactor: 1.0, duration: 0.3)
                    if !targetTileNode.hasActions(){
                        targetTileNode.run(SKAction.sequence([changeColor,changeColorBack]))
                    }
                }
            }
        }
    }
    
    func highlightDiag2(colorIndex: UInt32) {
        numMatchingThisRound = numMatchingThisRound + 1
        
        for row in 0..<NumRows{
            for column in Int(row/3)*3..<Int(row/3)*3+3 {
                if boardLayer.childNode(withName: "tile\(column)\(row)") == nil {
                    continue
                }
                let targetTileNode: TileNode = boardLayer.childNode(withName: "tile\(column)\(row)") as! TileNode
                if boardArray[column][row] == nil || boardArray[column][row] == colorIndex {
                    let changeColor = SKAction.colorize(with: ColorCategory.getBlockColorAtIndex(index: colorIndex).withAlphaComponent(0.5), colorBlendFactor: 1.0, duration: 0.3)
                    let changeColorBack = SKAction.colorize(with: ColorCategory.getTileColor(), colorBlendFactor: 1.0, duration: 0.3)
                    if !targetTileNode.hasActions(){
                        targetTileNode.run(SKAction.sequence([changeColor,changeColorBack]))
                    }
                }
            }
        }
    }

    func highlightSection(secCol:Int, secRow:Int, colorIndex: UInt32) {
        numMatchingThisRound = numMatchingThisRound + 1
        
        for column in secCol*3..<secCol*3+3 {
            for row in secRow*3..<secRow*3+3 {
                if boardLayer.childNode(withName: "tile\(column)\(row)") == nil {
                    continue
                }
                let targetTileNode: TileNode = boardLayer.childNode(withName: "tile\(column)\(row)") as! TileNode
                if boardArray[column][row] == nil || boardArray[column][row] == colorIndex {
                    let changeColor = SKAction.colorize(with: ColorCategory.getBlockColorAtIndex(index: colorIndex).withAlphaComponent(0.5), colorBlendFactor: 1.0, duration: 0.3)
                    let changeColorBack = SKAction.colorize(with: ColorCategory.getTileColor(), colorBlendFactor: 1.0, duration: 0.3)
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
                if boardArray[column][row] != nil {
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
    
    func saveBoard() {
        //print("saveBoard()")
        if isGameOver {
            return
        }
        //print("saveBoard()2")
        
        //print("SAVE BOARD NOW")
        UserDefaults.standard.set(true, forKey: "gameInProgress")
        
        // save game board
        var encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: boardArray)
        UserDefaults.standard.set(encodedData, forKey: "boardArray")
        encodedData = NSKeyedArchiver.archivedData(withRootObject: previousBoardArray)
        UserDefaults.standard.set(encodedData, forKey: "previousBoardArray")
        encodedData = NSKeyedArchiver.archivedData(withRootObject: previousReleasePositions)
        UserDefaults.standard.set(encodedData, forKey: "previousReleasePositions")
        
        
        // save bottom blocks
        encodedData = NSKeyedArchiver.archivedData(withRootObject: bottomBlockArray)
        UserDefaults.standard.set(encodedData, forKey: "bottomBlockArray")
        if let bottomBlockJustPut = bottomBlockJustPut {
            encodedData = NSKeyedArchiver.archivedData(withRootObject: bottomBlockJustPut)
            UserDefaults.standard.set(encodedData, forKey: "bottomBlockJustPut")
        }
        
        // save recall variables
        UserDefaults.standard.set(recallButtonNode.isRecallPossible, forKey: "isRecallPossible")
        UserDefaults.standard.set(recallButtonNode.getNumRecall(), forKey: "numRecall")
        
        // save other variables
        UserDefaults.standard.set(gameScore, forKey: "gameScore")
        UserDefaults.standard.set(combo, forKey: "combo")
        UserDefaults.standard.set(previousPoint, forKey: "previousPoint")
        UserDefaults.standard.set(previousCombo, forKey: "previousCombo")
        UserDefaults.standard.set(bottomBlockNum, forKey: "bottomBlockNum")
        
    }
    
    func clearSavedBoard() {
        //print("clearSavedBoard()")
        // clear saved board
        UserDefaults.standard.set(false, forKey: "gameInProgress")
        UserDefaults.standard.set(nil, forKey: "boardArray")
        UserDefaults.standard.set(nil, forKey: "previousBoardArray")
        UserDefaults.standard.set(nil, forKey: "bottomBlockArray")
        UserDefaults.standard.set(nil, forKey: "bottomBlockJustPut")
        UserDefaults.standard.set(nil, forKey: "gameScore")
        UserDefaults.standard.set(nil, forKey: "combo")
        UserDefaults.standard.set(nil, forKey: "previousPoint")
        UserDefaults.standard.set(nil, forKey: "previousCombo")
        UserDefaults.standard.set(nil, forKey: "previousReleasePositions")
        UserDefaults.standard.set(nil, forKey: "bottomBlockNum")
        UserDefaults.standard.set(nil, forKey: "isRecallPossible")
        UserDefaults.standard.set(nil, forKey: "numRecall")
    }
    
    
    func gameOver() {
        if let gameSoundOn = gameSoundOn, gameSoundOn {
            let gameOverSound: SKAction = SKAction.playSoundFileNamed(
                "gameOver.wav", waitForCompletion: false)
            self.run(gameOverSound)
        }
        
        isGameOver = true
        clearSavedBoard()
        
        // update high score if current game score is higher
        if gameScore >= bestScoreNode.getBestScore(){
            UserDefaults.standard.set(gameScore, forKey: "highScore")
            Analytics.logEvent("new_highscore", parameters: [
                "highscore": gameScore as NSInteger
                ])
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
        gameOverLayer.position = CGPoint(x: 0.0, y: bottomSafeSets)
        self.addChild(gameOverLayer)
        gameOverLayer.alpha = 0.0
       
        // set up game over node
        self.setUpGameOverNode()
        
        gameOverLayer.run(SKAction.fadeIn(withDuration: 1.0))
        
        // push to leaderboard
        postToLeaderBoard(gameScore: gameScore)
        
        // show Interstitial Ads
        let noAdsPurchased = UserDefaults.standard.bool(forKey: "noAdsPurchased")
        if !noAdsPurchased,!StoreReviewHelper.isAskingForReviewThisRound(),gameScore>=30 {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "runInterstitialAds"), object: nil)
        }
        
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
    
    
    func loadSavedGame() {
        let isGameInProgress = UserDefaults.standard.bool(forKey: "gameInProgress")
        //print(isGameInProgress)
        if !isGameInProgress {
            return
        }
        
        // play sound
        if let gameSoundOn = gameSoundOn, gameSoundOn {
            self.run(addBottomBlocksSound)
        }
        
        //print("LOAD SAVED GAME!")
        //print(UserDefaults.standard.bool(forKey: "isRecallPossible"))
        
        // load saved variables
        combo = UserDefaults.standard.integer(forKey: "combo")
        gameScore = UserDefaults.standard.integer(forKey: "gameScore")
        comboNode.recallSetCombo(to: combo)
        gameScoreNode.recallSetGameScore(to: gameScore)
        previousCombo = UserDefaults.standard.integer(forKey: "previousCombo")
        previousPoint = UserDefaults.standard.integer(forKey: "previousPoint")
        bottomBlockNum = UserDefaults.standard.integer(forKey: "bottomBlockNum")
        recallButtonNode.setNumRecall(to: UserDefaults.standard.integer(forKey: "numRecall"))
        recallButtonNode.isRecallPossible = UserDefaults.standard.bool(forKey: "isRecallPossible")
        
        // load saved board
        var decoded  = UserDefaults.standard.object(forKey: "boardArray") as! Data
        boardArray = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! [[UInt32?]]
        decoded  = UserDefaults.standard.object(forKey: "previousBoardArray") as! Data
        previousBoardArray = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! [[UInt32?]]
        decoded  = UserDefaults.standard.object(forKey: "bottomBlockArray") as! Data
        bottomBlockArray = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! [SKSpriteNode?]
        decoded  = UserDefaults.standard.object(forKey: "previousReleasePositions") as! Data
        previousReleasePositions = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! Array<CGPoint>
        
        
        let decodedOptional  = UserDefaults.standard.object(forKey: "bottomBlockJustPut") as? Data
        if let decoded = decodedOptional {
            bottomBlockJustPut = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! SKSpriteNode?
        }
        
        
        // update board
        for colNum in 0..<NumColumns {
            for rowNum in 0..<NumRows {
                updateBlockCellColorAt(column: colNum, row: rowNum)
            }
        }
    
    }
    
    //MARK:- Pause Menu Handling
    func pauseGame()
    {
        self.postImage  = self.view?.pb_takeSnapshot()
        gameLayer.isPaused = true
        pauseLayer.position = CGPoint(x:0.0, y:bottomSafeSets)
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
        
        // add restart button
        let restartButtonWidth = min(safeAreaRect.width/3,safeAreaRect.height/5)
        let restartButton = PlayButtonNode(color: ColorCategory.getBlockColorAtIndex(index: 1), width: restartButtonWidth, type: PlayButtonType.RestartButton)
        restartButton.buttonDelegate = self
        restartButton.position = CGPoint(x: safeAreaRect.width/2,
                                      y: safeAreaRect.height/2-restartButton.size.height/2)
        gameOverLayer.addChild(restartButton)
        
        // Add eye node
        let quarterCircleNode = QuarterCircleNode(color: ColorCategory.getBlockColorAtIndex(index: 3), width: restartButtonWidth*0.6)
        quarterCircleNode.position = CGPoint(x: size.width-quarterCircleNode.size.width*0.5, y: quarterCircleNode.size.height*0.5-bottomSafeSets)
        quarterCircleNode.buttonDelegate = self
        gameOverLayer.addChild(quarterCircleNode)
        
        /*** add buttons ***/
        let buttonWidth = restartButtonWidth/2.5
        let positionArmRadius = min(safeAreaRect.width/(2.0*cos(CGFloat.pi/6.0)) * 0.8 - buttonWidth*0.5, restartButtonWidth*1.3)
        let buttonColor =  ColorCategory.getBlockColorAtIndex(index: 7)
        
        // 1. Add Home button
        let homeButton = MenuButtonNode(color: buttonColor,
                                         buttonType: ButtonType.RoundButton,
                                         iconType: IconType.HomeButton,
                                         width: buttonWidth)
        homeButton.position = CGPoint(x: safeAreaRect.width/2-positionArmRadius*sin(CGFloat.pi*1/3),
                                       y: restartButton.position.y-positionArmRadius*cos(CGFloat.pi*1/3))
        homeButton.buttonDelegate = self
        gameOverLayer.addChild(homeButton)
        homeButton.removeAllActions()
        
        // 2. Add LeaderBoard button
        let leaderBoardButton = MenuButtonNode(color: buttonColor,
                                               buttonType: ButtonType.RoundButton,
                                               iconType: IconType.LeaderBoardButton,
                                               width: buttonWidth)
        leaderBoardButton.position = CGPoint(x: safeAreaRect.width/2-positionArmRadius*sin(CGFloat.pi/6.0),
                                             y: restartButton.position.y-positionArmRadius*cos(CGFloat.pi/6.0))
        leaderBoardButton.buttonDelegate = self
        gameOverLayer.addChild(leaderBoardButton)
        leaderBoardButton.removeAllActions()
        
        // 3. Add Share button
        let shareButton = MenuButtonNode(color: buttonColor,
                                               buttonType: ButtonType.RoundButton,
                                               iconType: IconType.ShareButton,
                                               width: buttonWidth)
        shareButton.position = CGPoint(x: safeAreaRect.width/2,
                                             y: restartButton.position.y-positionArmRadius)
        shareButton.buttonDelegate = self
        gameOverLayer.addChild(shareButton)
        
        // 4. Add like button
        let likeButton = MenuButtonNode(color: buttonColor,
                                         buttonType: ButtonType.RoundButton,
                                         iconType: IconType.LikeButton,
                                         width: buttonWidth)
        likeButton.position = CGPoint(x: safeAreaRect.width/2+positionArmRadius*sin(CGFloat.pi/6.0),
                                       y: restartButton.position.y-positionArmRadius*cos(CGFloat.pi/6.0))
        likeButton.buttonDelegate = self
        gameOverLayer.addChild(likeButton)
        likeButton.removeAllActions()
        
        // 5. Add NoAds button
        let noAdsButton = MenuButtonNode(color: buttonColor,
                                         buttonType: ButtonType.RoundButton,
                                         iconType: IconType.NoAdsButton,
                                         width: buttonWidth)
        noAdsButton.position = CGPoint(x: safeAreaRect.width/2+positionArmRadius*sin(CGFloat.pi*1/3),
                                       y: restartButton.position.y-positionArmRadius*cos(CGFloat.pi*1/3))
        noAdsButton.buttonDelegate = self
        gameOverLayer.addChild(noAdsButton)
        noAdsButton.removeAllActions()
        
        /*** add gameover title ***/
        let gameOverTitleWidth = min(safeAreaRect.width*0.75,safeAreaRect.height*0.5)
        let gameOverTitleHeight = gameOverTitleWidth*0.3
        let gameOverTitleFrame = CGRect(x: safeAreaRect.width/2 - gameOverTitleWidth/2, y: safeAreaRect.height*0.87-gameOverTitleHeight/2, width: gameOverTitleWidth, height: gameOverTitleHeight)
        let gameOverTitle = MessageNode(message: "GAME OVER")
        gameOverTitle.adjustLabelFontSizeToFitRect(rect: gameOverTitleFrame)
        //debugDrawArea(rect: gameOverTitleFrame)
        gameOverLayer.addChild(gameOverTitle)
        
        /*** add best score node ***/
        // add best score boarder
        let bestScoreBarNode = BestScoreBarNode(color: ColorCategory.getBestScoreFontColor().withAlphaComponent(0.55), width: restartButtonWidth*1.8)
        bestScoreBarNode.position = CGPoint(x: gameOverTitle.position.x,
                                            y: gameOverTitle.frame.minY - bestScoreBarNode.size.height*0.90)
        gameOverLayer.addChild(bestScoreBarNode)
        
        // add trophy
        let trophy = TrophyNode(color: ColorCategory.getBlockColorAtIndex(index: 3), height: bestScoreBarNode.size.height*0.63)
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
    
    func animateNodesFadeIn() {
        /*** Animate nodeLayer ***/
        for nodeLayer in self.children {
            nodeLayer.alpha = 0.0
            nodeLayer.run(SKAction.fadeIn(withDuration: 0.2))
        }
    }
    
    func moveBackAllBottomBlocks() {
        for index in 0..<3 {
            if bottomBlockArray[index] != nil {
                if let tempBlockNode = bottomBlockArray[index] as? OneBlockNode {
                    tempBlockNode.setNodeAt(positionInScreen: nil)
                }
                if let tempBlockNode = bottomBlockArray[index] as? TwoBlockNode {
                    tempBlockNode.setNodeAt(positionsInScreen: nil)
                }
                if let tempBlockNode = bottomBlockArray[index] as? ThreeBlockNode {
                    tempBlockNode.setNodeAt(positionsInScreen: nil)
                }
                if let tempBlockNode = bottomBlockArray[index] as? FourBlockNode {
                    tempBlockNode.setNodeAt(positionsInScreen: nil)
                }
            }
        }
    }
    
    func presentShareSheet() {
        let postText: String = "Check out my score! I got \(gameScore) points in Square Dash! #SquareDash #RawwrStudios"
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
    
    //sends the highest score to leaderboard
    func postToLeaderBoard(gameScore: Int) {
        
//        print("SAVE HIGH SCORE!")
        
        if GKLocalPlayer.localPlayer().isAuthenticated {
            
            let scoreReporter = GKScore(leaderboardIdentifier: "com.RawwrStudios.Squares")
            scoreReporter.value = Int64(gameScore)
            let scoreArray: [GKScore] = [scoreReporter]
            
            GKScore.report(scoreArray, withCompletionHandler: {error -> Void in
                if error != nil {
//                    print("An error has occured: \(String(describing: error))")
                }
            })
        }
    }
    
    func showSkinSelectionView() {
        isButtonEnabled = false
        
        // calculate numbers first
        let skinNodeHeight:CGFloat = (safeAreaRect.height-skinItemOffset*5.0)*0.25
        let skinItemNode4 = SkinItemNode(width: safeAreaRect.width-skinItemOffset*2.0, height: skinNodeHeight, skin: "Colorblind")
        let skinFontSize:CGFloat = skinItemNode4.getFontSize()
        
        // add gray mask to background
        let skinSelectionBackgroundNode = SKSpriteNode(color: SKColor.gray, size: CGSize(width: safeAreaRect.width, height:  (skinNodeHeight+skinItemOffset)*5))
        skinSelectionBackgroundNode.zPosition = 25000
        skinSelectionBackgroundNode.name = "skinSelectionBackgroundNode"
        skinSelectionBackgroundNode.anchorPoint = CGPoint(x:0.0, y:1.0)
        skinSelectionBackgroundNode.position = CGPoint(x:0.0 ,y: 0.0)
        pauseLayer.addChild(skinSelectionBackgroundNode)
        
        // Add skin item nodes
        // upper layer
//        let upperMask = SKSpriteNode(color: SKColor.gray, size: CGSize(width: safeAreaRect.width, height: skinNodeHeight+skinItemOffset))
//        upperMask.zPosition = 5000
//        upperMask.anchorPoint = CGPoint(x:0.0, y:0.0)
//        upperMask.position = CGPoint(x:0.0 ,y: 0.0)
//        skinSelectionBackgroundNode.addChild(upperMask)
        
        // Skin 1. Classic
        let skinItemNode1 = SkinItemNode(width: safeAreaRect.width-skinItemOffset*2.0, height: skinNodeHeight, skin: "Classic")
        skinItemNode1.zPosition = 35000
        skinItemNode1.position = CGPoint(x: skinItemOffset, y: -skinNodeHeight-skinItemOffset)
        skinItemNode1.setFontSize(fontSize: skinFontSize)
        skinItemNode1.skinItemNodeDelegate = self
        skinSelectionBackgroundNode.addChild(skinItemNode1)
        // Skin 2. Day
        let skinItemNode2 = SkinItemNode(width: safeAreaRect.width-skinItemOffset*2.0, height: skinNodeHeight, skin: "Day")
        skinItemNode2.zPosition = 35000
        skinItemNode2.position = CGPoint(x: skinItemOffset, y: -skinNodeHeight*2-skinItemOffset*2)
        skinItemNode2.setFontSize(fontSize: skinFontSize)
        skinItemNode2.skinItemNodeDelegate = self
        skinSelectionBackgroundNode.addChild(skinItemNode2)
        // Skin 3. Night
        let skinItemNode3 = SkinItemNode(width: safeAreaRect.width-skinItemOffset*2.0, height: skinNodeHeight, skin: "Night")
        skinItemNode3.zPosition = 35000
        skinItemNode3.position = CGPoint(x: skinItemOffset, y: -skinNodeHeight*3-skinItemOffset*3)
        skinItemNode3.setFontSize(fontSize: skinFontSize)
        skinItemNode3.skinItemNodeDelegate = self
        skinSelectionBackgroundNode.addChild(skinItemNode3)
        // Skin 4. Day
        skinItemNode4.zPosition = 35000
        skinItemNode4.position = CGPoint(x: skinItemOffset, y: -skinNodeHeight*4-skinItemOffset*4)
        skinItemNode4.skinItemNodeDelegate = self
        skinSelectionBackgroundNode.addChild(skinItemNode4)
        
        // add orangeBackgroundBox
        if let orangeBackgroundBox = orangeBackgroundBox {
            skinSelectionBackgroundNode.addChild(orangeBackgroundBox)
            let selectedSkin = UserDefaults.standard.object(forKey: "skin") as! String
            updateSkinItemFrame(skinItem: selectedSkin)
        }
        
        // add dismiss button
        let dismissButton = DismissButtonNode(color: ColorCategory.BlockColor1_Day.withAlphaComponent(0.8), width: skinItemNode1.size.height*0.25)
        dismissButton.position = CGPoint(x:safeAreaRect.width-skinItemOffset*1.5 ,y: -safeAreaRect.height+skinItemOffset*1.5)
        dismissButton.zPosition = 40000
        dismissButton.buttonDelegate = self
        skinSelectionBackgroundNode.addChild(dismissButton)
        
        // animate
        let moveUp = SKAction.move(to: CGPoint(x: 0.0, y: safeAreaRect.height*1.1), duration: 0.32)
        let moveDown = SKAction.move(to: CGPoint(x: 0.0, y: safeAreaRect.height*0.97), duration: 0.15)
        let moveUpSmall = SKAction.move(to: CGPoint(x: 0.0, y: safeAreaRect.height), duration: 0.07)
        moveUp.timingMode = .easeOut
        skinSelectionBackgroundNode.run(SKAction.sequence([moveUp,moveDown,moveUpSmall]))
    }
    
    func updateSkinItemFrame(skinItem: String) {
        // calculate size
        let skinNodeHeight:CGFloat = (safeAreaRect.height-skinItemOffset*5.0)*0.25
        
        if let orangeBackgroundBox = orangeBackgroundBox {
            if skinItem == "Classic" {
                orangeBackgroundBox.position = CGPoint(x: 0.0, y: -skinNodeHeight-skinItemOffset*2)
            } else if skinItem == "Day" {
                orangeBackgroundBox.position = CGPoint(x: 0.0, y: -skinNodeHeight*2-skinItemOffset*3)
            } else if skinItem == "Night" {
                orangeBackgroundBox.position = CGPoint(x: 0.0, y: -skinNodeHeight*3-skinItemOffset*4)
            } else if skinItem == "Colorblind" {
                orangeBackgroundBox.position = CGPoint(x: 0.0, y: -skinNodeHeight*4-skinItemOffset*5)
            }
        }
    }
    
}
