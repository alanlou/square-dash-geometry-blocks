//
//  MenuButtonNode.swift
//  Squares
//
//  Created by Alan Lou on 1/1/18.
//  Copyright © 2018 Rawwr Studios. All rights reserved.
//


import SpriteKit

protocol MenuButtonDelegate: NSObjectProtocol {
    func buttonWasPressed(sender: MenuButtonNode)
}

struct ButtonType {
    static let LongButton:  String = "LongButton"
    static let ShortButton:  String = "ShortButton"
    static let RoundButton:  String = "RoundButton"
}

struct IconType {
    static let ResumeButton:  String = "Resume"
    static let PlayButton:  String = "Resume"
    static let RestartButton:  String = "Restart"
    static let ShareButton:  String = "Share"
    static let HomeButton:  String = "Home"
    static let SoundOnButton:  String = "Sound"
    static let SoundOffButton:  String = "SoundMute"
    static let LeaderBoardButton:  String = "Medal"
    static let StoreButton:  String = "Store"
    static let NoAdsButton:  String = "NoAds"
}

class MenuButtonNode: SKSpriteNode {
    var buttonType: String
    var iconType: String
    var iconNode: SKSpriteNode
    var gameSoundOn: Bool? {
        get {
            return UserDefaults.standard.bool(forKey: "gameSoundOn")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "gameSoundOn")
        }
    }
    weak var buttonDelegate: MenuButtonDelegate!
    
    //MARK:- Initialization
    init(buttonType: String, iconType: String) {
        self.iconNode = SKSpriteNode()
        self.buttonType = buttonType
        self.iconType = iconType
        let buttonTexture = SKTexture(imageNamed: buttonType)
        super.init(texture: buttonTexture, color: .clear, size: buttonTexture.size())
        self.name = "menubutton"
        isUserInteractionEnabled = true
        
        // texture
        let iconTexture = SKTexture(imageNamed: iconType)
        iconNode = SKSpriteNode(texture: iconTexture, color: .white, size: iconTexture.size())
        iconNode.position = CGPoint(x:0, y:0)
        iconNode.zPosition = 2000
        self.addChild(iconNode)
        
        if buttonType == ButtonType.RoundButton {
            self.performWobbleAction()
        }
    }
    
    convenience init(color: SKColor, buttonType: String, iconType: String) {
        self.init(buttonType: buttonType, iconType: iconType)
        self.color = color
        self.colorBlendFactor = 1.0
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:- Helper Functions
    func changeColor(to color: SKColor) {
        self.color = color
        self.colorBlendFactor = 1.0
    }
    
    func getIconType() -> String {
        
        return self.iconType
    }
    
    //MARK:- Interactive Node
    func interact() {
        
        if iconType == IconType.SoundOnButton {
            iconType = IconType.SoundOffButton
            let texture = SKTexture(imageNamed: iconType)
            iconNode.texture = texture
            return
        }
        if iconType == IconType.SoundOffButton {
            iconType = IconType.SoundOnButton
            let texture = SKTexture(imageNamed: iconType)
            iconNode.texture = texture
            return
        }
    }
    
    // MARK:- Touch Events
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self.parent!)
        
        if self.contains(touchLocation) {
            let scaleUp = SKAction.scale(to: 1.1, duration: 0.15)
            self.run(scaleUp)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self.parent!)
        
        if self.contains(touchLocation) {
            let scaleUp = SKAction.scale(to: 1.1, duration: 0.10)
            self.run(scaleUp)
        } else {
            let scaleDown = SKAction.scale(to: 1.0, duration: 0.08)
            self.run(scaleDown)
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self.parent!)
        
        self.zRotation = 0.0
        self.removeAllActions()
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.08)
        self.run(scaleDown)
        
        if self.contains(touchLocation) {
            interact()
            self.buttonDelegate.buttonWasPressed(sender: self)
        }
    }
    
    func performWobbleAction() {
        // perform wobble action
        let wobbleLeftSmall = SKAction.rotate(byAngle: -CGFloat.pi * 1/20, duration: 0.08)
        let wobbleRight = SKAction.rotate(byAngle: CGFloat.pi * 1/10, duration: 0.16)
        let wait = SKAction.wait(forDuration: 4.0)
        let wobbleAction = SKAction.repeatForever(SKAction.sequence([wobbleLeftSmall,wobbleRight,wobbleLeftSmall,wait]))
        self.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),wobbleAction]))
    }
    
}

