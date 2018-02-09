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
    init(height: CGFloat) {
        let texture = SKTexture(imageNamed: "NewBestRibbon")
        let textureSize = CGSize(width: height*texture.size().width/texture.size().height, height: height)
        super.init(texture: texture, color: .clear, size: textureSize)
        self.name = "newbestribbon"
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
