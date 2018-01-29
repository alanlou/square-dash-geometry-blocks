//
//  MenuScene.swift
//  Squares
//
//  Created by Alan Lou on 1/15/18.
//  Copyright © 2018 Rawwr Studios. All rights reserved.
//


import SpriteKit

class MenuScene: SKScene, MenuButtonDelegate, PlayButtonDelegate {
    
    
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
        // setup background
        self.backgroundColor = ColorCategory.BackgroundColor
        self.view?.isMultipleTouchEnabled = false
        
        let safeSets = view.safeAreaInsets
        safeAreaRect = CGRect(x: safeSets.left,
                              y: safeSets.bottom,
                              width: size.width-safeSets.right-safeSets.left,
                              height: size.height-safeSets.top-safeSets.bottom)
        
        // add title
        let texture = SKTexture(imageNamed: "SquaresTitle")
        let gameTitle = SKSpriteNode(texture: texture, color: .clear, size: CGSize(width: size.width*0.75, height: size.width*0.75*texture.size().height/texture.size().width))
        gameTitle.position = CGPoint(x: safeAreaRect.width/2,
                                      y: safeAreaRect.height*3.2/4)
        self.addChild(gameTitle)
        
        
        // add play button
        let playButton = PlayButtonNode(color: ColorCategory.ContinueButtonColor, width: safeAreaRect.width/3, type: PlayButtonType.PlayButton)
        playButton.position = CGPoint(x: safeAreaRect.width/2,
                                      y: safeAreaRect.height/2-playButton.size.height/2)
        playButton.buttonDelegate = self
        self.addChild(playButton)
        
        // add best score boarder
        let bestScoreBarNode = BestScoreBarNode(color: ColorCategory.BestScoreFontColor.withAlphaComponent(0.55), width: safeAreaRect.width/1.7)
        bestScoreBarNode.position = CGPoint(x: safeAreaRect.width/2.0,
                                            y: (gameTitle.frame.minY + playButton.frame.maxY)/2.0)
        self.addChild(bestScoreBarNode)
        
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
        let buttonWidth = playButton.size.width/2.5
        let positionArmRadius = safeAreaRect.width/(2.0*cos(CGFloat.pi/6.0)) * 0.8 - buttonWidth*0.5
        
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
        self.addChild(soundButton)
        
        // 2. Add LeaderBoard button
        let leaderBoardButton = MenuButtonNode(color: ColorCategory.SoundButtonColor,
                                               buttonType: ButtonType.RoundButton,
                                               iconType: IconType.LeaderBoardButton,
                                               width: buttonWidth)
        leaderBoardButton.position = CGPoint(x: safeAreaRect.width/2-positionArmRadius*sin(CGFloat.pi/9.0),
                                             y: playButton.position.y-positionArmRadius*cos(CGFloat.pi/9.0))
        leaderBoardButton.name = "leaderboardbutton"
        leaderBoardButton.buttonDelegate = self
        self.addChild(leaderBoardButton)
        
        // 3. Add Store button
        let storeButton = MenuButtonNode(color: ColorCategory.SoundButtonColor,
                                         buttonType: ButtonType.RoundButton,
                                         iconType: IconType.StoreButton,
                                         width: buttonWidth)
        storeButton.position = CGPoint(x: safeAreaRect.width/2+positionArmRadius*sin(CGFloat.pi/9.0),
                                       y: playButton.position.y-positionArmRadius*cos(CGFloat.pi/9.0))
        storeButton.name = "storebutton"
        storeButton.buttonDelegate = self
        self.addChild(storeButton)
        
        // 4. Add NoAds button
        let noAdsButton = MenuButtonNode(color: ColorCategory.SoundButtonColor,
                                         buttonType: ButtonType.RoundButton,
                                         iconType: IconType.NoAdsButton,
                                         width: buttonWidth)
        noAdsButton.position = CGPoint(x: safeAreaRect.width/2+positionArmRadius*sin(CGFloat.pi*1/3),
                                       y: playButton.position.y-positionArmRadius*cos(CGFloat.pi*1/3))
        noAdsButton.name = "noadsbutton"
        noAdsButton.buttonDelegate = self
        self.addChild(noAdsButton)
        
    }
    
    //MARK:- PlayButtonNode Delegate
    func playButtonWasPressed(sender: PlayButtonNode) {
        if view != nil {
            let transition:SKTransition = SKTransition.fade(withDuration: 0.5)
            let gameScene = GameScene(size: self.size)
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
        
        if iconType == IconType.SoundOnButton  {
            //print("Sound On")
            gameSoundOn = true
            return
        }
        if iconType == IconType.SoundOffButton  {
            //print("Sound Off")
            gameSoundOn = false
            return
        }
    }
    
}
