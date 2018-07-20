//
//  MenuScene.swift
//  Squares
//
//  Created by Alan Lou on 1/15/18.
//  Copyright © 2018 Rawwr Studios. All rights reserved.
//


import SpriteKit
import GameKit
import StoreKit

class MenuScene: SKScene, MenuButtonDelegate, PlayButtonDelegate, DismissButtonDelegate, SkinItemNodeDelegate {
    
    // pre-defined numbers
    let skinItemOffset:CGFloat = 7.5
    
    // set up nodes container
    let nodeLayer = SKNode()
    var isAdReady = false
    var isButtonEnabled = true
    var safeAreaRect: CGRect!
    
    // more icon node
    var moreIconsButton: MoreIconsNode?
    
    // nodes
    var bestScoreBarNode: BestScoreBarNode?
    var trophy: TrophyNode?
    var orangeBackgroundBox: SKSpriteNode?

    // IAP Product
    var products = [SKProduct]()
    
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
    var adsHeight: CGFloat {
        get {
            return CGFloat(UserDefaults.standard.float(forKey: "AdsHeight"))
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
        self.backgroundColor = ColorCategory.getBackgroundColor()
        self.view?.isMultipleTouchEnabled = false
        
        var safeSets:UIEdgeInsets
        if #available(iOS 11.0, *) {
            safeSets = view.safeAreaInsets
        } else {
            safeSets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        }
        safeAreaRect = CGRect(x: safeSets.left,
                              y: safeSets.bottom,
                              width: size.width-safeSets.right-safeSets.left,
                              height: size.height-safeSets.top-safeSets.bottom-adsHeight)
        
        nodeLayer.position = CGPoint(x: 0.0, y: safeSets.bottom)
        self.addChild(nodeLayer)
        
        
        // add play button
        let playButtonWidth = min(safeAreaRect.width/3,safeAreaRect.height/5)
        let playButton = PlayButtonNode(color: ColorCategory.getBlockColorAtIndex(index: 1),
                                        width: playButtonWidth,
                                        type: PlayButtonType.PlayButton)
        playButton.position = CGPoint(x: safeAreaRect.width/2,
                                      y: safeAreaRect.height/2-playButton.size.height/2)
        playButton.buttonDelegate = self
        nodeLayer.addChild(playButton)
        
        // add orangeBackgroundBox
        let skinNodeHeight:CGFloat = (safeAreaRect.height-skinItemOffset*5.0)*0.25
        orangeBackgroundBox = SKSpriteNode(texture: nil,
                                          color: ColorCategory.BlockColor9_Colorblind.withAlphaComponent(0.8),
                                          size: CGSize(width:safeAreaRect.width, height:skinNodeHeight+skinItemOffset*2))
        orangeBackgroundBox!.name = "orangeBackgroundBox"
        orangeBackgroundBox!.zPosition = 0
        orangeBackgroundBox!.anchorPoint = CGPoint(x:0.0, y:0.0)
        
        // add pin icon on top of orangeBackgroundBox
        let dismissButtionWidth = skinNodeHeight*0.25
        let pinIconNode = PinIconNode(color: ColorCategory.BlockColor9_Colorblind.withAlphaComponent(0.8),
                                      width: dismissButtionWidth*0.8)
        pinIconNode.zPosition = 20000
        pinIconNode.anchorPoint = CGPoint(x:1.0, y:1.0)
        pinIconNode.position = CGPoint(x:orangeBackgroundBox!.size.width-skinItemOffset-dismissButtionWidth*0.1,
                                                y:orangeBackgroundBox!.size.height-skinItemOffset-dismissButtionWidth*0.1)
        orangeBackgroundBox!.addChild(pinIconNode)
        
        
        /*** add buttons ***/
        let buttonWidth = playButtonWidth/2.5
        let positionArmRadius = min(safeAreaRect.width/(2.0*cos(CGFloat.pi/6.0)) * 0.8 - buttonWidth*0.5, playButtonWidth*1.3)
        let buttonColor =  ColorCategory.getBlockColorAtIndex(index: 7)
        
        // 1. Add Sound button
        var iconTypeHere = IconType.SoundOnButton
        if let gameSoundOn = gameSoundOn {
            iconTypeHere = gameSoundOn ? IconType.SoundOnButton : IconType.SoundOffButton
        }
        let soundButton = MenuButtonNode(color: buttonColor,
                                         buttonType: ButtonType.RoundButton,
                                         iconType: iconTypeHere,
                                         width: buttonWidth)
        soundButton.position = CGPoint(x: safeAreaRect.width/2-positionArmRadius*sin(CGFloat.pi*1/3),
                                       y: playButton.position.y-positionArmRadius*cos(CGFloat.pi*1/3))
        soundButton.buttonDelegate = self
        nodeLayer.addChild(soundButton)
        
        // 2. Add LeaderBoard button
        let leaderBoardButton = MenuButtonNode(color: buttonColor,
                                               buttonType: ButtonType.RoundButton,
                                               iconType: IconType.LeaderBoardButton,
                                               width: buttonWidth)
        leaderBoardButton.position = CGPoint(x: safeAreaRect.width/2-positionArmRadius*sin(CGFloat.pi/6.0),
                                             y: playButton.position.y-positionArmRadius*cos(CGFloat.pi/6.0))
        leaderBoardButton.buttonDelegate = self
        nodeLayer.addChild(leaderBoardButton)
        
        // 3. Add Twitter button
        let twitterButton = MenuButtonNode(color: buttonColor,
                                         buttonType: ButtonType.RoundButton,
                                         iconType: IconType.TwitterButton,
                                         width: buttonWidth)
        twitterButton.position = CGPoint(x: safeAreaRect.width/2,
                                       y: playButton.position.y-positionArmRadius)
        twitterButton.buttonDelegate = self
        nodeLayer.addChild(twitterButton)
        
        
        // 4. Add facebook button
        let facebookButton = MenuButtonNode(color: buttonColor,
                                           buttonType: ButtonType.RoundButton,
                                           iconType: IconType.FacebookButton,
                                           width: buttonWidth)
        facebookButton.position = CGPoint(x: safeAreaRect.width/2+positionArmRadius*sin(CGFloat.pi/6.0),
                                         y: playButton.position.y-positionArmRadius*cos(CGFloat.pi/6.0))
        facebookButton.buttonDelegate = self
        nodeLayer.addChild(facebookButton)
        
        // 5. Add moreIcons button
        moreIconsButton = MoreIconsNode(color: buttonColor,
                                            width: buttonWidth)
        moreIconsButton!.position = CGPoint(x: safeAreaRect.width/2+positionArmRadius*sin(CGFloat.pi*1/3),
                                           y: playButton.position.y-positionArmRadius*cos(CGFloat.pi*1/3))
        moreIconsButton!.moreIconsButton.buttonDelegate = self
        moreIconsButton!.skinButton.buttonDelegate = self
        moreIconsButton!.noAdsButton.buttonDelegate = self
        moreIconsButton!.restoreIAPButton.buttonDelegate = self
        moreIconsButton!.likeButton.buttonDelegate = self
        moreIconsButton!.tutorialButton.buttonDelegate = self
        
        nodeLayer.addChild(moreIconsButton!)
        
        
        /*** add title - letters ***/
        let letterWidth = min(safeAreaRect.width/15.0,safeAreaRect.height/22.5)
        let letterSpacing = letterWidth/3.0
        let sideSpacing = (safeAreaRect.width - letterWidth*8.0 - letterSpacing*7.0)*0.48
        var currX = sideSpacing
        // 1. letter S - Square Dash
        let letterS = TitleLetterNode(letter: TitleLetterType.LetterS,
                                      color: ColorCategory.getBlockColorAtIndex(index: 1),
                                      width: letterWidth)
        letterS.anchorPoint = CGPoint(x:0.0, y:0.0)
        let letterHeight = letterS.size.height
        // calculate y level
        let letterYLevel = safeAreaRect.height - twitterButton.frame.minY*0.8 - letterHeight
        
        letterS.position = CGPoint(x: currX, y: letterYLevel)
        nodeLayer.addChild(letterS)
        currX = currX+letterS.size.width+letterSpacing
        // 2. letter Q - Square Dash
        let letterQ = TitleLetterNode(letter: TitleLetterType.LetterQ,
                                      color: ColorCategory.getBlockColorAtIndex(index: 2),
                                      width: letterWidth)
        letterQ.anchorPoint = CGPoint(x:0.0, y:0.0)
        letterQ.position = CGPoint(x: currX, y: letterYLevel-letterQ.size.height+letterHeight)
        nodeLayer.addChild(letterQ)
        currX = currX+letterQ.size.width+letterSpacing
        // 3. letter U - Square Dash
        let letterU = TitleLetterNode(letter: TitleLetterType.LetterU,
                                      color: ColorCategory.getBlockColorAtIndex(index: 3),
                                      width: letterWidth)
        letterU.anchorPoint = CGPoint(x:0.0, y:0.0)
        letterU.position = CGPoint(x: currX, y: letterYLevel)
        nodeLayer.addChild(letterU)
        currX = currX+letterU.size.width+letterSpacing
        // 4. letter A - Square Dash
        let letterA = TitleLetterNode(letter: TitleLetterType.LetterA,
                                      color: ColorCategory.getBlockColorAtIndex(index: 4),
                                      height: letterHeight)
        letterA.anchorPoint = CGPoint(x:0.0, y:0.0)
        letterA.position = CGPoint(x: currX, y: letterYLevel)
        nodeLayer.addChild(letterA)
        currX = currX+letterA.size.width+letterSpacing
        // 5. letter R - Square Dash
        let letterR = TitleLetterNode(letter: TitleLetterType.LetterR,
                                      color: ColorCategory.getBlockColorAtIndex(index: 5),
                                      height: letterHeight)
        letterR.anchorPoint = CGPoint(x:0.0, y:0.0)
        letterR.position = CGPoint(x: currX, y: letterYLevel)
        nodeLayer.addChild(letterR)
        currX = currX+letterR.size.width+letterSpacing
        // 6. letter E - Square Dash
        let letterE = TitleLetterNode(letter: TitleLetterType.LetterE,
                                      color: ColorCategory.getBlockColorAtIndex(index: 6),
                                      width: letterWidth)
        letterE.anchorPoint = CGPoint(x:0.0, y:0.0)
        letterE.position = CGPoint(x: currX, y: letterYLevel)
        nodeLayer.addChild(letterE)
        currX = currX-letterR.size.width-letterSpacing // backward by one letter
        // 7. letter D - Square Dash
        let letterD = TitleLetterNode(letter: TitleLetterType.LetterD,
                                      color: ColorCategory.getBlockColorAtIndex(index: 7),
                                      width: letterWidth)
        letterD.anchorPoint = CGPoint(x:0.0, y:1.0)
        letterD.position = CGPoint(x: currX, y: letterYLevel-safeAreaRect.height*0.02)
        nodeLayer.addChild(letterD)
        currX = currX+letterD.size.width+letterSpacing
        // 8. letter A - Square Dash
        let letterA2 = TitleLetterNode(letter: TitleLetterType.LetterA,
                                       color: ColorCategory.getBlockColorAtIndex(index: 8),
                                       height: letterHeight)
        letterA2.anchorPoint = CGPoint(x:0.0, y:1.0)
        letterA2.position = CGPoint(x: currX, y: letterYLevel-safeAreaRect.height*0.02)
        nodeLayer.addChild(letterA2)
        currX = currX+letterA2.size.width+letterSpacing
        // 9. letter S - Square Dash
        let letterS2 = TitleLetterNode(letter: TitleLetterType.LetterS,
                                       color: ColorCategory.getBlockColorAtIndex(index: 9),
                                       width: letterWidth)
        letterS2.anchorPoint = CGPoint(x:0.0, y:1.0)
        letterS2.position = CGPoint(x: currX, y: letterYLevel-safeAreaRect.height*0.02)
        nodeLayer.addChild(letterS2)
        currX = currX+letterS2.size.width+letterSpacing
        // 10. letter H - Square Dash
        let letterH = TitleLetterNode(letter: TitleLetterType.LetterH,
                                      color: ColorCategory.getBlockColorAtIndex(index: 1),
                                      width: letterWidth)
        letterH.anchorPoint = CGPoint(x:0.0, y:1.0)
        letterH.position = CGPoint(x: currX, y: letterYLevel-safeAreaRect.height*0.02)
        nodeLayer.addChild(letterH)
        
        letterS.name = "TitleLetter1"
        letterQ.name = "TitleLetter2"
        letterU.name = "TitleLetter3"
        letterA.name = "TitleLetter4"
        letterR.name = "TitleLetter5"
        letterE.name = "TitleLetter6"
        letterD.name = "TitleLetter7"
        letterA2.name = "TitleLetter8"
        letterS2.name = "TitleLetter9"
        letterH.name = "TitleLetter10"
        
        /*** add best score boarder ***/
        bestScoreBarNode = BestScoreBarNode(color: ColorCategory.getBestScoreFontColor().withAlphaComponent(0.55), width: min(size.width/1.7,size.height/2.55))
        bestScoreBarNode!.position = CGPoint(x: safeAreaRect.width/2.0,
                                             y: (letterD.frame.minY + playButton.frame.maxY)/2.0)
        nodeLayer.addChild(bestScoreBarNode!)
        
        let bestScoreBarNodeWidth = bestScoreBarNode!.size.width
        let bestScoreBarNodeHeight = bestScoreBarNode!.size.height
        
        // add trophy
        trophy = TrophyNode(color: ColorCategory.getBlockColorAtIndex(index: 3), height: bestScoreBarNodeHeight*0.63)
        trophy!.anchorPoint = CGPoint(x:0.0, y:0.5)
        trophy!.position = CGPoint(x: -bestScoreBarNode!.size.width/2.0+bestScoreBarNodeHeight*0.16,
                                   y: 0.0)
        bestScoreBarNode!.addChild(trophy!)
        
        // add best score label
        let bestScoreNodeWidth = bestScoreBarNodeWidth/3.0
        let bestScoreNodeHeight = bestScoreBarNodeHeight/3.0
        let bestScoreLabelNodeFrame = CGRect(x: bestScoreBarNodeHeight*0.16-bestScoreNodeWidth/2, y: bestScoreBarNodeHeight/18.0, width: bestScoreNodeWidth, height: bestScoreNodeHeight)
        let bestScoreLabelNode = MessageNode(message: "BEST")
        bestScoreLabelNode.adjustLabelFontSizeToFitRect(rect: bestScoreLabelNodeFrame)
        bestScoreBarNode!.addChild(bestScoreLabelNode)
        
        // add best score
        let bestScoreNodeFrame = CGRect(x: bestScoreBarNodeHeight*0.16-bestScoreNodeWidth/2, y: -bestScoreBarNodeHeight/18.0-bestScoreNodeHeight, width: bestScoreNodeWidth, height: bestScoreNodeHeight)
        let bestScoreNode = MessageNode(message: "\(bestScore)")
        bestScoreNode.adjustLabelFontSizeToFitRect(rect: bestScoreNodeFrame)
        bestScoreBarNode!.addChild(bestScoreNode)
        
        bestScoreLabelNode.name = "bestScoreLabelNode"
        bestScoreNode.name = "bestScoreNode"
        
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
    
    //MARK:- DismissButtonNode Delegate
    func dismissButtonWasPressed(sender: DismissButtonNode) {
        // play sound
        if let gameSoundOn = gameSoundOn,
            gameSoundOn {
            self.run(buttonPressedSound)
        }
        
        let skinSelectionBackgroundNode = nodeLayer.childNode(withName: "skinSelectionBackgroundNode")
        
        if let skinSelectionBackgroundNode = skinSelectionBackgroundNode {
            // animate
            let moveUp = SKAction.move(to: CGPoint(x: 0.0, y: safeAreaRect.height*1.1-adsHeight), duration: 0.15)
            let moveDown = SKAction.move(to: CGPoint(x: 0.0, y: 0.0), duration: 0.32)
            moveDown.timingMode = .easeIn
            skinSelectionBackgroundNode.run(SKAction.sequence([moveUp,moveDown]), completion: { [weak self] in
                skinSelectionBackgroundNode.removeFromParent()
                self?.isButtonEnabled = true
                self?.orangeBackgroundBox?.removeFromParent()
            })
        }
        
        return
    }
    
    //MARK:- SkinItemNodeWasReleased
    func skinItemNodeWasReleased(sender: SkinItemNode, skinItem: String) {
        // play sound
        if let gameSoundOn = gameSoundOn,
            gameSoundOn {
            self.run(buttonPressedSound)
        }
        
        // select skin
        UserDefaults.standard.set(skinItem, forKey: "skin")
        
        // update color
        // 1. background
        self.backgroundColor = ColorCategory.getBackgroundColor()
        // 2. Title
        for i in 1..<11 {
            if let letter = nodeLayer.childNode(withName: "TitleLetter\(i)") as? TitleLetterNode {
                if i == 10 {
                    letter.changeColor(to: ColorCategory.getBlockColorAtIndex(index: UInt32(1)))
                } else {
                    letter.changeColor(to: ColorCategory.getBlockColorAtIndex(index: UInt32(i)))
                }
            }
        }
        // 3. Best ScoreNode
        if let bestScoreLabelNode = bestScoreBarNode?.childNode(withName: "bestScoreLabelNode") as? MessageNode {
            bestScoreLabelNode.setFontColor(color: ColorCategory.getBestScoreFontColor())
        }
        if let bestScoreNode = bestScoreBarNode?.childNode(withName: "bestScoreNode") as? MessageNode {
            bestScoreNode.setFontColor(color: ColorCategory.getBestScoreFontColor())
        }
        bestScoreBarNode?.changeColor(to: ColorCategory.getBestScoreFontColor().withAlphaComponent(0.55))
        // 4. Trophy
        trophy?.color = ColorCategory.getBlockColorAtIndex(index: 3)
        // 5. Menu buttons
        nodeLayer.enumerateChildNodes(withName: "menubutton") {
            node, stop in
            let menuButton = node as! MenuButtonNode
            menuButton.updateColor()
            menuButton.changeColor(to: ColorCategory.getBlockColorAtIndex(index: 7))
        }
        moreIconsButton?.enumerateChildNodes(withName: "menubutton") {
            node, stop in
            let menubutton = node as! MenuButtonNode
            menubutton.updateColor()
            menubutton.changeColor(to: ColorCategory.getBlockColorAtIndex(index: 7))
        }
        
        // 6. Play button
        if let playbutton = nodeLayer.childNode(withName: "playbutton") as? PlayButtonNode {
            playbutton.changeColor(to: ColorCategory.getBlockColorAtIndex(index: 1))
        }
        
        // Update Selection Frame
        updateSkinItemFrame(skinItem: skinItem)
    }
    
    //MARK:- MenuButtonNode Delegate
    func buttonWasPressed(sender: MenuButtonNode) {
        
        if !isButtonEnabled {
            return
        }
        
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
        } else if iconType == IconType.SoundOffButton  {
            gameSoundOn = false
            return
        } else if iconType == IconType.TwitterButton  {
            let twInstalled = schemeAvailable("twitter://")
            
            if twInstalled {
                // If user twitter installed
                guard let url = URL(string: "twitter://user?screen_name=rawwrstudios") else {
                    return
                }
                
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            } else {
                // If user does not have twitter installed
                guard let url = URL(string: "https://mobile.twitter.com/rawwrstudios") else {
                    return
                }
                
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
            
            return
        } else if iconType == IconType.FacebookButton  {
            let fbInstalled = schemeAvailable("fb://")
            
            if fbInstalled {
                // If user twitter installed
                guard let url = URL(string: "fb://profile/349909612079389") else {
                    return
                }
                
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            } else {
                // If user does not have twitter installed
                guard let url = URL(string: "https://www.facebook.com/RawwrStudios") else {
                    return
                }
                
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
            
            return
        } else if iconType == IconType.MoreIconsButton  {
            if let moreIconsButton = moreIconsButton, let bestScoreBarNode = bestScoreBarNode {
                let duration1 = 0.3
                let duration2 = 0.08
                let movingDistance = moreIconsButton.size.width*0.6
                
                if !moreIconsButton.isOpen {
                    // best score node move to left
                    let moveLeft = SKAction.moveBy(x: -movingDistance-5.0, y: 0.0, duration: duration1)
                    let moveRight = SKAction.moveBy(x: 5.0, y: 0.0, duration: duration2)
                    moveLeft.timingMode = .easeOut
                    bestScoreBarNode.run(SKAction.sequence([moveLeft,moveRight]))
                } else {
                    // best score node move to right
                    let moveRight = SKAction.moveBy(x: movingDistance+5.0, y: 0.0, duration: duration1)
                    let moveLeft = SKAction.moveBy(x: -5.0, y: 0.0, duration: duration2)
                    moveRight.timingMode = .easeOut
                    bestScoreBarNode.run(SKAction.sequence([moveRight,moveLeft]))
                }
                
                moreIconsButton.interact()
                
            }
        } else if iconType == IconType.SkinButton  {
            showSkinSelectionView()
            
        } else if iconType == IconType.NoAdsButton  {
//            print("NoAdsButton")
            
            products = []
            IAPProducts.store.requestProducts{success, products in
                if success {
//                    print("NoAdsButton Success")
                    self.products = products!
                    let firstProduct = self.products[0] as SKProduct
                    IAPProducts.store.buyProduct(firstProduct)
                }
            }
            
        } else if iconType == IconType.RestoreIAPButton  {
            IAPProducts.store.restorePurchases()
//            print("RestoreIAPButton")
            
        } else if iconType == IconType.LikeButton {
            let userInfoDict:[String: String] = ["forButton": "like"]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "displayAlertMessage"), object: nil, userInfo: userInfoDict)
            
        } else if iconType == IconType.InfoButton {
            let userInfoDict:[String: String] = ["forButton": "tutorial"]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "displayAlertMessage"), object: nil, userInfo: userInfoDict)
            
        } else if iconType == IconType.LeaderBoardButton {
            let userInfoDict:[String: String] = ["forButton": "leaderboard"]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "displayAlertMessage"), object: nil, userInfo: userInfoDict)
            
        }
    }
    //MARK:- Helper Functions
    func schemeAvailable(_ scheme: String) -> Bool {
        if let url = URL(string: scheme) {
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }
    
    func animateNodesFadeIn() {
        /*** Animate nodeLayer ***/
        nodeLayer.alpha = 0.0
        nodeLayer.run(SKAction.fadeIn(withDuration: 0.2))
    }
    
    func showSkinSelectionView() {
        isButtonEnabled = false
        
        // calculate numbers first
        let skinNodeHeight:CGFloat = (safeAreaRect.height-skinItemOffset*5.0)*0.25
        let skinItemNode4 = SkinItemNode(width: safeAreaRect.width-skinItemOffset*2.0, height: skinNodeHeight, skin: "Colorblind")
        let skinFontSize:CGFloat = skinItemNode4.getFontSize()
        
        // add gray mask to background
        let skinSelectionBackgroundNode = SKSpriteNode(color: SKColor.gray, size: CGSize(width: safeAreaRect.width, height: (skinNodeHeight+skinItemOffset)*5))
        skinSelectionBackgroundNode.zPosition = 5000
        skinSelectionBackgroundNode.name = "skinSelectionBackgroundNode"
        skinSelectionBackgroundNode.anchorPoint = CGPoint(x:0.0, y:1.0)
        skinSelectionBackgroundNode.position = CGPoint(x:0.0 ,y: 0.0)
        nodeLayer.addChild(skinSelectionBackgroundNode)
        
        // Add skin item nodes
        // upper layer
//        let upperMask = SKSpriteNode(color: SKColor.gray, size: CGSize(width: safeAreaRect.width, height: skinNodeHeight+skinItemOffset))
//        upperMask.zPosition = 5000
//        upperMask.anchorPoint = CGPoint(x:0.0, y:0.0)
//        upperMask.position = CGPoint(x:0.0 ,y: 0.0)
//        skinSelectionBackgroundNode.addChild(upperMask)

        // Skin 1. Classic
        let skinItemNode1 = SkinItemNode(width: safeAreaRect.width-skinItemOffset*2.0, height: skinNodeHeight, skin: "Classic")
        skinItemNode1.zPosition = 15000
        skinItemNode1.position = CGPoint(x: skinItemOffset, y: -skinNodeHeight-skinItemOffset)
        skinItemNode1.setFontSize(fontSize: skinFontSize)
        skinItemNode1.skinItemNodeDelegate = self
        skinSelectionBackgroundNode.addChild(skinItemNode1)
        // Skin 2. Day
        let skinItemNode2 = SkinItemNode(width: safeAreaRect.width-skinItemOffset*2.0, height: skinNodeHeight, skin: "Day")
        skinItemNode2.zPosition = 15000
        skinItemNode2.position = CGPoint(x: skinItemOffset, y: -skinNodeHeight*2-skinItemOffset*2)
        skinItemNode2.setFontSize(fontSize: skinFontSize)
        skinItemNode2.skinItemNodeDelegate = self
        skinSelectionBackgroundNode.addChild(skinItemNode2)
        // Skin 3. Night
        let skinItemNode3 = SkinItemNode(width: safeAreaRect.width-skinItemOffset*2.0, height: skinNodeHeight, skin: "Night")
        skinItemNode3.zPosition = 15000
        skinItemNode3.position = CGPoint(x: skinItemOffset, y: -skinNodeHeight*3-skinItemOffset*3)
        skinItemNode3.setFontSize(fontSize: skinFontSize)
        skinItemNode3.skinItemNodeDelegate = self
        skinSelectionBackgroundNode.addChild(skinItemNode3)
        // Skin 4. Day
        skinItemNode4.zPosition = 15000
        skinItemNode4.position = CGPoint(x: skinItemOffset, y: -skinNodeHeight*4-skinItemOffset*4)
        skinItemNode4.skinItemNodeDelegate = self
        skinSelectionBackgroundNode.addChild(skinItemNode4)
        
        // add orangeBackgroundBox
        if let orangeBackgroundBox = orangeBackgroundBox {
            skinSelectionBackgroundNode.addChild(orangeBackgroundBox)
            let selectedSkin = UserDefaults.standard.object(forKey: "skin") as! String
            updateSkinItemFrame(skinItem: selectedSkin)
        }
        
        // add dismiss button
        let dismissButton = DismissButtonNode(color: ColorCategory.BlockColor1_Day.withAlphaComponent(0.8), width: skinItemNode1.size.height*0.25)
        dismissButton.position = CGPoint(x:safeAreaRect.width-skinItemOffset*1.5 ,y: -safeAreaRect.height+skinItemOffset*1.5)
        dismissButton.zPosition = 20000
        dismissButton.buttonDelegate = self
        skinSelectionBackgroundNode.addChild(dismissButton)
        
        // animate
        let moveUp = SKAction.move(to: CGPoint(x: 0.0, y: safeAreaRect.height*1.1), duration: 0.32)
        let moveDown = SKAction.move(to: CGPoint(x: 0.0, y: safeAreaRect.height*0.97), duration: 0.15)
        let moveUpSmall = SKAction.move(to: CGPoint(x: 0.0, y: safeAreaRect.height), duration: 0.07)
        moveUp.timingMode = .easeOut
        skinSelectionBackgroundNode.run(SKAction.sequence([moveUp,moveDown,moveUpSmall]))
    }
    
    func updateSkinItemFrame(skinItem: String) {
        // calculate size
        let skinNodeHeight:CGFloat = (safeAreaRect.height-skinItemOffset*5.0)*0.25
        
        if let orangeBackgroundBox = orangeBackgroundBox {
            if skinItem == "Classic" {
                orangeBackgroundBox.position = CGPoint(x: 0.0, y: -skinNodeHeight-skinItemOffset*2)
            } else if skinItem == "Day" {
                orangeBackgroundBox.position = CGPoint(x: 0.0, y: -skinNodeHeight*2-skinItemOffset*3)
            } else if skinItem == "Night" {
                orangeBackgroundBox.position = CGPoint(x: 0.0, y: -skinNodeHeight*3-skinItemOffset*4)
            } else if skinItem == "Colorblind" {
                orangeBackgroundBox.position = CGPoint(x: 0.0, y: -skinNodeHeight*4-skinItemOffset*5)
            }
        }
    }
}
