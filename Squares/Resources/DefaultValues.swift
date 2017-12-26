//
//  DefaultValues.swift
//  Squares
//
//  Created by Alan Lou on 12/20/17.
//  Copyright © 2017 Rawwr Studios. All rights reserved.
//

import SpriteKit

struct ColorCategory {
    static let BackgroundColor = SKColor(red: 255/255, green: 252/255, blue: 244/255, alpha: 1.0)
    static let TileColor = SKColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 0.3)
    
    // Pause Menu Buttons
    static let ContinueButtonColor = SKColor(red: 255/255, green: 127/255, blue: 129/255, alpha: 1.0)
    static let HomeButtonColor = SKColor(red: 250/255, green: 218/255, blue: 94/255, alpha: 1.0)
    static let SoundButtonColor = SKColor(red: 122/255, green: 201/255, blue: 195/255, alpha: 1.0)
    
    // Block Colors
    static let BlockColor1 = SKColor.red
    static let BlockColor2 = SKColor.yellow
    static let BlockColor3 = SKColor.blue
    static let BlockColor4 = SKColor.green
    static let BlockColor5 = SKColor.brown
    static let BlockColor6 = SKColor.purple
    
    static func randomBlockColor() -> SKColor {
        let randomIndex = Int(arc4random_uniform(6)) + 1
        print(randomIndex)
        
        switch randomIndex {
        case 1:
            return BlockColor1
        case 2:
            return BlockColor2
        case 3:
            return BlockColor3
        case 4:
            return BlockColor4
        case 5:
            return BlockColor5
        case 6:
            return BlockColor6
        default:
            return SKColor.clear
        }
    }
    
}

