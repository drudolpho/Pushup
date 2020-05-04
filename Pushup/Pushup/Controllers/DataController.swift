//
//  DataController.swift
//  Pushup
//
//  Created by Dennis Rudolph on 5/4/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    var dateAsString = "MM/dd/yyyy"
    
    init() {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        dateAsString = formatter.string(from: date)
    }
    
    
}
