//
//  GameViewController.swift
//  Squares
//
//  Created by Alan Lou on 12/20/17.
//  Copyright © 2017 Rawwr Studios. All rights reserved.
//

import UIKit
import SpriteKit
import GoogleMobileAds
import GameKit

class GameViewController: UIViewController, GKGameCenterControllerDelegate, GADBannerViewDelegate, GADRewardBasedVideoAdDelegate {
    
    // declare a property to keep a reference to the SKView
    var skView: SKView!

    /// The banner ads view.
    var bannerView: GADBannerView!
    /// Is an ad being loaded.
    var adRequestInProgress: Bool = false
    /// Is an ad ready.
    var isAdReady: Bool = false
    /// The reward-based video ad.
    var rewardBasedVideo: GADRewardBasedVideoAd?
    
    // Variables
    var makeRecallAfterClosing: Bool = false
    
    // Ads Unit ID
    // Banner Ad unit ID (Test): ca-app-pub-3940256099942544/2934735716
    // Banner Ad unit ID (Squares!): ca-app-pub-5422633750847690/7863937958
    let bannerAdsUnitID = "ca-app-pub-3940256099942544/2934735716"
    // Reward Ad unit ID (Test): ca-app-pub-3940256099942544/1712485313
    // Reward Ad unit ID (Squares!): ca-app-pub-5422633750847690/1953135721
    let rewardAdsUnitID = "ca-app-pub-3940256099942544/1712485313"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let noAdsPurchased = UserDefaults.standard.bool(forKey: "noAdsPurchased")
        
        // noAds NOT purchased
        if !noAdsPurchased {
            
            // Set up banner with desired ad size
            // Smart Banner: Screen width x 32|50|90
            bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
            
            if UserDefaults.standard.float(forKey: "AdsHeight") == 0.0 {
                UserDefaults.standard.set(bannerView.frame.height, forKey: "AdsHeight")
            }
            
            bannerView.adUnitID = self.bannerAdsUnitID
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
            bannerView.delegate = self
            
        }
        
