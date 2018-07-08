//
//  TitleLetterNode.swift
//  Squares
//
//  Created by Alan Lou on 7/6/18.
//  Copyright © 2018 Rawwr Studios. All rights reserved.
//

import SpriteKit

struct TitleLetterType {
    static let LetterS:  String = "LetterS"
    static let LetterQ:  String = "LetterQ"
    static let LetterU:  String = "LetterU"
    static let LetterA:  String = "LetterA"
    static let LetterR:  String = "LetterR"
    static let LetterE:  String = "LetterE"
    static let LetterD:  String = "LetterD"
    static let LetterH:  String = "LetterH"
}

class TitleLetterNode: SKSpriteNode {
    
    //MARK:- Initialization
    init(letter: String, color: SKColor, width: CGFloat) {
        let texture = SKTexture(imageNamed: letter)
        let textureSize = CGSize(width: width, height: width*texture.size().height/texture.size().width)
        super.init(texture: texture, color: .clear, size: textureSize)
        self.name = "TitleLetter"
        self.color = color
        self.colorBlendFactor = 1.0
    }
    
    init(letter: String, color: SKColor, height: CGFloat) {
        let texture = SKTexture(imageNamed: letter)
        let textureSize = CGSize(width: height*texture.size().width/texture.size().height, height: height)
        super.init(texture: texture, color: .clear, size: textureSize)
        self.name = letter
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
