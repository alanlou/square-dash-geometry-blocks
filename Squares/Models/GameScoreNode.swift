//
//  GameScoreNode.swift
//  Squares
//
//  Created by Alan Lou on 1/3/18.
//  Copyright © 2018 Rawwr Studios. All rights reserved.
//

import SpriteKit

class GameScoreNode: SKLabelNode {
    private var gameScore: Int = 0
    private var numberDigits: Int = 1
    private var boundingRect: CGRect?
    
    override init() {
        super.init()
        text = "\(gameScore)"
        fontName = "ChalkboardSE-Light"
        fontSize = 150
        fontColor = ColorCategory.ScoreFontColor
        zPosition = 100
        horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // helper functions
    func setGameScore(to score: Int){
        gameScore = score
        if let boundingRect = boundingRect, score.digitCount>numberDigits {
            self.adjustLabelFontSizeToFitRect(rect: boundingRect)
        }
        numberDigits = score.digitCount
        
        
        // animate the update
        let duration = 0.14
        let scaleUp = SKAction.scale(to: 1.24, duration: duration)
        let updateText = SKAction.run() { [weak self] in
            self?.text = "\(self?.getGameScore() ?? 0)"
        }
        let scaleXDown = SKAction.scaleX(to: 0.8, duration: duration)
        let scaleXUp = SKAction.scaleX(to: 1.2, duration: duration)
        let scaleXBack = SKAction.scaleX(to: 1.0, duration: duration/2)
        let scaleDown = SKAction.scale(to: 0.9, duration: duration)
        let scaleBack = SKAction.scale(to: 1.0, duration: duration/2)
        self.run(SKAction.sequence([scaleUp, updateText,
                                    SKAction.group([scaleXDown, scaleDown]),
                                    SKAction.group([scaleBack, scaleXUp]),
                                    scaleXBack]))
    }
    
    func recallSetGameScore(to score: Int){
        gameScore = score
        if let boundingRect = boundingRect, score.digitCount>numberDigits {
            self.adjustLabelFontSizeToFitRect(rect: boundingRect)
        }
        numberDigits = score.digitCount
        
        // animate the update
        let duration = 0.14
        let updateText = SKAction.run() { [weak self] in
            self?.text = "\(self?.getGameScore() ?? 0)"
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
    
    func getGameScore() -> Int {
        return self.gameScore
    }
}


