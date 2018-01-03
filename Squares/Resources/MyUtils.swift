//
//  MyUtils.swift
//  Squares
//
//  Created by Alan Lou on 12/29/17.
//  Copyright © 2017 Rawwr Studios. All rights reserved.
//

import Foundation

public extension Int {
    /// returns number of digits in Int number
    public var digitCount: Int {
        get {
            return numberOfDigits(in: self)
        }
    }
    // private recursive method for counting digits
    private func numberOfDigits(in number: Int) -> Int {
        if abs(number) < 10 {
            return 1
        } else {
            return 1 + numberOfDigits(in: number/10)
        }
    }
}
