//
//  RecallButtonNode.swift
//  Squares
//
//  Created by Alan Lou on 1/1/18.
//  Copyright © 2018 Rawwr Studios. All rights reserved.
//

import SpriteKit

protocol RecallButtonDelegate: NSObjectProtocol {
    func recallButtonWasPressed(sender: RecallButtonNode)
}

class RecallButtonNode: SKSpriteNode {
    
    // delegate
    weak var buttonDelegate: RecallButtonDelegate!
    
    // nodes
    var recallButtonNode: SKSpriteNode!
    var numRecallMessageNode: MessageNode!
    
    // numbers
    var numRecall: Int = 33
    
    // variables
    private var _isRecallPossible: Bool = false
    var isRecallPossible: Bool {
        get {
            return _isRecallPossible
        }
        set {
            self._isRecallPossible = newValue
            if newValue {
                self.run(SKAction.fadeAlpha(to: 1.0, duration: 0.1))
                self.isUserInteractionEnabled = true
            } else {
                self.run(SKAction.fadeAlpha(to: 0.2, duration: 0.1))
                self.isUserInteractionEnabled = false
            }
        }
    }
    
    //MARK:- Initialization
    init() {
        super.init(texture: nil, color: .clear, size: CGSize(width: 50, height: 50))
        
        self.name = "Recallbutton"
        self.anchorPoint = CGPoint(x:0.0, y:1.0)
        self.isUserInteractionEnabled = false
        self.alpha = 0.2
        
        // set up Recall button node
        let texture = SKTexture(imageNamed: "RecallButton")
        recallButtonNode = SKSpriteNode(texture: texture, color: .clear, size: texture.size())
        recallButtonNode.colorBlendFactor = 1.0
        recallButtonNode.anchorPoint = CGPoint(x:0.0, y:1.0)
        recallButtonNode.position = CGPoint(x:5.0, y:-17.0) // xpos: 5 - 25
        
        // set up numRecall message node
        numRecallMessageNode = MessageNode(message: "\(numRecall)")
        let messageNodeFrame = CGRect(x: 28.0,
                                      y: -23.0,
                                      width: 15.0,
                                      height: 12.0)
        numRecallMessageNode.adjustLabelFontSizeToFitRect(rect: messageNodeFrame)
        numRecallMessageNode.setHorizontalAlignment(mode: .left)
        //debugDrawArea(rect: messageNodeFrame)
        
        // add children
        self.addChild(recallButtonNode)
        self.addChild(numRecallMessageNode)
    }
    
    convenience init(color: SKColor) {
        self.init()
        recallButtonNode.color = color
        recallButtonNode.colorBlendFactor = 1.0
        numRecallMessageNode.setFontColor(color: color)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:- Helper Functions
    func changeColor(to color: SKColor) {
        recallButtonNode.color = color
        recallButtonNode.colorBlendFactor = 1.0
        numRecallMessageNode.setFontColor(color: color)
    }
    
    //MARK:- Touch Events
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self.parent!)
        
        if self.contains(touchLocation) {
            if numRecall > 0 {
                numRecall = numRecall - 1
                self.numRecallMessageNode.setNumRecall(to: numRecall)
                self.buttonDelegate.recallButtonWasPressed(sender: self)
            } else {
                print("Cannot Recall")
            }
        }
    }
    
    //MARK:- Helper Functions
    func debugDrawArea(rect drawRect: CGRect) {
        let shape = SKShapeNode(rect: drawRect)
        shape.strokeColor = SKColor.red
        shape.lineWidth = 2.0
        self.addChild(shape)
    }
    
}