//
//  PushupController.swift
//  Pushup
//
//  Created by Dennis Rudolph on 4/19/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

protocol PushupControllerDelegate {
    func updatePushupLabel(pushups: Int)
}

class PushupController {
    
    var delegate: PushupControllerDelegate?
    var pushupCount = 0 {
        didSet {
            delegate?.updatePushupLabel(pushups: pushupCount)
        }
    }
    
    func createSetOfPushups(time: Int) {
        let _ = SetOfPushups(pushups: pushupCount, time: time)
        do {
            try CoreDataStack.shared.save(context: CoreDataStack.shared.mainContext)
        } catch {
            print("Error saving to core data")
        }
    }
}
