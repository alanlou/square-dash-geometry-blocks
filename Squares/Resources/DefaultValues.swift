//
//  DefaultValues.swift
//  Squares
//
//  Created by Alan Lou on 12/20/17.
//  Copyright © 2017 Rawwr Studios. All rights reserved.
//

import SpriteKit

enum ColorCategory {
    static let BackgroundColor = SKColor(red: 255/255, green: 252/255, blue: 244/255, alpha: 1.0)
    static let TileColor = SKColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 0.2)
    
    // Game UI Colors
    static let BestScoreFontColor = SKColor(red: 105/255, green: 105/255, blue: 105/255, alpha: 1.0)
    static let RecallButtonColor = BestScoreFontColor
    static let ScoreFontColor = BestScoreFontColor
    static let GameOverNodeColor = SKColor(red: 210/255, green: 210/255, blue: 210/255, alpha: 1.0)
    
    // Pause Menu Colors
    static let PauseButtonColor = BestScoreFontColor
    static let ContinueButtonColor = SKColor(red: 255/255, green: 127/255, blue: 129/255, alpha: 1.0)
    static let HomeButtonColor = SKColor(red: 250/255, green: 218/255, blue: 94/255, alpha: 1.0)
    static let SoundButtonColor = SKColor(red: 122/255, green: 201/255, blue: 195/255, alpha: 1.0)
    
    // Block Colors
    static let BlockColor1 = SKColor(red: 227/255, green:81/255, blue: 91/255, alpha: 1.0) // red
    static let BlockColor2 = SKColor(red: 250/255, green:198/255, blue: 86/255, alpha: 1.0) // yellow
    static let BlockColor3 = SKColor(red: 15/255, green:124/255, blue: 200/255, alpha: 1.0) // blue
    static let BlockColor4 = SKColor(red: 99/255, green:172/255, blue: 32/255, alpha: 1.0) // green
    static let BlockColor5 = SKColor(red: 162/255, green:138/255, blue: 128/255, alpha: 1.0) // brown
    static let BlockColor6 = SKColor(red: 253/255, green:154/255, blue: 182/255, alpha: 1.0) // pink
    static let BlockColor7 = SKColor(red: 133/255, green:111/255, blue: 177/255, alpha: 1.0) // purple
    static let BlockColor8 = SKColor(red: 128/255, green:207/255, blue: 204/255, alpha: 1.0) // teal
    static let BlockColor9 = SKColor(red: 150/255, green:164/255, blue: 165/255, alpha: 1.0) // gray
    
    static let BlockColorArray = [BlockColor1, BlockColor2, BlockColor3, BlockColor4, BlockColor5, BlockColor6, BlockColor7, BlockColor8, BlockColor9]
    
    static func randomBlockColor(maxIndex: UInt32) -> SKColor {
        assert(maxIndex <= 9)
        
        let randomIndex = Int(arc4random_uniform(maxIndex)) + 1
        
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
        case 7:
            return BlockColor7
        case 8:
            return BlockColor8
        case 9:
            return BlockColor9
        default:
            return SKColor.clear
        }
    }
    
}

