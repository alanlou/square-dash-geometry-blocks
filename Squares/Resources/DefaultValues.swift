//
//  DefaultValues.swift
//  Squares
//
//  Created by Alan Lou on 12/20/17.
//  Copyright © 2017 Rawwr Studios. All rights reserved.
//

import SpriteKit

enum ColorCategory {
    // Background Colors
    static let BackgroundColor_Classic = SKColor(red: 248/255, green: 240/255, blue: 230/255, alpha: 1.0)
    static let BackgroundColor_Day = SKColor(red: 255/255, green: 250/255, blue: 240/255, alpha: 1.0)
    static let BackgroundColor_Night = SKColor(red: 24/255, green: 34/255, blue: 40/255, alpha: 1.0)
    static let BackgroundColor_Colorblind = SKColor(red: 248/255, green: 240/255, blue: 230/255, alpha: 1.0)
    
    // Tile Colors
    static let TileColor_Day = SKColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 0.12)
    static let TileColorClassic = SKColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 0.12)
    static let TileColor_Night = SKColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 0.12)
    static let TileColor_Colorblind = SKColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 0.12)
    
    // Button Background Colors
    static let ButtonBackColor_Classic = BackgroundColor_Classic
    static let ButtonBackColor_Day = BackgroundColor_Day
    static let ButtonBackColor_Night = BackgroundColor_Night
    static let ButtonBackColor_Colorblind = BackgroundColor_Colorblind
    
    // Game UI Colors
    static let BestScoreFontColor_Classic = SKColor(red: 105/255, green: 105/255, blue: 105/255, alpha: 1.0)
    static let BestScoreFontColor_Day = SKColor(red: 105/255, green: 105/255, blue: 105/255, alpha: 1.0)
    static let BestScoreFontColor_Night = SKColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
    static let BestScoreFontColor_Colorblind = SKColor(red: 105/255, green: 105/255, blue: 105/255, alpha: 1.0)
    static let RecallButtonColor = getBestScoreFontColor()
    static let ScoreFontColor = getBestScoreFontColor()
    static let GameOverNodeColor = getBestScoreFontColor()
    static let TrophyColor = SKColor(red: 250/255, green:198/255, blue: 86/255, alpha: 1.0)
    
    // Pause Menu Colors
    static let ContinueButtonColor = SKColor(red: 255/255, green: 127/255, blue: 129/255, alpha: 1.0)
    static let SoundButtonColor = SKColor(red: 122/255, green: 201/255, blue: 195/255, alpha: 1.0)
    
    // Block Colors - Sweet
    static let BlockColor1_Classic = SKColor(red: 228/255, green:96/255, blue: 94/255, alpha: 1.0) // red
    static let BlockColor2_Classic = SKColor(red: 142/255, green:165/255, blue: 210/255, alpha: 1.0) // blue
    static let BlockColor3_Classic = SKColor(red: 245/255, green:218/255, blue: 70/255, alpha: 1.0) // yellow
    static let BlockColor4_Classic = SKColor(red: 192/255, green:210/255, blue: 109/255, alpha: 1.0) // green
    static let BlockColor5_Classic = SKColor(red: 192/255, green:170/255, blue: 149/255, alpha: 1.0) // brown
    static let BlockColor6_Classic = SKColor(red: 242/255, green:183/255, blue: 200/255, alpha: 1.0) // pink
    static let BlockColor7_Classic = SKColor(red: 145/255, green:202/255, blue: 199/255, alpha: 1.0) // teal
    static let BlockColor8_Classic = SKColor(red: 172/255, green:144/255, blue: 168/255, alpha: 1.0) // purple
    static let BlockColor9_Classic = SKColor(red: 237/255, green:161/255, blue: 92/255, alpha: 1.0) // orange
    
    // Block Colors - Day
    static let BlockColor1_Day = SKColor(red: 227/255, green:81/255, blue: 91/255, alpha: 1.0) // red
    static let BlockColor2_Day = SKColor(red: 22/255, green:131/255, blue: 208/255, alpha: 1.0) // blue
    static let BlockColor3_Day = SKColor(red: 250/255, green:198/255, blue: 86/255, alpha: 1.0) // yellow
    static let BlockColor4_Day = SKColor(red: 118/255, green:183/255, blue: 52/255, alpha: 1.0) // green
    static let BlockColor5_Day = SKColor(red: 165/255, green:141/255, blue: 131/255, alpha: 1.0) // brown
    static let BlockColor6_Day = SKColor(red: 253/255, green:154/255, blue: 182/255, alpha: 1.0) // pink
    static let BlockColor7_Day = SKColor(red: 128/255, green:207/255, blue: 204/255, alpha: 1.0) // teal
    static let BlockColor8_Day = SKColor(red: 133/255, green:111/255, blue: 177/255, alpha: 1.0) // purple
    static let BlockColor9_Day = SKColor(red: 150/255, green:164/255, blue: 165/255, alpha: 1.0) // gray
    
    // Block Colors - Night
    static let BlockColor1_Night = SKColor(red: 232/255, green:59/255, blue: 73/255, alpha: 1.0) // red
    static let BlockColor2_Night = SKColor(red: 25/255, green:127/255, blue: 167/255, alpha: 1.0) // blue
    static let BlockColor3_Night = SKColor(red: 250/255, green:198/255, blue: 86/255, alpha: 1.0)  // yellow
    static let BlockColor4_Night = SKColor(red: 42/255, green:166/255, blue: 98/255, alpha: 1.0) // green
    static let BlockColor5_Night = SKColor(red: 124/255, green:98/255, blue: 82/255, alpha: 1.0) // brown
    static let BlockColor6_Night = SKColor(red: 225/255, green:70/255, blue: 140/255, alpha: 1.0) // pink
    static let BlockColor7_Night = SKColor(red: 69/255, green:199/255, blue: 185/255, alpha: 1.0) // teal
    static let BlockColor8_Night = SKColor(red: 128/255, green:88/255, blue: 182/255, alpha: 1.0) // purple
    static let BlockColor9_Night = SKColor(red: 255/255, green:153/255, blue: 112/255, alpha: 1.0) // orange
    
    // Block Colors - Colorblind
    static let BlockColor1_Colorblind = SKColor(red: 250/255, green:88/255, blue: 87/255, alpha: 1.0) // red
    static let BlockColor2_Colorblind = SKColor(red: 78/255, green:164/255, blue: 215/255, alpha: 1.0) // blue
    static let BlockColor3_Colorblind = SKColor(red: 225/255, green:207/255, blue: 80/255, alpha: 1.0) // yellow
    static let BlockColor4_Colorblind = SKColor(red: 79/255, green:188/255, blue: 109/255, alpha: 1.0) // green
    static let BlockColor5_Colorblind = SKColor(red: 181/255, green:145/255, blue: 58/255, alpha: 1.0) // brown
    static let BlockColor6_Colorblind = SKColor(red: 248/255, green:124/255, blue: 174/255, alpha: 1.0) // pink
    static let BlockColor7_Colorblind = SKColor(red: 77/255, green:77/255, blue: 77/255, alpha: 1.0) // gray
    static let BlockColor8_Colorblind = SKColor(red: 181/255, green:118/255, blue: 175/255, alpha: 1.0) // purple
    static let BlockColor9_Colorblind = SKColor(red: 255/255, green:163/255, blue: 72/255, alpha: 1.0) // orange
    
    
    static func getBlockColorAtIndex(index:UInt32) -> SKColor {
        
        let selectedSkin = UserDefaults.standard.object(forKey: "skin") as! String
        
        // Skin 1: Day
        if selectedSkin == "Classic" {
            switch index {
            case 1:
                return BlockColor1_Classic
            case 2:
                return BlockColor2_Classic
            case 3:
                return BlockColor3_Classic
            case 4:
                return BlockColor4_Classic
            case 5:
                return BlockColor5_Classic
            case 6:
                return BlockColor6_Classic
            case 7:
                return BlockColor7_Classic
            case 8:
                return BlockColor8_Classic
            case 9:
                return BlockColor9_Classic
            default:
                return SKColor.clear
            }
        } else if selectedSkin == "Day" {
            switch index {
            case 1:
                return BlockColor1_Day
            case 2:
                return BlockColor2_Day
            case 3:
                return BlockColor3_Day
            case 4:
                return BlockColor4_Day
            case 5:
                return BlockColor5_Day
            case 6:
                return BlockColor6_Day
            case 7:
                return BlockColor7_Day
            case 8:
                return BlockColor8_Day
            case 9:
                return BlockColor9_Day
            default:
                return SKColor.clear
            }
        } else if selectedSkin == "Night" {
            switch index {
            case 1:
                return BlockColor1_Night
            case 2:
                return BlockColor2_Night
            case 3:
                return BlockColor3_Night
            case 4:
                return BlockColor4_Night
            case 5:
                return BlockColor5_Night
            case 6:
                return BlockColor6_Night
            case 7:
                return BlockColor7_Night
            case 8:
                return BlockColor8_Night
            case 9:
                return BlockColor9_Night
            default:
                return SKColor.clear
            }
        } else if selectedSkin == "Colorblind" {
            switch index {
            case 1:
                return BlockColor1_Colorblind
            case 2:
                return BlockColor2_Colorblind
            case 3:
                return BlockColor3_Colorblind
            case 4:
                return BlockColor4_Colorblind
            case 5:
                return BlockColor5_Colorblind
            case 6:
                return BlockColor6_Colorblind
            case 7:
                return BlockColor7_Colorblind
            case 8:
                return BlockColor8_Colorblind
            case 9:
                return BlockColor9_Colorblind
            default:
                return SKColor.clear
            }
        } else {
            return SKColor.clear
        }
    }
    
    static func getBackgroundColor() -> SKColor {
        
        if UserDefaults.standard.object(forKey: "skin") == nil {
            UserDefaults.standard.set("Classic", forKey: "skin")
        }
        let selectedSkin = UserDefaults.standard.object(forKey: "skin") as! String
        
        if selectedSkin == "Classic" {
            return BackgroundColor_Classic
        } else if selectedSkin == "Day" {
            return BackgroundColor_Day
        } else if selectedSkin == "Night" {
            return BackgroundColor_Night
        } else if selectedSkin == "Colorblind" {
            return BackgroundColor_Colorblind
        } else {
            return SKColor.clear
        }
    }
    
    static func getBestScoreFontColor() -> SKColor {
        
        if UserDefaults.standard.object(forKey: "skin") == nil {
            UserDefaults.standard.set("Classic", forKey: "skin")
        }
        let selectedSkin = UserDefaults.standard.object(forKey: "skin") as! String
        
        if selectedSkin == "Classic" {
            return BestScoreFontColor_Classic
        } else if selectedSkin == "Day" {
            return BestScoreFontColor_Day
        } else if selectedSkin == "Night" {
            return BestScoreFontColor_Night
        } else if selectedSkin == "Colorblind" {
            return BestScoreFontColor_Colorblind
        } else {
            return SKColor.clear
        }
    }
    
    static func getButtonBackgroundColor() -> SKColor {
        let selectedSkin = UserDefaults.standard.object(forKey: "skin") as! String
        
        if selectedSkin == "Classic" {
            return ButtonBackColor_Classic
        } else if selectedSkin == "Day" {
            return ButtonBackColor_Day
        } else if selectedSkin == "Night" {
            return ButtonBackColor_Night
        } else if selectedSkin == "Colorblind" {
            return ButtonBackColor_Colorblind
        } else {
            return SKColor.clear
        }
    }
    
    static func getTileColor() -> SKColor {
        let selectedSkin = UserDefaults.standard.object(forKey: "skin") as! String
        
        if selectedSkin == "Classic" {
            return TileColorClassic
        } else if selectedSkin == "Day" {
            return TileColor_Day
        } else if selectedSkin == "Night" {
            return TileColor_Night
        } else if selectedSkin == "Colorblind" {
            return TileColor_Colorblind
        } else {
            return SKColor.clear
        }
    }
    
    static func getBlockColorArray() -> [SKColor] {
        return [getBlockColorAtIndex(index: 1),getBlockColorAtIndex(index: 2),getBlockColorAtIndex(index: 3),getBlockColorAtIndex(index: 4),getBlockColorAtIndex(index: 5),getBlockColorAtIndex(index: 6),getBlockColorAtIndex(index: 7),getBlockColorAtIndex(index: 8),getBlockColorAtIndex(index: 9)]
    }
    
    static func getBlockColorIndexArray() -> [UInt32] {
        return [1,2,3,4,5,6,7,8,9]
    }
    
    static func randomBlockColor(maxIndex: UInt32) -> SKColor {
        assert(maxIndex <= 9)
        
        let randomIndex = UInt32(arc4random_uniform(maxIndex)) + 1
        
        return getBlockColorAtIndex(index: randomIndex)
    }
    
}

