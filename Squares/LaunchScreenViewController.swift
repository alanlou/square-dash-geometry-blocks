//
//  LaunchScreenViewController.swift
//  Squares
//
//  Created by Alan Lou on 1/21/18.
//  Copyright © 2018 Rawwr Studios. All rights reserved.
//

import UIKit

class LaunchScreenViewController: UIViewController {
    
    @IBOutlet weak var logoView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set background
        self.view.backgroundColor = ColorCategory.getBackgroundColor()
        
        logoView.isHidden = false
        logoView.alpha = 1.0
        // Then fades it away after 1 seconds (the cross-fade animation will take 0.5s)
        UIView.animate(withDuration: 0.15, delay: 0.7, options: [], animations: {
            self.logoView.alpha = 0.0
        }) { (finished: Bool) in
            self.logoView.isHidden = true
            self.showNavController()
        }
        
        setUpOpenApp()
        
    }
    
    func showNavController() {
        performSegue(withIdentifier: "showGameViewController", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //MARK:- Helper functions
    
    
    //MARK:- Helper Functions
    func setUpOpenApp() {
        UserDefaults.standard.set(true, forKey: "justOpenApp")
    }
}
