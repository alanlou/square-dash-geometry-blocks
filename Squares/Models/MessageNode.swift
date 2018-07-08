//
//  MessageNode.swift
//  Squares
//
//  Created by Alan Lou on 1/1/18.
//  Copyright © 2018 Rawwr Studios. All rights reserved.
//

import SpriteKit

class MessageNode: SKLabelNode {
    var frameRect: CGRect = CGRect()
    
    convenience init(message: String) {
        self.init(fontNamed: "ChalkboardSE-Light")
        self.name = "message"
        text = message
        fontName = "ChalkboardSE-Light"
        fontSize = 16
        fontColor = ColorCategory.getBestScoreFontColor()
        zPosition = 2000
        horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
    }
    
    // helper functions
    func adjustLabelFontSizeToFitRect(rect:CGRect) {
        frameRect = rect
        // determine the font scaling factor that should let the label text fit in the given rectangle
        let scalingFactor = min(rect.width / self.frame.width, rect.height / self.frame.height)
        // change the fontSize
        self.fontSize *= scalingFactor
        // optionally move the SKLabelNode to the center of the rectangle
        self.position = CGPoint(x: rect.midX, y: rect.midY)
    }
    
    func setFontSize (fontSize: CGFloat) {
        self.fontSize = fontSize
    }
    
    func setFontColor (color: UIColor) {
        self.fontColor = color
    }
    
    func setText(to text: String){
        self.text = text
    }
    
    func setNumRecall(to numRecall: Int){
        // animate the update
        let duration = 0.1
        let scaleDown = SKAction.scale(to: 0.5, duration: duration)
        let updateText = SKAction.run() { [weak self] in
            self?.text = "\(numRecall)"
        }
        let scaleBack = SKAction.scale(to: 1.0, duration: duration)
        self.run(SKAction.sequence([scaleDown, updateText, scaleBack]))
    }
    
    func setHorizontalAlignment (mode: SKLabelHorizontalAlignmentMode) {
        horizontalAlignmentMode = mode
        if mode == SKLabelHorizontalAlignmentMode.left {
            self.position = CGPoint(x: frameRect.minX, y: frameRect.midY)
        }
        if mode == SKLabelHorizontalAlignmentMode.center {
            self.position = CGPoint(x: frameRect.midX, y: frameRect.midY)
        }
        if mode == SKLabelHorizontalAlignmentMode.right {
            self.position = CGPoint(x: frameRect.maxX, y: frameRect.midY)
        }
    }
}

