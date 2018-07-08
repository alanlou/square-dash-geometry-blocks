//
//  BestScoreNode.swift
//  Squares
//
//  Created by Alan Lou on 1/1/18.
//  Copyright © 2018 Rawwr Studios. All rights reserved.
//

import SpriteKit

class BestScoreNode: SKLabelNode {
    private var numberDigits: Int = 1
    private var boundingRect: CGRect?
    var bestScore: Int {
        get {
            return UserDefaults.standard.integer(forKey: "highScore")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "highScore")
        }
    }
    
    override init() {
        super.init()
        text = "BEST: \(bestScore)"
        fontName = "ChalkboardSE-Light"
        fontSize = 16
        fontColor = ColorCategory.getBestScoreFontColor()
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
    
    func setBestScore(to score: Int){
        if bestScore == score {
            return
        }
        
        bestScore = score
        numberDigits = score.digitCount
        
        // animate the update
        let duration = 0.14
        let updateText = SKAction.run() { [weak self] in
            self?.text = "BEST: \(self?.bestScore ?? 0)"
        }
        let scaleXDown = SKAction.scaleX(to: 0.8, duration: duration)
        let scaleXUp = SKAction.scaleX(to: 1.2, duration: duration)
        let scaleXBack = SKAction.scaleX(to: 1.0, duration: duration/2)
        let scaleDown = SKAction.scale(to: 0.8, duration: duration)
        let scaleBack = SKAction.scale(to: 1.0, duration: duration/2)
        self.run(SKAction.sequence([updateText,
                                    SKAction.group([scaleXDown, scaleDown]),
                                    SKAction.group([scaleBack, scaleXUp]),
                                    scaleXBack]))
    }
    
    func getBestScore() -> Int {
        return bestScore
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
    
    
    func adjustLabelFontSizeToFitRectRight(rect:CGRect) {
        if boundingRect == nil{
            boundingRect = rect
        }
        // determine the font scaling factor that should let the label text fit in the given rectangle
        let scalingFactor = min(rect.width / self.frame.width, rect.height / self.frame.height)
        // change the fontSize
        self.fontSize *= scalingFactor
        // optionally move the SKLabelNode to the center of the rectangle
        self.position = CGPoint(x: rect.maxX, y: rect.midY)
        horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
    }
}


