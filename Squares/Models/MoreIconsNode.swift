//
//  MoreIconsNode.swift
//  Squares
//
//  Created by Alan Lou on 2/7/18.
//  Copyright © 2018 Rawwr Studios. All rights reserved.
//

import SpriteKit

class MoreIconsNode: SKSpriteNode {
    // buttons inside
    var moreIconsButton: MenuButtonNode
    var noAdsButton: MenuButtonNode
    var restoreIAPButton: MenuButtonNode
    var likeButton: MenuButtonNode
    var tutorialButton: MenuButtonNode
    
    // boolean
    var isOpen: Bool = false
    
    //MARK:- Initialization
    init(color: SKColor, width: CGFloat) {
        
        // 1. Add moreIcons button
        moreIconsButton = MenuButtonNode(color: color,
                                         buttonType: ButtonType.RoundButton,
                                         iconType: IconType.MoreIconsButton,
                                         width: width)
        moreIconsButton.position = CGPoint(x: 0.0, y: 0.0)
        moreIconsButton.name = "moreiconsbutton"
        
        // 2. Add noAds button
        noAdsButton = MenuButtonNode(color: color,
                                         buttonType: ButtonType.RoundButton,
                                         iconType: IconType.NoAdsButton,
                                         width: width*0.8)
        noAdsButton.position = CGPoint(x: 0.0, y: 0.0)
        noAdsButton.alpha = 0.0
        noAdsButton.name = "noadsbutton"
        
        // 3. Add restoreIAP button
        restoreIAPButton = MenuButtonNode(color: color,
                                     buttonType: ButtonType.RoundButton,
                                     iconType: IconType.RestoreIAPButton,
                                     width: width*0.8)
        restoreIAPButton.position = CGPoint(x: 0.0, y: 0.0)
        restoreIAPButton.alpha = 0.0
        restoreIAPButton.name = "restoreIAPbutton"
        
        // 4. Add like button
        likeButton = MenuButtonNode(color: color,
                                          buttonType: ButtonType.RoundButton,
                                          iconType: IconType.LikeButton,
                                          width: width*0.8)
        likeButton.position = CGPoint(x: 0.0, y: 0.0)
        likeButton.alpha = 0.0
        likeButton.name = "likebutton"
        
        // 5. Add tutorial button
        tutorialButton = MenuButtonNode(color: color,
                                    buttonType: ButtonType.RoundButton,
                                    iconType: IconType.InfoButton,
                                    width: width*0.8)
        tutorialButton.position = CGPoint(x: 0.0, y: 0.0)
        tutorialButton.alpha = 0.0
        tutorialButton.name = "tutorialbutton"
        
        // underlying larger area
        super.init(texture: nil, color: .clear, size: CGSize(width: width, height: width))
        
        self.name = "moreicons"
        self.anchorPoint = CGPoint(x:0.5, y:5.5)
        self.isUserInteractionEnabled = true
        
        
        // add buttons
        self.addChild(moreIconsButton)
        self.addChild(noAdsButton)
        self.addChild(restoreIAPButton)
        self.addChild(likeButton)
        self.addChild(tutorialButton)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:- Helper Functions
    func changeColor(to color: SKColor) {
        moreIconsButton.color = color
        moreIconsButton.colorBlendFactor = 1.0
    }
    
    func interact() {
        let duration1 = 0.3
        let duration2 = 0.08
        if !isOpen {
            // rotate right to open
            let rotateRight = SKAction.rotate(byAngle: -CGFloat.pi*0.58, duration: duration1)
            rotateRight.timingMode = .easeOut
            let rotateLeft = SKAction.rotate(byAngle: CGFloat.pi*0.08, duration: duration2)
            moreIconsButton.run(SKAction.sequence([rotateRight,rotateLeft]))
            
            // expand icons
            let offset = self.size.height*0.1
            let moveLength = self.size.height*0.9
            let moveUp1 = SKAction.move(to: CGPoint(x:0.0, y:offset+moveLength+5.0), duration: duration1)
            let moveUp2 = SKAction.move(to: CGPoint(x:0.0, y:offset+moveLength*2.0+5.0), duration: duration1)
            let moveUp3 = SKAction.move(to: CGPoint(x:0.0, y:offset+moveLength*3.0+5.0), duration: duration1)
            let moveUp4 = SKAction.move(to: CGPoint(x:0.0, y:offset+moveLength*4.0+5.0), duration: duration1)
            let moveDown = SKAction.move(by: CGVector(dx:0.0, dy:-5.0), duration: duration2)
            let fadeIn = SKAction.fadeIn(withDuration: duration1+duration2)
            
            moveUp1.timingMode = .easeOut
            moveUp2.timingMode = .easeOut
            moveUp3.timingMode = .easeOut
            moveUp4.timingMode = .easeOut
            moveDown.timingMode = .easeOut
            fadeIn.timingMode = .easeOut
            
            // 1. Add noAds button
            noAdsButton.run(SKAction.group([SKAction.sequence([moveUp1,moveDown]),fadeIn]))
            // 2. Add restoreIAP button
            restoreIAPButton.run(SKAction.group([SKAction.sequence([moveUp2,moveDown]),fadeIn]))
            // 3. Add restoreIAP button
            likeButton.run(SKAction.group([SKAction.sequence([moveUp3,moveDown]),fadeIn]))
            // 4. Add tutorialIAP button
            tutorialButton.run(SKAction.group([SKAction.sequence([moveUp4,moveDown]),fadeIn]))
            
        } else {
            // rotate left to close
            let rotateLeft = SKAction.rotate(byAngle: CGFloat.pi*0.58, duration: duration1)
            rotateLeft.timingMode = .easeOut
            let rotateRight = SKAction.rotate(byAngle: -CGFloat.pi*0.08, duration: duration2)
            moreIconsButton.run(SKAction.sequence([rotateLeft,rotateRight]))
            
            // retract icons
            let moveDown = SKAction.move(to: CGPoint(x:0.0, y:0.0), duration: duration1)
            let fadeOut = SKAction.fadeOut(withDuration: duration1)
            moveDown.timingMode = .easeOut
            fadeOut.timingMode = .easeOut
            
            let retractAction = SKAction.group([moveDown,fadeOut])
            
            // 1. Add noAds button
            noAdsButton.run(retractAction)
            // 2. Add restoreIAP button
            restoreIAPButton.run(retractAction)
            // 3. Add restoreIAP button
            likeButton.run(retractAction)
            // 4. Add tutorialIAP button
            tutorialButton.run(retractAction)
            
        }
        
        
        isOpen = !isOpen
    }
}
