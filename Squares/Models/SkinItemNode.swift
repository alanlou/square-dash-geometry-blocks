//
//  SkinItemNode.swift
//  Squares
//
//  Created by Alan Lou on 7/4/18.
//  Copyright © 2018 Rawwr Studios. All rights reserved.
//


import SpriteKit

protocol SkinItemNodeDelegate: NSObjectProtocol {
    func skinItemNodeWasReleased(sender: SkinItemNode, skinItem: String)
}

class SkinItemNode: SKSpriteNode {
    
    let boardSpacingX: CGFloat
    let boardSpacingY: CGFloat
    let cellSpacing: CGFloat
    let tileWidth: CGFloat
    
    let skinItem: String
    var skinItemTitle: MessageNode?
    
    weak var skinItemNodeDelegate: SkinItemNodeDelegate!
    
    //MARK:- Initialization
    init(width: CGFloat, height: CGFloat, skin: String) {
        
        skinItem = skin
        
        // pre-defined numbers
        boardSpacingX = width/25.0
        let sectionSpacing = width/20.0
        cellSpacing = width/150.0
        tileWidth = (width - boardSpacingX*2.0 - sectionSpacing*2.0 - cellSpacing*6.0)/9.0
        boardSpacingY = (height - 3.0*tileWidth - 2.0*cellSpacing)*0.5
        let sectionWidth = 3.0*tileWidth+2.0*cellSpacing+2.0*boardSpacingX
        
        super.init(texture: nil, color: .clear, size: CGSize(width:width, height:height))
        self.name = "skinItemNode"
        self.zPosition = 10000
        self.anchorPoint = CGPoint(x:0.0, y:0.0)
        self.color = getBackgroundColor()
        
        // set up options
        isUserInteractionEnabled = true
        
        // add block cell nodes
        for row in 0..<3 {
            for col in 0..<3 {
                let tileNode = TileNode(color: getBlockColorAtIndex(index: UInt32((2-row)*3+col+1)), width:tileWidth) // arrange color in correct order
                tileNode.position = pointInBoardLayerFor(column: col, row: row)
                tileNode.name = "tile\(col)\(row)"
                self.addChild(tileNode)
            }
        }
        
        // add skin item name
        let skinItemTitleWidth = min(tileWidth*3.5,width-tileWidth*7.5)
        let skinItemTitleHeight = skinItemTitleWidth*0.5
        let skinItemTitleFrame = CGRect(x: (width-sectionWidth)/2.0 + sectionWidth - skinItemTitleWidth/2, y: height/2.0-skinItemTitleHeight/2.0, width: skinItemTitleWidth, height: skinItemTitleHeight)
        skinItemTitle = MessageNode(message: skin)
        skinItemTitle?.setFontColor(color: ColorCategory.BestScoreFontColor_Classic)
        skinItemTitle!.adjustLabelFontSizeToFitRect(rect: skinItemTitleFrame)
        //debugDrawArea(rect: skinItemTitleFrame)
        self.addChild(skinItemTitle!)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:- Helper Functions
    func setFontSize (fontSize: CGFloat) {
        skinItemTitle!.setFontSize(fontSize: fontSize)
    }
    
    func getFontSize () -> CGFloat {
        return skinItemTitle!.fontSize
    }
    
    func setFontColor (fontColor: UIColor) {
        skinItemTitle!.setFontColor(color: fontColor)
    }
    
    func pointInBoardLayerFor(column: Int, row: Int) -> CGPoint {
        let xCoord = CGFloat(column)*(tileWidth+cellSpacing) + tileWidth/2 + boardSpacingX
        let yCoord = CGFloat(row)*(tileWidth+cellSpacing) + tileWidth/2 + boardSpacingY
        
        return CGPoint(x: xCoord, y: yCoord)
    }
    
    func getBackgroundColor() -> SKColor {
        
        let selectedSkin = self.skinItem
        
        if selectedSkin == "Classic" {
            return ColorCategory.BackgroundColor_Classic
        } else if selectedSkin == "Day" {
            return ColorCategory.BackgroundColor_Day
        } else if selectedSkin == "Night" {
            return ColorCategory.BackgroundColor_Night
        } else if selectedSkin == "Colorblind" {
            return ColorCategory.BackgroundColor_Colorblind
        } else {
            return SKColor.clear
        }
    }
    
    func getBlockColorAtIndex(index:UInt32) -> SKColor {
        
        let selectedSkin = self.skinItem
        
        // Skin 1: Day
        if selectedSkin == "Day" {
            switch index {
            case 1:
                return ColorCategory.BlockColor1_Day
            case 2:
                return ColorCategory.BlockColor2_Day
            case 3:
                return ColorCategory.BlockColor3_Day
            case 4:
                return ColorCategory.BlockColor4_Day
            case 5:
                return ColorCategory.BlockColor5_Day
            case 6:
                return ColorCategory.BlockColor6_Day
            case 7:
                return ColorCategory.BlockColor7_Day
            case 8:
                return ColorCategory.BlockColor8_Day
            case 9:
                return ColorCategory.BlockColor9_Day
            default:
                return SKColor.clear
            }
        } else if selectedSkin == "Classic" {
            switch index {
            case 1:
                return ColorCategory.BlockColor1_Classic
            case 2:
                return ColorCategory.BlockColor2_Classic
            case 3:
                return ColorCategory.BlockColor3_Classic
            case 4:
                return ColorCategory.BlockColor4_Classic
            case 5:
                return ColorCategory.BlockColor5_Classic
            case 6:
                return ColorCategory.BlockColor6_Classic
            case 7:
                return ColorCategory.BlockColor7_Classic
            case 8:
                return ColorCategory.BlockColor8_Classic
            case 9:
                return ColorCategory.BlockColor9_Classic
            default:
                return SKColor.clear
            }
        } else if selectedSkin == "Night" {
            switch index {
            case 1:
                return ColorCategory.BlockColor1_Night
            case 2:
                return ColorCategory.BlockColor2_Night
            case 3:
                return ColorCategory.BlockColor3_Night
            case 4:
                return ColorCategory.BlockColor4_Night
            case 5:
                return ColorCategory.BlockColor5_Night
            case 6:
                return ColorCategory.BlockColor6_Night
            case 7:
                return ColorCategory.BlockColor7_Night
            case 8:
                return ColorCategory.BlockColor8_Night
            case 9:
                return ColorCategory.BlockColor9_Night
            default:
                return SKColor.clear
            }
        } else if selectedSkin == "Colorblind" {
            switch index {
            case 1:
                return ColorCategory.BlockColor1_Colorblind
            case 2:
                return ColorCategory.BlockColor2_Colorblind
            case 3:
                return ColorCategory.BlockColor3_Colorblind
            case 4:
                return ColorCategory.BlockColor4_Colorblind
            case 5:
                return ColorCategory.BlockColor5_Colorblind
            case 6:
                return ColorCategory.BlockColor6_Colorblind
            case 7:
                return ColorCategory.BlockColor7_Colorblind
            case 8:
                return ColorCategory.BlockColor8_Colorblind
            case 9:
                return ColorCategory.BlockColor9_Colorblind
            default:
                return SKColor.clear
            }
        } else {
            return SKColor.clear
        }
    }
    
    func debugDrawArea(rect drawRect: CGRect) {
        let shape = SKShapeNode(rect: drawRect)
        shape.strokeColor = SKColor.red
        shape.lineWidth = 2.0
        self.addChild(shape)
    }
    
    //MARK:- Touch Events
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.zPosition = 100
        self.skinItemNodeDelegate.skinItemNodeWasReleased(sender: self, skinItem: self.skinItem)
    }
    
}

