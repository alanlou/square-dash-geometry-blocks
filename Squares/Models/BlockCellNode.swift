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
    let blockColor: SKColor
    
    init() {
        blockColor = SKColor.clear
        let texture = SKTexture(imageNamed: "Tile")
        super.init(texture: texture, color: .clear, size: texture.size())
        self.name = "blockcell"
    }
    
    convenience init(color: SKColor) {
        self.init()
        self.color = color
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
    
    func getBlockColor() -> SKColor {
        return blockColor
    }
}
