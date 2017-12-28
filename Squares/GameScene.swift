//
//  GameScene.swift
//  Squares
//
//  Created by Alan Lou on 12/20/17.
//  Copyright © 2017 Rawwr Studios. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, OneBlockNodeDelegate {
    // super node containing the gamelayer and pauselayer
    let gameLayer = SKNode()
    let boardLayer = SKNode()
    
    // board 2D array
    var boardArray = Array2D<SKColor>(columns: 9, rows: 9)
    
    // numbers
    let NumColumns: Int = 9
    let NumRows: Int = 9
    var bottomBlockNum: Int = 3
    
    let boardSpacing: CGFloat = 30.0
    let sectionSpacing: CGFloat = 17.0
    let cellSpacing: CGFloat = 3.0
    
    // variables
    let boardRect: CGRect
    let tileWidth: CGFloat
    
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
        // set position
        let bottomBlockY = size.height/4-boardRect.height/4
        let bottomBlockXLeft = (tileWidth+cellSpacing) + tileWidth/2 + boardSpacing
        let bottomBlockXMid = size.width/2
        let bottomBlockXRight = 7*(tileWidth+cellSpacing) - cellSpacing*CGFloat(2.0) + tileWidth/2 + boardSpacing + sectionSpacing*CGFloat(2.0)
        
        // initialize block nodes
        let bottomBlock1 = OneBlockNode(width: tileWidth, color: ColorCategory.randomBlockColor(), position: CGPoint(x: bottomBlockXLeft, y: bottomBlockY))
        let bottomBlock2 = OneBlockNode(width: tileWidth, color: ColorCategory.randomBlockColor(), position: CGPoint(x: bottomBlockXMid, y: bottomBlockY))
        let bottomBlock3 = OneBlockNode(width: tileWidth, color: ColorCategory.randomBlockColor(), position: CGPoint(x: bottomBlockXRight, y: bottomBlockY))
        
        // add block nodes
        bottomBlock1.position = bottomBlock1.getBlockPosition()
        bottomBlock2.position = bottomBlock2.getBlockPosition()
        bottomBlock3.position = bottomBlock3.getBlockPosition()
        
        // set delegate
        bottomBlock1.blockDelegate = self
        bottomBlock2.blockDelegate = self
        bottomBlock3.blockDelegate = self
        
        // add blocks with animation
        bottomBlock1.setScale(0.0)
        bottomBlock2.setScale(0.0)
        bottomBlock3.setScale(0.0)
        
        gameLayer.addChild(bottomBlock1)
        gameLayer.addChild(bottomBlock2)
        gameLayer.addChild(bottomBlock3)
        
        let scaleUp = SKAction.scale(to: 0.6, duration: 0.15)
        bottomBlock1.run(scaleUp)
        bottomBlock2.run(scaleUp)
        bottomBlock3.run(scaleUp)
        
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
            sender.setNodeAt(positionInScreen: nil)
        }
    }
    
    func oneBlockWasSet(sender: OneBlockNode) {
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
    
    func checkBoardAndUpdate() {
        
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
                            
                            print("(\(row),\(column))")
                            print(matchingColor)
                            
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
    }
    
    // remove tile node with animation
    func removeTileNode(tileNode: TileNode) {
        
        let emitter = SKEmitterNode()
        let particleTexture = SKTexture(imageNamed: "Ball")
        emitter.particleTexture = particleTexture
        emitter.particleBirthRate = 150
        emitter.numParticlesToEmit = 15
        emitter.particleLifetime = 0.5
        emitter.emissionAngle = 0.0
        emitter.emissionAngleRange = CGFloat.pi*2
        emitter.particleSpeed = 300
        emitter.particleSpeedRange = 10
        emitter.particleAlpha = 1.0
        emitter.particleAlphaSpeed = -2.0
        emitter.particleAlphaRange = 0.0
        //emitter.particleRotation = 0.0
        //emitter.particleRotationRange = CGFloat.pi*2
        emitter.particleScale = 1.5
        emitter.particleScaleRange = 1.0
        emitter.particleScaleSpeed = -2.5
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
        assert(secRow >= 0 && secRow < 3)
        for column in 0..<NumColumns {
            for row in secRow*3..<secRow*3+3 {
                let targetTileNode: TileNode = boardLayer.childNode(withName: "tile\(column)\(row)") as! TileNode
                if let color = color, boardArray[column,row] == nil || boardArray[column,row] == color {
                    let changeColor = SKAction.colorize(with: color.withAlphaComponent(0.3), colorBlendFactor: 1.0, duration: 0.25)
                    let changeColorBack = SKAction.colorize(with: ColorCategory.TileColor, colorBlendFactor: 1.0, duration: 0.2)
                    if !targetTileNode.hasActions(){
                        targetTileNode.run(SKAction.sequence([changeColor,changeColorBack]))
                    }
                }
            }
        }
    }
    
    func highlightSecCol(secCol: Int, color: SKColor?) {
        assert(secCol >= 0 && secCol < 3)
        for row in 0..<NumRows {
            for column in secCol*3..<secCol*3+3 {
                let targetTileNode: TileNode = boardLayer.childNode(withName: "tile\(column)\(row)") as! TileNode
                if let color = color, boardArray[column,row] == nil || boardArray[column,row] == color {
                    let changeColor = SKAction.colorize(with: color.withAlphaComponent(0.3), colorBlendFactor: 1.0, duration: 0.25)
                    let changeColorBack = SKAction.colorize(with: ColorCategory.TileColor, colorBlendFactor: 1.0, duration: 0.2)
                    if !targetTileNode.hasActions(){
                        targetTileNode.run(SKAction.sequence([changeColor,changeColorBack]))
                    }
                }
            }
        }
    }
    
    func highlightDiag1(color: SKColor?) {
        for row in 0..<NumRows{
            for column in 6-Int(row/3)*3..<9-Int(row/3)*3 {
                let targetTileNode: TileNode = boardLayer.childNode(withName: "tile\(column)\(row)") as! TileNode
                if let color = color, boardArray[column,row] == nil || boardArray[column,row] == color {
                    let changeColor = SKAction.colorize(with: color.withAlphaComponent(0.3), colorBlendFactor: 1.0, duration: 0.25)
                    let changeColorBack = SKAction.colorize(with: ColorCategory.TileColor, colorBlendFactor: 1.0, duration: 0.2)
                    if !targetTileNode.hasActions(){
                        targetTileNode.run(SKAction.sequence([changeColor,changeColorBack]))
                    }
                }
            }
        }
    }
    
    
    func highlightDiag2(color: SKColor?) {
        for row in 0..<NumRows{
            for column in Int(row/3)*3..<Int(row/3)*3+3 {
                let targetTileNode: TileNode = boardLayer.childNode(withName: "tile\(column)\(row)") as! TileNode
                if let color = color, boardArray[column,row] == nil || boardArray[column,row] == color {
                    let changeColor = SKAction.colorize(with: color.withAlphaComponent(0.3), colorBlendFactor: 1.0, duration: 0.25)
                    let changeColorBack = SKAction.colorize(with: ColorCategory.TileColor, colorBlendFactor: 1.0, duration: 0.2)
                    if !targetTileNode.hasActions(){
                        targetTileNode.run(SKAction.sequence([changeColor,changeColorBack]))
                    }
                }
            }
        }
    }
    
    
    func highlightSection(secCol:Int, secRow:Int, color: SKColor?) {
        for column in secCol*3..<secCol*3+3 {
            for row in secRow*3..<secRow*3+3 {
                let targetTileNode: TileNode = boardLayer.childNode(withName: "tile\(column)\(row)") as! TileNode
                if let color = color, boardArray[column,row] == nil || boardArray[column,row] == color {
                    let changeColor = SKAction.colorize(with: color.withAlphaComponent(0.3), colorBlendFactor: 1.0, duration: 0.25)
                    let changeColorBack = SKAction.colorize(with: ColorCategory.TileColor, colorBlendFactor: 1.0, duration: 0.2)
                    if !targetTileNode.hasActions(){
                        targetTileNode.run(SKAction.sequence([changeColor,changeColorBack]))
                    }
                }
            }
        }
    }
}
