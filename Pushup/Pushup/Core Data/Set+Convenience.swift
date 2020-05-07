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
    convenience init(pushups: Int, time: Int, date: Date = Date(), context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.pushups = Int32(pushups)
        self.time = Int32(time)
        self.date = date
    }
}

extension Day {
    convenience init(pushups: Int, average: Int, sets: Int, date: Date = Date(), count: Int, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.pushups = Int32(pushups)
        self.average = Int32(average)
        self.date = date
        self.sets = Int32(sets)
        self.count = Int32(count)
    }
}
