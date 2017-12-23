//
//  Level.swift
//  Squares
//
//  Created by Alan Lou on 12/22/17.
//  Copyright © 2017 Rawwr Studios. All rights reserved.
//

import Foundation

let NumColumns = 9
let NumRows = 9

class Level {
    fileprivate var blockCells = Array2D<BlockCell>(columns: NumColumns, rows: NumRows)
    
    func blockAt(column: Int, row: Int) -> BlockCell? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return blockCells[column, row]
    }

    func shuffle() -> Set<BlockCell> {
        return createInitialBlockCells()
    }
    
    private func createInitialBlockCells() -> Set<BlockCell> {
        var set = Set<BlockCell>()
        
        for row in 0..<NumRows {
            for column in 0 ..< NumColumns {
                let blockCellType = BlockCellType.random()
                let blockCell = BlockCell(column: column, row: row, blockCellType: blockCellType)
                blockCells[column, row] = blockCell
                set.insert(blockCell)
            }
        }
        return set
    }
}

