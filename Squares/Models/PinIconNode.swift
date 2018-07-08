//
//  PinIconNode.swift
//  Squares
//
//  Created by Alan Lou on 7/5/18.
//  Copyright © 2018 Rawwr Studios. All rights reserved.
//

import SpriteKit

class PinIconNode: SKSpriteNode {
    
    //MARK:- Initialization
    init(color: SKColor, width: CGFloat) {
        let texture = SKTexture(imageNamed: "Pin")
        let textureSize = CGSize(width: width, height: width)
        super.init(texture: texture, color: .clear, size: textureSize)
        self.name = "pinicon"
        self.anchorPoint = CGPoint(x:1.0, y:1.0)
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
    
}
