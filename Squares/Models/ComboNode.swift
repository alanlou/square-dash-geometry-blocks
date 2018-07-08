//
//  ComboNode.swift
//  Squares
//
//  Created by Alan Lou on 1/3/18.
//  Copyright © 2018 Rawwr Studios. All rights reserved.
//


import SpriteKit

class ComboNode: SKLabelNode {
    private var combo: Int = 0
    private var numberDigits: Int = 1
    private var boundingRect: CGRect?
    
    override init() {
        super.init()
        text = "x\(combo)"
        fontName = "ChalkboardSE-Light"
        fontSize = 150
        fontColor = ColorCategory.getBestScoreFontColor()
        alpha = 0.0
        zPosition = 100
        horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // helper functions
    
    func setFontColor (color: UIColor) {
        self.fontColor = color
    }
    
    func setCombo(to combo: Int){
        self.combo = combo
        if let boundingRect = boundingRect, combo.digitCount>numberDigits {
            self.adjustLabelFontSizeToFitRect(rect: boundingRect)
        }
        
        // animate the update
        let duration = 0.14
        let scaleUp = SKAction.scale(to: 1.2, duration: duration)
        let updateText = SKAction.run() { [weak self] in
            self?.text = "x\(self?.getCombo() ?? 0)"
        }
        let scaleXDown = SKAction.scaleX(to: 0.8, duration: duration)
        let scaleXUp = SKAction.scaleX(to: 1.1, duration: duration)
        let scaleXBack = SKAction.scaleX(to: 1.0, duration: duration/2)
        let scaleDown = SKAction.scale(to: 0.95, duration: duration)
        let scaleBack = SKAction.scale(to: 1.0, duration: duration/2)
        self.run(SKAction.sequence([scaleUp, updateText,
                                    SKAction.group([scaleXDown, scaleDown]),
                                    SKAction.group([scaleBack, scaleXUp]),
                                    scaleXBack]))
        
        shakeNode(layer: self, duration: 0.2, magnitude: CGFloat(combo)*0.2)
    }
    
    func recallSetCombo(to combo: Int){
        self.combo = combo
        self.text = "x\(combo)"
        if let boundingRect = boundingRect, combo.digitCount>numberDigits {
            self.adjustLabelFontSizeToFitRect(rect: boundingRect)
        }
        
        if combo < 2 {
            self.run(SKAction.fadeOut(withDuration: 0.2))
        } else {
            self.run(SKAction.fadeIn(withDuration: 0.35))
        }
    }
    
    
    func adjustLabelFontSizeToFitRect(rect:CGRect) {
        if boundingRect == nil{
            boundingRect = rect
        }
        
        // determine the font scaling factor that should let the label text fit in the given rectangle
        let scalingFactor = min(rect.width / self.frame.width, rect.height / self.frame.height)
        
        // change the fontSize
        self.fontSize *= scalingFactor
        
        // optionally move the SKLabelNode to the center of the rectangle
        self.position = CGPoint(x: rect.midX, y: rect.midY)
    }
    
    func getCombo() -> Int {
        return self.combo
    }
    
    func shakeNode(layer:SKNode, duration:Float, magnitude: CGFloat) {
        let amplitudeX:CGFloat = 10.0 * magnitude;
        let amplitudeY:CGFloat = 6.0 * magnitude;
        let numberOfShakes = duration / 0.04;
        var actionsArray:[SKAction] = [];
        for _ in 1...Int(numberOfShakes) {
            let moveX = CGFloat(arc4random_uniform(UInt32(amplitudeX))) - amplitudeX/2.0
            let moveY = CGFloat(arc4random_uniform(UInt32(amplitudeY))) - amplitudeY/2.0
            let shakeAction = SKAction.moveBy(x: CGFloat(moveX), y: CGFloat(moveY), duration: 0.02)
            shakeAction.timingMode = SKActionTimingMode.easeOut
            actionsArray.append(shakeAction)
            actionsArray.append(shakeAction.reversed())
        }
        actionsArray.append(SKAction.wait(forDuration: 2.5))
        
        let actionSeq = SKAction.sequence(actionsArray)
        layer.run(SKAction.repeatForever(actionSeq))
    }
    
}



