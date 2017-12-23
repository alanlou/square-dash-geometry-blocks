//
//  GameScene.swift
//  Squares
//
//  Created by Alan Lou on 12/20/17.
//  Copyright © 2017 Rawwr Studios. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    // super node containing the gamelayer and pauselayer
    let gameLayer = SKNode()
    let tileLayer = SKNode()
    
    // number
    let NumColumns = 9
    let NumRows = 9
    
    let boardSpacing = CGFloat(20.0)
    let sectionSpacing = CGFloat(5.0)
    let cellSpacing = CGFloat(3.0)
    
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
        
        /*** set up tile layer ***/
        let layerPosition = CGPoint(x: 0, y: size.height/2-size.width/2)
        tileLayer.position = layerPosition
        gameLayer.addChild(tileLayer)
        addTiles()
        
        
        
    }
    
    //MARK:- Set Up Board
    func addTiles() {
        for row in 0..<NumRows {
            for col in 0..<NumColumns {
                let tileNode = TileNode(color: ColorCategory.TileColor)
                tileNode.size = CGSize(width: tileWidth, height: tileWidth)
                tileNode.position = pointInTileLayerFor(column: col, row: row)
                tileLayer.addChild(tileNode)
            }
        }
    }
    
    //MARK:- Helper Functions
    func pointInTileLayerFor(column: Int, row: Int) -> CGPoint {
        var xCoord = CGFloat(0.0)
        var yCoord = CGFloat(0.0)
        
        switch column {
        case (0...2):
            xCoord = CGFloat(column)*(tileWidth+cellSpacing) + tileWidth/2 + boardSpacing
        case (3...5):
            xCoord = CGFloat(column)*(tileWidth+cellSpacing) + tileWidth/2 + boardSpacing + sectionSpacing
        case (6...8):
            xCoord = CGFloat(column)*(tileWidth+cellSpacing) + tileWidth/2 + boardSpacing + sectionSpacing*CGFloat(2.0)
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
}
