//
//  NewBestRibbonNode.swift
//  Squares
//
//  Created by Alan Lou on 1/4/18.
//  Copyright © 2018 Rawwr Studios. All rights reserved.
//

import SpriteKit

class NewBestRibbonNode: SKSpriteNode {
    
    //MARK:- Initialization
    init() {
        let texture = SKTexture(imageNamed: "NewBestRibbon")
        super.init(texture: texture, color: .clear, size: texture.size())
        self.name = "newbestribbon"
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
