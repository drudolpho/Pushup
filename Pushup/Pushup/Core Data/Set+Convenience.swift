//
//  Set+Convenience.swift
//  Pushup
//
//  Created by Dennis Rudolph on 4/18/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension SetOfPushups {
    convenience init(pushups: Int, time: Int, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.pushups = Int32(pushups)
        self.time = Int32(time)
        self.date = Date()
    }
}
