//
//  TutorialScene.swift
//  Squares
//
//  Created by Alan Lou on 2/5/18.
//  Copyright © 2018 Rawwr Studios. All rights reserved.
//

import SpriteKit

class TutorialScene: SKScene, SkipButtonDelegate, OneBlockNodeDelegate, TwoBlockNodeDelegate, ThreeBlockNodeDelegate, FourBlockNodeDelegate {
    
    // super node containing the layers
    let gameLayer = SKNode()
    let boardLayer = SKNode()
    
    // board 2D array
    var boardArray = Array2D<SKColor>(columns: 9, rows: 9)
    
    // nodes
    var topMessageNode = MessageNode(message: "Welcome to Squares!")
    var bottomMessageNode = MessageNode(message: "Tap to Start Tutorial")
    
    // numbers
    let NumColumns: Int = 9
    let NumRows: Int = 9
    var bottomBlockNum: Int = 3
    var combo: Int = 0
    var progressIndex: Int = 0
    var messageIndex: Int = 0
    
    // variables
    let boardSpacing: CGFloat
    let sectionSpacing: CGFloat
    let cellSpacing: CGFloat
    let boardRect: CGRect!
    let boardInset: CGFloat
    var safeAreaRect: CGRect!
    let tileWidth: CGFloat
    var numMatchingThisRound: Int = 0
    var bottomBlockArray = [SKSpriteNode?](repeating: nil, count: 3)
    
