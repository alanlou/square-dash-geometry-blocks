//
//  MyUtils.swift
//  Squares
//
//  Created by Alan Lou on 12/29/17.
//  Copyright © 2017 Rawwr Studios. All rights reserved.
//

import Foundation

extension Collection {
    
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
