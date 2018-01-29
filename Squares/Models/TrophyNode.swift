//
//  TrophyNode.swift
//  Squares
//
//  Created by Alan Lou on 1/24/18.
//  Copyright © 2018 Rawwr Studios. All rights reserved.
//

import SpriteKit

class TrophyNode: SKSpriteNode {
    
    //MARK:- Initialization
    init(color: SKColor, height: CGFloat) {
        let texture = SKTexture(imageNamed: "Trophy")
        let textureSize = CGSize(width: height*texture.size().width/texture.size().height, height: height)
        super.init(texture: texture, color: .clear, size: textureSize)
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
