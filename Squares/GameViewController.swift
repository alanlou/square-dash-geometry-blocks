//
//  GameViewController.swift
//  Squares
//
//  Created by Alan Lou on 12/20/17.
//  Copyright © 2017 Rawwr Studios. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpFirstLaunch()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        /*** initialize Main ***/
        let scene = MenuScene(size: self.view.bounds.size) // match the device's size
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        
        // present game scene
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        //skView.showsPhysics = true
        skView.ignoresSiblingOrder = true
        
        let transition:SKTransition = SKTransition.fade(withDuration: 0.5)
        skView.presentScene(scene, transition: transition)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func setUpFirstLaunch() {
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore  {
            //return
        }
        UserDefaults.standard.set(true, forKey: "launchedBefore")
    }
}

