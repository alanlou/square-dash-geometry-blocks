//
//  BlockCellNode.swift
//  Squares
//
//  Created by Alan Lou on 12/22/17.
//  Copyright © 2017 Rawwr Studios. All rights reserved.
//

import SpriteKit

// model object that describes the data
class BlockCellNode: SKSpriteNode {
    var column: Int?
    var row: Int?
    var blockColor: SKColor
    let blockColorIndex: UInt32
    
    init(colorIndex: UInt32) {
        blockColorIndex = colorIndex
        blockColor = ColorCategory.getBlockColorAtIndex(index: blockColorIndex)
        let texture = SKTexture(imageNamed: "Tile")
        super.init(texture: texture, color: .clear, size: texture.size())
        self.name = "blockcell"
        self.color = blockColor
        self.colorBlendFactor = 1.0
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:- Helper Functions
    func setCellAt(col colTemp: Int, row rowTemp: Int){
        self.column = colTemp
        self.row = rowTemp
    }
    
    func updateCellColor() {
        blockColor = ColorCategory.getBlockColorAtIndex(index: blockColorIndex)
        self.color = blockColor
    }
}
