//
//  TileNode.swift
//  Squares
//
//  Created by Alan Lou on 12/23/17.
//  Copyright © 2017 Rawwr Studios. All rights reserved.
//

import SpriteKit

class TileNode: SKSpriteNode {
    
    //MARK:- Initialization
    init() {
        let texture = SKTexture(imageNamed: "Tile")
        super.init(texture: texture, color: .clear, size: texture.size())
        self.name = "tile"
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
    func changeColor(to color: SKColor) {
        self.color = color
        self.colorBlendFactor = 1.0
    }
    
    func getColor() -> SKColor {
        return self.color
    }
}


