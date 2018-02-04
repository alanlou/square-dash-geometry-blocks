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
    var numRecall: Int = 3
    
    // variables
    private var _isRecallPossible: Bool = false
    var isAdsRecallPossible: Bool = false
    var isRecallPossible: Bool {
        get {
            return _isRecallPossible
        }
        set {
            self._isRecallPossible = newValue
            if newValue {
                print("---")
                print(numRecall)
                print(isAdsRecallPossible)
                if numRecall > 0 || isAdsRecallPossible {
                    self.run(SKAction.fadeAlpha(to: 1.0, duration: 0.4), completion: { [weak self] in
                        self?.isUserInteractionEnabled = true
                    })
                }
            } else {
                self.isUserInteractionEnabled = false
                self.run(SKAction.fadeAlpha(to: 0.2, duration: 0.1))
            }
        }
    }
    
    //MARK:- Initialization
    init(color: SKColor, width: CGFloat){
        let texture = SKTexture(imageNamed: "RecallButton")
        let textureSize = CGSize(width: width*0.76, height: width*texture.size().height/texture.size().width*0.76)
    
        super.init(texture: nil, color: .clear, size: CGSize(width: width*1.3, height: width*1.5))
        
        self.name = "Recallbutton"
        self.anchorPoint = CGPoint(x:0.0, y:1.0)
        self.isUserInteractionEnabled = false
        self.alpha = 0.2
        
        // set up Recall button node
        recallButtonNode = SKSpriteNode(texture: texture, color: .clear, size: textureSize)
        recallButtonNode.colorBlendFactor = 1.0
        recallButtonNode.anchorPoint = CGPoint(x:0.0, y:1.0)
        recallButtonNode.position = CGPoint(x:width*0.15, y:-width*0.38)
        
        // set up numRecall message node
        numRecallMessageNode = MessageNode(message: "\(numRecall)")
        let messageNodeFrame = CGRect(x: width*0.80,
                                      y: -width*0.69,
                                      width: width*0.45,
                                      height: width*0.45)
        numRecallMessageNode.adjustLabelFontSizeToFitRect(rect: messageNodeFrame)
        numRecallMessageNode.setHorizontalAlignment(mode: .left)
        //debugDrawArea(rect: messageNodeFrame)
        
        // add children
        self.addChild(recallButtonNode)
        self.addChild(numRecallMessageNode)
        
        // change color
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
                performRecallAction()
                
                // Used all recall chances. Add AdsRecall Node
                if numRecall == 0 {
//                    isAdsRecallPossible = true
                    
                    let texture = SKTexture(imageNamed: "AdsVideo")
                    let adsVideoNode = SKSpriteNode(texture: texture, color: .clear, size: texture.size())
                    adsVideoNode.color = ColorCategory.RecallButtonColor
                    adsVideoNode.colorBlendFactor = 1.0
                    adsVideoNode.anchorPoint = CGPoint(x:0.35, y:0.35)
                    adsVideoNode.position = numRecallMessageNode.position
                    adsVideoNode.setScale(0.0)
                    self.addChild(adsVideoNode)
                    adsVideoNode.run(SKAction.scale(to: 1.0, duration: 0.1))
                    
                    numRecallMessageNode.removeFromParent()
                    
                }
                // exit function
                return
            }
            
            if isAdsRecallPossible {
                // RUN ADS HERE!
                print("Run Ads")
                NotificationCenter.default.post(name: Notification.Name(rawValue: "runRewardAds"), object: nil)
                
                disableAdsRecall()
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
    
    func enableAdsRecall() {
        print("ENABLE ADS RECALL!")
        isAdsRecallPossible = true
        if isRecallPossible {
            self.run(SKAction.fadeAlpha(to: 1.0, duration: 0.4), completion: { [weak self] in
                self?.isUserInteractionEnabled = true
            })
        }
    }
    
    func disableAdsRecall() {
        isAdsRecallPossible = false
        self.isUserInteractionEnabled = false
        self.run(SKAction.fadeAlpha(to: 0.2, duration: 0.1))
    }
    
    func performRecallAction() {
        self.buttonDelegate.recallButtonWasPressed(sender: self)
    }
    
    
}
