//
//  IAPProducts.swift
//  Squares
//
//  Created by Alan Lou on 6/28/18.
//  Copyright © 2018 Rawwr Studios. All rights reserved.
//

import Foundation

public struct IAPProducts {
    
    public static let NoAds = "com.RawwrStudios.Squares.NoAds"
    
    fileprivate static let productIdentifiers: Set<ProductIdentifier> = [IAPProducts.NoAds]
    
    public static let store = IAPHelper(productIds: IAPProducts.productIdentifiers)
}

func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
    return productIdentifier.components(separatedBy: ".").last
}
