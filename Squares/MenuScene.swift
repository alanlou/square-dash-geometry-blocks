//
//  MenuScene.swift
//  Squares
//
//  Created by Alan Lou on 1/15/18.
//  Copyright © 2018 Rawwr Studios. All rights reserved.
//


import SpriteKit

class MenuScene: SKScene, MenuButtonDelegate, PlayButtonDelegate {
    
    // set up nodes container
    let nodeLayer = SKNode()
    var isAdReady = false
    var safeAreaRect: CGRect!
    
    let buttonPressedSound: SKAction = SKAction.playSoundFileNamed(
        "buttonPressed.wav", waitForCompletion: false)
    
    var gameSoundOn: Bool? {
        get {
            if  UserDefaults.standard.object(forKey: "gameSoundOn") == nil {
                UserDefaults.standard.set(true, forKey: "gameSoundOn")
            }
            return UserDefaults.standard.bool(forKey: "gameSoundOn")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "gameSoundOn")
        }
    }

    var bestScore: Int {
        get {
            return UserDefaults.standard.integer(forKey: "highScore")
        }
    }
    
    //MARK:- Initialization
    override init(size: CGSize) {
        super.init(size: size)
        
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        // set up background
        self.backgroundColor = ColorCategory.BackgroundColor
        self.view?.isMultipleTouchEnabled = false
        
        let safeSets = view.safeAreaInsets
        safeAreaRect = CGRect(x: safeSets.left,
                              y: safeSets.bottom,
                              width: size.width-safeSets.right-safeSets.left,
                              height: size.height-safeSets.top-safeSets.bottom)
        
        nodeLayer.position = CGPoint(x: 0.0, y: safeSets.bottom)
        self.addChild(nodeLayer)
        
        // add title
        let texture = SKTexture(imageNamed: "SquaresTitle")
        let gameTitle = SKSpriteNode(texture: texture, color: .clear, size: CGSize(width: size.width*0.75, height: size.width*0.75*texture.size().height/texture.size().width))
        gameTitle.position = CGPoint(x: safeAreaRect.width/2,
                                      y: safeAreaRect.height*0.8)
        nodeLayer.addChild(gameTitle)
        
        
        // add play button
        let playButtonWidth = min(safeAreaRect.width/3,safeAreaRect.height/5)
        let playButton = PlayButtonNode(color: ColorCategory.ContinueButtonColor, width: playButtonWidth, type: PlayButtonType.PlayButton)
        playButton.position = CGPoint(x: safeAreaRect.width/2,
                                      y: safeAreaRect.height/2-playButton.size.height/2)
        playButton.buttonDelegate = self
        nodeLayer.addChild(playButton)
        
        // add best score boarder
        let bestScoreBarNode = BestScoreBarNode(color: ColorCategory.BestScoreFontColor.withAlphaComponent(0.55), width: safeAreaRect.width/1.7)
        bestScoreBarNode.position = CGPoint(x: safeAreaRect.width/2.0,
                                            y: (gameTitle.frame.minY + playButton.frame.maxY)/2.0)
        nodeLayer.addChild(bestScoreBarNode)
        
        // add trophy
        let trophy = TrophyNode(color: ColorCategory.TrophyColor, height: bestScoreBarNode.size.height*0.63)
        trophy.anchorPoint = CGPoint(x:0.0, y:0.5)
        trophy.position = CGPoint(x: -bestScoreBarNode.size.width/2.0+bestScoreBarNode.size.height*0.16,
                                      y: 0.0)
        bestScoreBarNode.addChild(trophy)
        
        // add best score label
        let bestScoreNodeWidth = bestScoreBarNode.size.width/3.0
        let bestScoreNodeHeight = bestScoreBarNode.size.height/3.0
        let bestScoreLabelNodeFrame = CGRect(x: bestScoreBarNode.size.height*0.16-bestScoreNodeWidth/2, y: bestScoreBarNode.size.height/18.0, width: bestScoreNodeWidth, height: bestScoreNodeHeight)
        let bestScoreLabelNode = MessageNode(message: "BEST")
        bestScoreLabelNode.adjustLabelFontSizeToFitRect(rect: bestScoreLabelNodeFrame)
        bestScoreBarNode.addChild(bestScoreLabelNode)
        
        // add best score
        let bestScoreNodeFrame = CGRect(x: bestScoreBarNode.size.height*0.16-bestScoreNodeWidth/2, y: -bestScoreBarNode.size.height/18.0-bestScoreNodeHeight, width: bestScoreNodeWidth, height: bestScoreNodeHeight)
        let bestScoreNode = MessageNode(message: "\(bestScore)")
        bestScoreNode.adjustLabelFontSizeToFitRect(rect: bestScoreNodeFrame)
        bestScoreBarNode.addChild(bestScoreNode)
        
        /*** add buttons ***/
        let buttonWidth = playButtonWidth/2.5
        let positionArmRadius = min(safeAreaRect.width/(2.0*cos(CGFloat.pi/6.0)) * 0.8 - buttonWidth*0.5, playButtonWidth*1.2)
        
        // 1. Add Sound button
        var iconTypeHere = IconType.SoundOnButton
        if let gameSoundOn = gameSoundOn {
            iconTypeHere = gameSoundOn ? IconType.SoundOnButton : IconType.SoundOffButton
        }
        let soundButton = MenuButtonNode(color: ColorCategory.SoundButtonColor,
                                         buttonType: ButtonType.RoundButton,
                                         iconType: iconTypeHere,
                                         width: buttonWidth)
        soundButton.position = CGPoint(x: safeAreaRect.width/2-positionArmRadius*sin(CGFloat.pi*1/3),
                                       y: playButton.position.y-positionArmRadius*cos(CGFloat.pi*1/3))
        soundButton.name = "soundbutton"
        soundButton.buttonDelegate = self
        nodeLayer.addChild(soundButton)
        
        // 2. Add LeaderBoard button
        let leaderBoardButton = MenuButtonNode(color: ColorCategory.SoundButtonColor,
                                               buttonType: ButtonType.RoundButton,
                                               iconType: IconType.LeaderBoardButton,
                                               width: buttonWidth)
        leaderBoardButton.position = CGPoint(x: safeAreaRect.width/2-positionArmRadius*sin(CGFloat.pi/6.0),
                                             y: playButton.position.y-positionArmRadius*cos(CGFloat.pi/6.0))
        leaderBoardButton.name = "leaderboardbutton"
        leaderBoardButton.buttonDelegate = self
        nodeLayer.addChild(leaderBoardButton)
        
        // 3. Add Twitter button
        let twitterButton = MenuButtonNode(color: ColorCategory.SoundButtonColor,
                                         buttonType: ButtonType.RoundButton,
                                         iconType: IconType.TwitterButton,
                                         width: buttonWidth)
        twitterButton.position = CGPoint(x: safeAreaRect.width/2,
                                       y: playButton.position.y-positionArmRadius)
        twitterButton.name = "twitterbutton"
        twitterButton.buttonDelegate = self
        nodeLayer.addChild(twitterButton)
        
        
        // 4. Add Information button
        let infoButton = MenuButtonNode(color: ColorCategory.SoundButtonColor,
                                           buttonType: ButtonType.RoundButton,
                                           iconType: IconType.InfoButton,
                                           width: buttonWidth)
        infoButton.position = CGPoint(x: safeAreaRect.width/2+positionArmRadius*sin(CGFloat.pi/6.0),
                                         y: playButton.position.y-positionArmRadius*cos(CGFloat.pi/6.0))
        infoButton.name = "infobutton"
        infoButton.buttonDelegate = self
        nodeLayer.addChild(infoButton)
        
        // 5. Add NoAds button
        let noAdsButton = MenuButtonNode(color: ColorCategory.SoundButtonColor,
                                         buttonType: ButtonType.RoundButton,
                                         iconType: IconType.NoAdsButton,
                                         width: buttonWidth)
        noAdsButton.position = CGPoint(x: safeAreaRect.width/2+positionArmRadius*sin(CGFloat.pi*1/3),
                                       y: playButton.position.y-positionArmRadius*cos(CGFloat.pi*1/3))
        noAdsButton.name = "noadsbutton"
        noAdsButton.buttonDelegate = self
        nodeLayer.addChild(noAdsButton)
        
    }
    
    //MARK:- PlayButtonNode Delegate
    func playButtonWasPressed(sender: PlayButtonNode) {
        if view != nil {
            let transition:SKTransition = SKTransition.fade(withDuration: 0.5)
            let gameScene = GameScene(size: self.size)
            gameScene.isAdReady = self.isAdReady
            self.view?.presentScene(gameScene, transition: transition)
        }
        return
    }
    
    
    //MARK:- MenuButtonNode Delegate
    func buttonWasPressed(sender: MenuButtonNode) {
        let iconType = sender.getIconType()
        
        // play sound
        if let gameSoundOn = gameSoundOn,
            gameSoundOn,
            iconType != IconType.SoundOffButton {
            self.run(buttonPressedSound)
        }
        
        // make action based on icon type
        if iconType == IconType.SoundOnButton  {
            gameSoundOn = true
            self.run(buttonPressedSound)
            return
        }
        if iconType == IconType.SoundOffButton  {
            gameSoundOn = false
            return
        }
        if iconType == IconType.TwitterButton  {
            guard let url = URL(string: "https://mobile.twitter.com/rawwrstudios") else {
                return //be safe
            }
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
            return
        }
        
    }
    
    func animateNodesFadeIn() {
        /*** Animate nodeLayer ***/
        nodeLayer.alpha = 0.0
        nodeLayer.run(SKAction.fadeIn(withDuration: 0.2))
    }
    
}
