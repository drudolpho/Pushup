//
//  TestController.swift
//  Pushup
//
//  Created by Dennis Rudolph on 4/18/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class TestController {
    
    var data: [Int: [Double]] = [:]
    var rawValues: [Double] = []
    var counter = 0
    
    func addSet() {
        data[counter] = rawValues
        counter += 1
        rawValues = []
    }
    
    func printDataForSet(setNum: Int) {
        guard let lightData = data[setNum] else { return }
        for input in lightData {
            print(input)
        }
    }
}
