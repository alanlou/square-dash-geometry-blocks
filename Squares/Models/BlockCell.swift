//
//  BlockCell.swift
//  Squares
//
//  Created by Alan Lou on 12/22/17.
//  Copyright © 2017 Rawwr Studios. All rights reserved.
//

import SpriteKit

enum BlockCellType: Int, CustomStringConvertible {
    case unknown = 0, croissant, cupcake, danish, donut, macaroon, sugarblock
    
    var spriteName: String {
        let spriteNames = [
            "Croissant",
            "Cupcake",
            "Danish",
            "Donut",
            "Macaroon",
            "Sugarblock"]
        
        return spriteNames[rawValue - 1]
    }
    
    var highlightedSpriteName: String {
        return spriteName + "-Highlighted"
    }
    
    var description: String {
        return spriteName
    }
    
    static func random() -> BlockCellType {
        return BlockCellType(rawValue: Int(arc4random_uniform(6)) + 1)!
    }
}

// model object that describes the data
class BlockCell: CustomStringConvertible, Hashable {
    var column: Int
    var row: Int
    let blockType: BlockCellType
    var sprite: SKSpriteNode?
    
    var description: String {
        return "type:\(blockType) square:(\(column),\(row))"
    }
    var hashValue: Int {
        return row*10 + column
    }
    
    init(column: Int, row: Int, blockCellType: BlockCellType) {
        self.column = column
        self.row = row
        self.blockType = blockCellType
    }
}

func ==(lhs: BlockCell, rhs: BlockCell) -> Bool {
    return lhs.column == rhs.column && lhs.row == rhs.row
}
