//
//  BestScoreBarNode.swift
//  Squares
//
//  Created by Alan Lou on 1/22/18.
//  Copyright © 2018 Rawwr Studios. All rights reserved.
//

import SpriteKit

class BestScoreBarNode: SKSpriteNode {
    
    //MARK:- Initialization
    init(width: CGFloat) {
        let texture = SKTexture(imageNamed: "BestScoreBar")
        let textureSize = CGSize(width: width, height: width*texture.size().height/texture.size().width)
        super.init(texture: texture, color: .clear, size: textureSize)
    }
    
    convenience init(color: SKColor, width: CGFloat) {
        self.init(width: width)
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

