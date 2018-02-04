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
    static let TwitterButton:  String = "Twitter"
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
    init(color: SKColor, buttonType: String, iconType: String, width: CGFloat) {
        self.iconNode = SKSpriteNode()
        self.buttonType = buttonType
        self.iconType = iconType
        let buttonTexture = SKTexture(imageNamed: buttonType)
        let buttonTextureSize = CGSize(width: width, height: width*buttonTexture.size().height/buttonTexture.size().width)
        super.init(texture: buttonTexture, color: .clear, size: buttonTextureSize)
        self.name = "menubutton"
        isUserInteractionEnabled = true
        
        self.color = color
        self.colorBlendFactor = 1.0
        
        // texture
        let iconTexture = SKTexture(imageNamed: iconType)
        let iconTextureSize = CGSize(width: width*iconTexture.size().width/buttonTexture.size().width, height: width*iconTexture.size().height/buttonTexture.size().width)
        iconNode = SKSpriteNode(texture: iconTexture, color: .white, size: iconTextureSize)
        iconNode.position = CGPoint(x:0, y:0)
        iconNode.zPosition = 2000
        self.addChild(iconNode)
        
        if buttonType == ButtonType.RoundButton {
            self.performWobbleAction()
        }
        
        if iconType == IconType.ShareButton {
            self.performShareWobbleAction()
        }
    }
    
    convenience init(color: SKColor, buttonType: String, iconType: String, height: CGFloat) {
        
        let buttonTexture = SKTexture(imageNamed: buttonType)
        let width = height*buttonTexture.size().width/buttonTexture.size().height
        
        self.init(color: color, buttonType: buttonType, iconType: iconType, width: width)
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
            let scaleUp = SKAction.scale(to: 1.15, duration: 0.12)
            self.run(scaleUp, withKey: "scaleup")
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self.parent!)
        
        if self.contains(touchLocation) {
            if let _ = self.action(forKey: "scaleup") {
            } else {
                let scaleUp = SKAction.scale(to: 1.15, duration: 0.12)
                self.run(scaleUp, withKey: "scaleup")
            }
        } else {
            let scaleDown = SKAction.scale(to: 1.0, duration: 0.08)
            self.run(scaleDown)
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self.parent!)
        
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.08)
        self.removeAction(forKey: "scaleup")
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
    
    func performShareWobbleAction() {
        // perform wobble action
        let wobbleLeftSmall1 = SKAction.rotate(byAngle: -CGFloat.pi * 1/7, duration: 0.22)
        let wobbleRight = SKAction.rotate(byAngle: CGFloat.pi * 1/3.5, duration: 0.44)
        let wobbleLeftSmall2 = SKAction.rotate(byAngle: -CGFloat.pi * 1/7, duration: 0.22)
        wobbleLeftSmall1.timingMode = .easeOut
        wobbleRight.timingMode = .easeInEaseOut
        wobbleLeftSmall2.timingMode = .easeIn
        let wobbleAction = SKAction.repeatForever(SKAction.sequence([wobbleLeftSmall1,wobbleRight,wobbleLeftSmall2]))
        self.run(wobbleAction)
    }

    
}

