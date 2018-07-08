//
//  StoreReviewHelper.swift
//  Squares
//
//  Created by Alan Lou on 1/31/18.
//  Copyright © 2018 Rawwr Studios. All rights reserved.
//

import Foundation
import StoreKit

struct StoreReviewHelper {
    
    static func incrementAppHighScoreCount() { // called from appdelegate didfinishLaunchingWithOptions:
        let Defaults = UserDefaults()
        guard var appOpenCount = Defaults.value(forKey: "Update_High_Score_Count") as? Int else {
            Defaults.set(1, forKey: "Update_High_Score_Count")
            return
        }
        appOpenCount += 1
        Defaults.set(appOpenCount, forKey: "Update_High_Score_Count")
    }
    
    static func checkAndAskForReview() { // call this whenever appropriate
        // this will not be shown everytime. Apple has some internal logic on how to show this.
        let Defaults = UserDefaults()
        guard let appOpenCount = Defaults.value(forKey: "Update_High_Score_Count") as? Int else {
            Defaults.set(1, forKey: "Update_High_Score_Count")
            return
        }
        
        switch appOpenCount {
        case 10,25:
            StoreReviewHelper().requestReview()
        case _ where appOpenCount%50 == 0 :
            StoreReviewHelper().requestReview()
        default:
            print("Total game count is : \(appOpenCount)")
            break;
        }
        
    }
    
    fileprivate func requestReview() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        } else {
            // Fallback on earlier versions
            // Try any other 3rd party or manual method here.
        }
    }
}