    // booleans
    var isAdReady: Bool = false
    
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
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }
    
    override func didMove(to view: SKView) {
        self.backgroundColor = ColorCategory.BackgroundColor
        self.view?.isMultipleTouchEnabled = false
        
        var safeSets:UIEdgeInsets
        if #available(iOS 11.0, *) {
            safeSets = view.safeAreaInsets
        } else {
            safeSets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        }
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
        
        /*** add tiles ***/
        addInitialTiles()
        
        /*** set up skip node ***/
        let skipButtonNode = SkipButtonNode(color: ColorCategory.BestScoreFontColor, width: (safeAreaRect.height/2-boardRect.size.height/2)*0.3)
        skipButtonNode.position = CGPoint(x:safeAreaRect.width - skipButtonNode.size.width - 10, y: size.height-safeSets.top-adsHeight)
        skipButtonNode.buttonDelegate = self
        gameLayer.addChild(skipButtonNode)
        
        /*** set up top message node ***/
        let topMessageNodeWidth = safeAreaRect.width*0.75
        let topMessageNodeHeight = (safeAreaRect.height/2-boardRect.size.height/2)*0.3
        let topMessageNodeFrame = CGRect(x: safeAreaRect.width/2-topMessageNodeWidth/2, y: (safeAreaRect.maxY + boardRect.maxY)/2-topMessageNodeHeight/2+boardSpacing/2-topMessageNodeHeight*0.8, width: topMessageNodeWidth, height: topMessageNodeHeight)
        topMessageNode.adjustLabelFontSizeToFitRect(rect: topMessageNodeFrame)
        //debugDrawArea(rect: topMessageNodeFrame)
        gameLayer.addChild(topMessageNode)
        
        /*** set up bottom message node ***/
        let bottomMessageNodeWidth = safeAreaRect.width*0.5
        let bottomMessageNodeHeight = (size.height-size.width)*0.2
        let bottomMessageNodeFrame = CGRect(x: safeAreaRect.width/2-bottomMessageNodeWidth/2, y: boardRect.minY/2-bottomMessageNodeHeight/2+boardSpacing/2, width: bottomMessageNodeWidth, height: bottomMessageNodeHeight)
        bottomMessageNode.adjustLabelFontSizeToFitRect(rect: bottomMessageNodeFrame)
        //debugDrawArea(rect: bottomMessageNodeFrame)
        gameLayer.addChild(bottomMessageNode)
        
        // animate topMessageNode
        let wait = SKAction.wait(forDuration: 3.0)
        let scaleUp = SKAction.scale(to: 1.05, duration: 0.3)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.2)
        scaleUp.timingMode = .easeOut
        scaleDown.timingMode = .easeIn
        let scaleActions = SKAction.sequence([wait,scaleUp,scaleDown])
        topMessageNode.run(SKAction.repeatForever(scaleActions))
        
    }
    
    //MARK:- Set Up Board
    func addInitialTiles() {
        for row in 3..<6 {
            for col in 0..<NumColumns {
                let tileNode = TileNode(color: ColorCategory.TileColor)
                tileNode.size = CGSize(width: tileWidth, height: tileWidth)
                tileNode.position = pointInBoardLayerFor(column: col, row: row)
                tileNode.name = "tile\(col)\(row)"
                boardLayer.addChild(tileNode)
            }
        }
    }
    
    func addRemainingTiles() {
        for row in 0..<3 {
            for col in 0..<NumColumns {
                let tileNode = TileNode(color: ColorCategory.TileColor)
                tileNode.size = CGSize(width: tileWidth, height: tileWidth)
                tileNode.position = pointInBoardLayerFor(column: col, row: row)
                tileNode.name = "tile\(col)\(row)"
                tileNode.alpha = 0.0
                boardLayer.addChild(tileNode)
            }
        }
        for row in 6..<9 {
            for col in 0..<NumColumns {
                let tileNode = TileNode(color: ColorCategory.TileColor)
                tileNode.size = CGSize(width: tileWidth, height: tileWidth)
                tileNode.position = pointInBoardLayerFor(column: col, row: row)
                tileNode.name = "tile\(col)\(row)"
                tileNode.alpha = 0.0
                boardLayer.addChild(tileNode)
            }
        }
        
        let waitDuration: CGFloat = 0.05
        
        // top-left
        for column in 0..<NumColumns {
            let numNodes = column+1
            
            for row in numNodes-1 ..< NumRows {
                let targetTileNode: TileNode = boardLayer.childNode(withName: "tile\(column)\(row)") as! TileNode
                
                let waitMult = 8 - abs(row - column)
                let wait = SKAction.wait(forDuration: TimeInterval(CGFloat(waitMult)*waitDuration))
                let fadeIn = SKAction.fadeIn(withDuration: 0.15)
                targetTileNode.removeAllActions()
                targetTileNode.run(SKAction.sequence([wait, fadeIn]))
            }
        }
        // bottom-right
        for column in 1..<NumColumns {
            
            for row in 0 ..< column {
                let targetTileNode: TileNode = boardLayer.childNode(withName: "tile\(column)\(row)") as! TileNode
                
                let waitMult = abs(row - column)
                let wait = SKAction.wait(forDuration: TimeInterval(CGFloat(waitMult)*waitDuration+waitDuration*8.0))
                let fadeIn = SKAction.fadeIn(withDuration: 0.15)
                targetTileNode.removeAllActions()
                targetTileNode.run(SKAction.sequence([wait, fadeIn]))
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
        
        let maxIndex: UInt32 = 2
        
        // add bottom blocks
        if progressIndex == 1 {
            let bottomBlock1 = OneBlockNode(width: tileWidth, color: ColorCategory.BlockColor1, position: CGPoint(x: bottomBlockXLeft, y: bottomBlockY))
            addSingleBottomBlock(bottomBlock: bottomBlock1)
            bottomBlockArray[0] = bottomBlock1
            bottomBlock1.name = "bottomBlock0"
        } else if progressIndex == 4 && messageIndex > 24 {
            let bottomBlock1 = OneBlockNode(width: tileWidth, color: ColorCategory.BlockColor1, position: CGPoint(x: bottomBlockXLeft, y: bottomBlockY))
            addSingleBottomBlock(bottomBlock: bottomBlock1)
            bottomBlockArray[0] = bottomBlock1
            bottomBlock1.name = "bottomBlock0"
        } else {
            let bottomBlock1 = OneBlockNode(width: tileWidth, color: ColorCategory.randomBlockColor(maxIndex: maxIndex), position: CGPoint(x: bottomBlockXLeft, y: bottomBlockY))
            addSingleBottomBlock(bottomBlock: bottomBlock1)
            bottomBlockArray[0] = bottomBlock1
            bottomBlock1.name = "bottomBlock0"
        }
        
        if progressIndex == 1 {
            let bottomBlock2 = TwoBlockNode(width: tileWidth, color: ColorCategory.BlockColor2, position: CGPoint(x: bottomBlockXMid, y: bottomBlockY))
            addSingleBottomBlock(bottomBlock: bottomBlock2)
            bottomBlockArray[1] = bottomBlock2
            bottomBlock2.name = "bottomBlock1"
        } else if progressIndex == 4 && messageIndex <= 24 {
            let bottomBlock2 = TwoBlockNode(width: tileWidth, color: ColorCategory.randomBlockColor(maxIndex: 1), position: CGPoint(x: bottomBlockXMid, y: bottomBlockY))
            addSingleBottomBlock(bottomBlock: bottomBlock2)
            bottomBlockArray[1] = bottomBlock2
            bottomBlock2.name = "bottomBlock1"
        } else {
            let bottomBlock2 = OneBlockNode(width: tileWidth, color: ColorCategory.randomBlockColor(maxIndex: 1), position: CGPoint(x: bottomBlockXMid, y: bottomBlockY))
            addSingleBottomBlock(bottomBlock: bottomBlock2)
            bottomBlockArray[1] = bottomBlock2
            bottomBlock2.name = "bottomBlock1"
        }
        
        if progressIndex < 4 {
            let bottomBlock3 = ThreeBlockNode(width: tileWidth, color: ColorCategory.randomBlockColor(maxIndex: maxIndex), position: CGPoint(x: bottomBlockXRight, y: bottomBlockY))
            addSingleBottomBlock(bottomBlock: bottomBlock3)
            bottomBlockArray[2] = bottomBlock3
            bottomBlock3.name = "bottomBlock2"
        } else if progressIndex == 4 && messageIndex <= 24 {
            let bottomBlock3 = TwoBlockNode(width: tileWidth, color: ColorCategory.randomBlockColor(maxIndex: 1), position: CGPoint(x: bottomBlockXRight, y: bottomBlockY))
            addSingleBottomBlock(bottomBlock: bottomBlock3)
            bottomBlockArray[2] = bottomBlock3
            bottomBlock3.name = "bottomBlock2"
        } else {
            let bottomBlock3 = OneBlockNode(width: tileWidth, color: ColorCategory.randomBlockColor(maxIndex: 1), position: CGPoint(x: bottomBlockXRight, y: bottomBlockY))
            addSingleBottomBlock(bottomBlock: bottomBlock3)
            bottomBlockArray[2] = bottomBlock3
            bottomBlock3.name = "bottomBlock2"
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
        // only middle section row is visible now
        if progressIndex == 1 {
            if row < 3 || row > 5 {
                return ColorCategory.BackgroundColor
            }
        }
        
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
        
        // reset combo
        if numMatchingThisRound > 0 {
            
            // increment combo
            combo = combo+numMatchingThisRound
            
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
            
            
        } else {
            combo = 0
        }
        
        if combo > 1 {
            shakeCamera(layer: boardLayer, duration: 0.16, magnitude: CGFloat(combo))
        }
        
        numMatchingThisRound = 0
        
        updateTopMessageBasedOnProgress()
        //checkGameOver()
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
        
        // finished 1st task
        if progressIndex == 1 {
            topMessageNode.setText(to: "Nice! Now try vertically.")
            //topMessageNode.adjustLabelFontSizeToFitRect(rect: topMessageNode.frameRect)
            addRemainingTiles()
            let wait = SKAction.wait(forDuration: 1.0)
            gameLayer.run(wait, completion: {[weak self] in
                self?.progressIndex = 2
                self?.messageIndex = 10
            })
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
        
        if progressIndex == 2 {
            topMessageNode.setText(to: "Awesome! Diagonally next!")
            //topMessageNode.adjustLabelFontSizeToFitRect(rect: topMessageNode.frameRect)
            progressIndex = 3
            messageIndex = 15
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
        
        // finished 3rd task
        if progressIndex == 3 {
            topMessageNode.setText(to: "Fantastic!")
            let wait = SKAction.wait(forDuration: 1.3)
            gameLayer.run(wait, completion: {[weak self] in
                self?.progressIndex = 4
                self?.messageIndex = 20
                self?.updateTopMessageBasedOnProgress()
            })
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
        
        // finished 3rd task
        if progressIndex == 3 {
            topMessageNode.setText(to: "Fantastic!")
            let wait = SKAction.wait(forDuration: 1.3)
            gameLayer.run(wait, completion: {[weak self] in
                self?.progressIndex = 4
                self?.messageIndex = 20
                self?.updateTopMessageBasedOnProgress()
            })
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
        
        // finished 4th task
        if progressIndex == 4 {
            
            // remove bottom blocks
            for index in 0..<3 {
                let bottomBlock = gameLayer.childNode(withName: "bottomBlock\(index)")
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                bottomBlock?.isUserInteractionEnabled = false
                bottomBlock?.run(fadeOut)
            }
            
            topMessageNode.setText(to: "Good Luck, Have Fun!")
            //topMessageNode.adjustLabelFontSizeToFitRect(rect: topMessageNode.frameRect)
            bottomMessageNode.setText(to: "Tap to Finish Tutorial")
            messageIndex = messageIndex+1
            progressIndex = 5
        }
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
    
    //MARK:- SkipButtonDelegate
    func skipButtonWasPressed(sender: SkipButtonNode) {
        // Back to Home!
        if view != nil {
            let transition:SKTransition = SKTransition.fade(withDuration: 0.5)
            let gameScene = GameScene(size: size)
            gameScene.isAdReady = self.isAdReady
            self.view?.presentScene(gameScene, transition: transition)
        }
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
        
        /*** Update the tile color ***/
        if let colNum = colNum, let rowNum = rowNum {
            boardArray[colNum, rowNum] = sender.getBlockColor()
            updateBlockCellColorAt(column: colNum, row: rowNum)
        }
        
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
        
        for releasePosition in nodeReleasePositions {
            let posInBoardLayer = convert(releasePosition, to: boardLayer)
            let (rowNum, colNum) = rowAndColFor(position: posInBoardLayer)
            
            /*** Update the tile color ***/
            if let colNum = colNum, let rowNum = rowNum {
                boardArray[colNum, rowNum] = sender.getBlockColor()
                updateBlockCellColorAt(column: colNum, row: rowNum)
            }
        }
        
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
        
        for releasePosition in nodeReleasePositions {
            let posInBoardLayer = convert(releasePosition, to: boardLayer)
            let (rowNum, colNum) = rowAndColFor(position: posInBoardLayer)
            
            /*** Update the tile color ***/
            if let colNum = colNum, let rowNum = rowNum {
                boardArray[colNum, rowNum] = sender.getBlockColor()
                updateBlockCellColorAt(column: colNum, row: rowNum)
            }
        }
        
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
        
        for releasePosition in nodeReleasePositions {
            let posInBoardLayer = convert(releasePosition, to: boardLayer)
            let (rowNum, colNum) = rowAndColFor(position: posInBoardLayer)
            
            /*** Update the tile color ***/
            if let colNum = colNum, let rowNum = rowNum {
                boardArray[colNum, rowNum] = sender.getBlockColor()
                updateBlockCellColorAt(column: colNum, row: rowNum)
            }
        }
        
        sender.removeFromParent()
        
        checkBoardAndUpdate()
    }
    
    
    //MARK:- Touch Events
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if progressIndex == 0 {
            progressIndex = 1
            topMessageNode.setText(to: "Place squares on the board.")
            topMessageNode.adjustLabelFontSizeToFitRect(rect: topMessageNode.frameRect)
            bottomMessageNode.setText(to: "")
            messageIndex = messageIndex+1
            addBottomBlocks()
        }
        if progressIndex == 4 && messageIndex == 20 {
            topMessageNode.setText(to: "Finally, fill a 3x3 section.")
            messageIndex = messageIndex+1
        }
        // Back to Home Screen
        if progressIndex == 5 {
            if view != nil {
                let transition:SKTransition = SKTransition.fade(withDuration: 0.5)
                let gameScene = GameScene(size: size)
                gameScene.isAdReady = self.isAdReady
                self.view?.presentScene(gameScene, transition: transition)
            }
            return
        }
    }
    
    //MARK:- Helper Functions
    func debugDrawArea(rect drawRect: CGRect) {
        let shape = SKShapeNode(rect: drawRect)
        shape.strokeColor = SKColor.red
        shape.lineWidth = 2.0
        gameLayer.addChild(shape)
    }
    
    func updateTopMessageBasedOnProgress() {
        if progressIndex == 1 {
            if messageIndex == 1 {
                topMessageNode.setText(to: "Good Job! Keep it going.")
                messageIndex = messageIndex+1
            } else if messageIndex == 2 {
                topMessageNode.setText(to: "Place squares in every 3x3 section.")
                messageIndex = messageIndex+1
            } else if messageIndex == 3 {
                topMessageNode.setText(to: "And match colors to score.")
                messageIndex = messageIndex+1
            }
        }
        
        if progressIndex == 2 && messageIndex == 11 {
            topMessageNode.setText(to: "Remember to match colors.")
        } else if progressIndex == 2 {
            messageIndex = messageIndex+1
        }
        
        if progressIndex == 4 && messageIndex == 20 {
            topMessageNode.setText(to: "Finally, fill a 3x3 section.")
            messageIndex = messageIndex+1
        } else if progressIndex == 4 && messageIndex == 23 {
            topMessageNode.setText(to: "Of course, match colors.")
            messageIndex = messageIndex+1
        } else if progressIndex == 4 {
            messageIndex = messageIndex+1
        }
        
        
        
    }
    
    
    func animateNodesFadeIn() {
        /*** Animate nodeLayer ***/
        gameLayer.alpha = 0.0
        gameLayer.run(SKAction.fadeIn(withDuration: 0.2))
    }
}
