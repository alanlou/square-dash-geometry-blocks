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
    
    // numbers
    let NumColumns: Int = 9
    let NumRows: Int = 9
    
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
        
        /*** set up game layer ***/
        self.addChild(gameLayer)
        
        /*** set up board layer ***/
        let layerPosition = CGPoint(x: boardRect.minX, y: boardRect.minY)
        boardLayer.position = layerPosition
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
                tileNode.position = pointInTileLayerFor(column: col, row: row)
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
        
        gameLayer.addChild(bottomBlock1)
        gameLayer.addChild(bottomBlock2)
        gameLayer.addChild(bottomBlock3)
    }
    
    //MARK:- BlockNodeDelegate
    func oneBlockWasReleased(sender: OneBlockNode) {
        let releasePosition = sender.getReleasePosition()
        guard let releasePosition = releasePosition else {
            return
        }
        
        let (rowNum, colNum) = rowAndColFor(touchPosition: releasePosition)
        print(releasePosition)
        print(rowNum)
        print(colNum)
    }
    
    //MARK:- Helper Functions
    func pointInTileLayerFor(column: Int, row: Int) -> CGPoint {
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
            yCoord = CGFloat(row)*(tileWidth+cellSpacing) + tileWidth/2 + boardSpacing + sectionSpacing
        case (6...8):
            yCoord = CGFloat(row)*(tileWidth+cellSpacing) + tileWidth/2 + boardSpacing + sectionSpacing*CGFloat(2.0)
        default: break
        }
        
        return CGPoint(x: xCoord, y: yCoord)
    }
    
    func rowAndColFor(touchPosition position: CGPoint) -> (Int, Int) {
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
            colNum = -1
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
            rowNum = -1
        }
        
        // if not in a cell, return (-1,-1)
        return (rowNum, colNum)
    }
}