        // Add reward ads observer
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(runRewardsAds),
                                               name: Notification.Name(rawValue: "runRewardAds"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(removeBannerAds),
                                               name: Notification.Name(rawValue: "removeBannerAds"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(displayAlertMessage(notification:)),
                                               name: Notification.Name(rawValue: "displayAlertMessage"),
                                               object: nil)
        prepareRewardsAds()
        
        // For Gamecenter
        authenticateLocalPlayer()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        print("viewWillLayoutSubviews")
        
        
        let justOpenApp = UserDefaults.standard.bool(forKey: "justOpenApp")
        
        if justOpenApp {
            
            let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
            // first time launching
            if !launchedBefore  {
                print("WELCOME! FIRST TIME LAUNCHING!")
                /*** initialize Main ***/
                let scene = TutorialScene(size: self.view.bounds.size) // match the device's size
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                if let view = self.view as! SKView? {
                    // present game scene
                    skView = view
                    skView.showsFPS = true
                    skView.showsNodeCount = true
                    skView.ignoresSiblingOrder = true
                    
                    UserDefaults.standard.set(false, forKey: "justOpenApp")
                    UserDefaults.standard.set(false, forKey: "noAdsPurchased")
                    UserDefaults.standard.set(true, forKey: "launchedBefore")
                    UserDefaults.standard.set("Classic", forKey: "skin")
                    
                    scene.isAdReady = self.isAdReady
                    skView.presentScene(scene)
                    
                    // view fade in
                    scene.animateNodesFadeIn()
                    
                    return
                }
            }
            
            
            /*** initialize Main ***/
            let scene = MenuScene(size: self.view.bounds.size) // match the device's size
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            
            if let view = self.view as! SKView? {
                // present game scene
                skView = view
                skView.showsFPS = true
                skView.showsNodeCount = true
                skView.ignoresSiblingOrder = true
                
                UserDefaults.standard.set(false, forKey: "justOpenApp")
                
                scene.isAdReady = self.isAdReady
                skView.presentScene(scene)
                
                // view fade in
                scene.animateNodesFadeIn()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //MARK:- GADBannerViewDelegate
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
        addBannerViewToView(bannerView)
        bannerView.alpha = 0
        UIView.animate(withDuration: 1, animations: {
            bannerView.alpha = 1
        })
    }
    
    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        //print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        //print("adViewWillPresentScreen")
    }
    
    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        //print("adViewWillDismissScreen")
    }
    
    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        //print("adViewDidDismissScreen")
    }
    
    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        //print("adViewWillLeaveApplication")
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        if #available(iOS 11.0, *) {
            // In iOS 11, we need to constrain the view to the safe area.
            positionBannerViewFullWidthAtBottomOfSafeArea(bannerView)
        }
        else {
            // In lower iOS versions, safe area is not available so we use
            // bottom layout guide and view edges.
            positionBannerViewFullWidthAtBottomOfView(bannerView)
        }
    }
    
    // MARK: - view positioning
    @available (iOS 11, *)
    func positionBannerViewFullWidthAtBottomOfSafeArea(_ bannerView: UIView) {
        // Position the banner. Stick it to the bottom of the Safe Area.
        // Make it constrained to the edges of the safe area.
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            guide.leftAnchor.constraint(equalTo: bannerView.leftAnchor),
            guide.rightAnchor.constraint(equalTo: bannerView.rightAnchor),
            guide.topAnchor.constraint(equalTo: bannerView.topAnchor)
            ])
    }
    
    func positionBannerViewFullWidthAtBottomOfView(_ bannerView: UIView) {
        view.addConstraint(NSLayoutConstraint(item: bannerView,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: .leading,
                                              multiplier: 1,
                                              constant: 0))
        view.addConstraint(NSLayoutConstraint(item: bannerView,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: .trailing,
                                              multiplier: 1,
                                              constant: 0))
        if #available(iOS 11.0, *) {
            view.addConstraint(NSLayoutConstraint(item: bannerView,
                                                  attribute: .top,
                                                  relatedBy: .equal,
                                                  toItem: view.safeAreaLayoutGuide.topAnchor,
                                                  attribute: .top,
                                                  multiplier: 1,
                                                  constant: 0))
        } else {
            // Fallback on earlier versions
            view.addConstraint(NSLayoutConstraint(item: bannerView,
                                                  attribute: .top,
                                                  relatedBy: .equal,
                                                  toItem: view,
                                                  attribute: .top,
                                                  multiplier: 1,
                                                  constant: 0))
        }
    }

    
    //MARK:- GADRewardBasedVideoAdDelegate
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didFailToLoadWithError error: Error) {
        adRequestInProgress = false
        //print("Reward based video ad failed to load: \(error.localizedDescription)")
        // load again
        if !adRequestInProgress && rewardBasedVideo?.isReady == false {
            rewardBasedVideo?.load(GADRequest(),
                                   withAdUnitID: self.rewardAdsUnitID)
            adRequestInProgress = true
        }
    }
    
    func rewardBasedVideoAdDidReceive(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        adRequestInProgress = false
        isAdReady = true
        print("Reward based video ad is received.")
        
        // check to see if the current scene is the game scene
        if let gameScene = skView.scene as? GameScene {
            gameScene.recallButtonNode.enableAdsRecall()
        }
        if let menuScene = skView.scene as? MenuScene {
            menuScene.isAdReady = true
        }
        if let tutorialScene = skView.scene as? TutorialScene {
            tutorialScene.isAdReady = true
        }
    }
    
    func rewardBasedVideoAdDidOpen(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Opened reward based video ad.")
    }
    
    func rewardBasedVideoAdDidStartPlaying(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad started playing.")
    }
    
    func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad is closed.")
        
        // check to see if the current scene is the game scene
        if let gameScene = skView.scene as? GameScene, makeRecallAfterClosing {
            gameScene.recallButtonNode.performRecallAction()
        }
        
        makeRecallAfterClosing = false
        isAdReady = false
        prepareRewardsAds()
    }
    
    func rewardBasedVideoAdWillLeaveApplication(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad will leave application.")
    }
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didRewardUserWith reward: GADAdReward) {
        print("Reward received with currency: \(reward.type), amount \(reward.amount).")

        makeRecallAfterClosing = true
    }
    
    //MARK:- Prepare and Run Reward Video Ads
    func prepareRewardsAds() {
        print("PREPARE ADS!")
        rewardBasedVideo = GADRewardBasedVideoAd.sharedInstance()
        rewardBasedVideo?.delegate = self
        
        if !adRequestInProgress && rewardBasedVideo?.isReady == false {
            rewardBasedVideo?.load(GADRequest(),
                                   withAdUnitID: rewardAdsUnitID)
            adRequestInProgress = true
        }
    }
    
    @objc func runRewardsAds() {
        print("RUN ADS!")
        if rewardBasedVideo?.isReady == true {
            rewardBasedVideo?.present(fromRootViewController: self)
        }

    }
    
    @objc func removeBannerAds() {
        print("Remove Banner Ads!")
        if bannerView == nil {
            return
        }
        UserDefaults.standard.set(0.0, forKey: "AdsHeight")
        self.bannerView.removeFromSuperview()
        self.view.setNeedsDisplay()
    }
    
    //MARK:- Alert Message
    @objc func displayAlertMessage(notification:NSNotification) {
        if let userInfo = notification.userInfo {
            let message = userInfo["forButton"] as! String
            print(message)
            
            // Case 1. display alert view for like
            if message == "like" {
                let alertController = UIAlertController(title: "Enjoy Squares?", message: "Please rate the game to support us. Thank you!", preferredStyle: .alert)
                let actionYes = UIAlertAction(title: "Yes, I like it!", style: .default) {
                    UIAlertAction in
                    self.rateApp(appId: "id1348195923") { success in
                        print("RateApp \(success)")
                    }
                }
                let actionNo = UIAlertAction(title: "No, thanks.", style: .default) {
                    UIAlertAction in
                }

                alertController.addAction(actionYes)
                alertController.addAction(actionNo)
                
                self.present(alertController, animated: true, completion: nil)
            }
            
            // Case 2. display alert view for tutorial
            if message == "tutorial" {
                let alertController = UIAlertController(title: "How to play", message: "Do you want to follow the tutorial?", preferredStyle: .alert)
                let actionYes = UIAlertAction(title: "Yes", style: .default) {
                    UIAlertAction in
                    if let view = self.view as! SKView? {
                        let scene = TutorialScene(size: self.view.bounds.size)
                        scene.isAdReady = self.isAdReady
                        let transition:SKTransition = SKTransition.fade(withDuration: 0.5)
                        view.presentScene(scene, transition: transition)
                    }
                }
                let actionNo = UIAlertAction(title: "Cancel", style: .cancel) {
                    UIAlertAction in
                    NSLog("OK Pressed")
                }
                
                alertController.addAction(actionYes)
                alertController.addAction(actionNo)
                
                self.present(alertController, animated: true, completion: nil)
            }
            
            // Case 3. display alert view for leaderboard
            if message == "leaderboard" {
                 showLeaderboard()
            }
            
        }
    }
    
    //MARK:- Helper Function
    func rateApp(appId: String, completion: @escaping ((_ success: Bool)->())) {
        guard let url = URL(string : "itms-apps://itunes.apple.com/app/" + appId) else {
            completion(false)
            return
        }
        guard #available(iOS 10, *) else {
            completion(UIApplication.shared.openURL(url))
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: completion)
    }
    
    func authenticateLocalPlayer() {
        let localPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler = {(viewController, error) -> Void in
            
            if (viewController != nil) {
                self.present(viewController!, animated: true, completion: nil)
            }
            else {
                print((GKLocalPlayer.localPlayer().isAuthenticated))
            }
        }
    }
    
    func showLeaderboard() {
        print("show leaderboard")
        let gKGCViewController = GKGameCenterViewController()
        gKGCViewController.gameCenterDelegate = self as GKGameCenterControllerDelegate
        self.present(gKGCViewController, animated: true, completion: nil)
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
}



