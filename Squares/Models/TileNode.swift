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
    init(color: SKColor, width: CGFloat) {
        let texture = SKTexture(imageNamed: "Tile")
        let textureSize = CGSize(width: width, height: width)
        super.init(texture: texture, color: .clear, size: textureSize)
        self.name = "tile"
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


