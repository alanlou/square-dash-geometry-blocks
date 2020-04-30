//
//  Array2D.swift
//  Squares
//
//  Created by Alan Lou on 12/22/17.
//  Copyright © 2017 Rawwr Studios. All rights reserved.
//

struct SetArray2D<T>: Codable {
    let columns: Int
    let rows: Int
    fileprivate var array: Array<Set<UInt32>?>
    
    init(columns: Int, rows: Int) {
        self.columns = columns
        self.rows = rows
        array = Array<Set<UInt32>?>(repeating: nil, count: rows*columns)
    }
    
    subscript(column: Int, row: Int) -> Set<UInt32>? {
        get {
            // safe column
            if column < 0 {
                return nil
            } else if column >= columns {
                return nil
            }
            // safe row
            if row < 0 {
                return nil
            } else if row >= rows {
                return nil
            }
            
            return array[row*columns + column]
        }
        set {
            // safe column
            if column < 0 {
                return
            } else if column >= columns {
                return
            }
            // safe row
            if row < 0 {
                return
            } else if row >= rows {
                return
            }
            
            array[row*columns + column] = newValue
        }
    }
}
