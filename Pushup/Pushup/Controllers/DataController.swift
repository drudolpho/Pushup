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
    let date = Date()
    let formatter = DateFormatter()
    var dayIsSet = false
    var setData: [SetOfPushups] = []
    var dayData: [Day]? {
        didSet {
            createDays()
        }
    }
    
    func updateTodaysData(set: SetOfPushups) {
        guard let today = dayData?.last else { return }
        today.pushups += set.pushups
        
        let totalDays = getDaysSince(day1: dayData?.first?.date ?? date, day2: date)
        let totalPushups = getTotalPushups()
        if totalDays == 0 {
            today.average += set.pushups
        } else {
            let avg = totalPushups / totalDays
            today.average = Int32(avg)
        }
        
    }
    
    func createDays() { //Creates days for each day missed, for graphing daily average. Or just creates current day.
        guard let lastDay = dayData?.last, let firstDay = dayData?.first else { return }
        let daysSinceLast = getDaysSince(day1: lastDay.date ?? date, day2: date)
        let totalDays = getDaysSince(day1: firstDay.date ?? date, day2: lastDay.date ?? date)
        let totalPushups = getTotalPushups()
        
        if daysSinceLast == 1{
            let avg = totalPushups / (totalDays + 1)
            let day = Day(pushups: 0, average: avg, sets: 0)
            self.dayData?.append(day)
        } else if daysSinceLast > 1 {
            for i in 1...daysSinceLast - 1 {
                let avg = totalPushups / (totalDays + i)
                let _ = Day(pushups: 0, average: avg, sets: 0)
            }
            let avg = totalPushups / (totalDays + 1)
            let day = Day(pushups: 0, average: avg, sets: 0)
            self.dayData?.append(day)
        }
        dayIsSet = true
        do {  //Save Core Data
            try CoreDataStack.shared.save(context: CoreDataStack.shared.mainContext)
        } catch {
            print("Error saving to core data")
        }
    }
    
    func getDaysSince(day1: Date, day2: Date) -> Int {
        let calendar = Calendar.current
        // Replace the hour (time) of both dates with 00:00
        let date1 = calendar.startOfDay(for: day1)
        let date2 = calendar.startOfDay(for: day2)

        let components = calendar.dateComponents([.day], from: date1, to: date2)
        return components.day ?? 0
    }
    
    init() {
        formatter.dateFormat = "MM/dd/yyyy"
        dateAsString = formatter.string(from: date)
        fetchSetData()
        fetchDayData()
    }
    
    func getTotalTimeAsString() -> String {
        var sum = 0
        for set in setData {
            sum += Int(set.time)
        }
        
        let minutes = sum / 60
        let seconds = sum % 60
        var secondString = ""
        
        if seconds < 10 {
            secondString = "0\(seconds)"
        } else {
            secondString = "\(seconds)"
        }
        
        return "\(minutes):\(secondString)"
    }
    
    func getTotalPushups() -> Int{
        var sum = 0
        for set in setData {
            sum += Int(set.pushups)
        }
        return sum
    }
    
    func getAvgPushups(totalPushups: Int) -> Int{
        let sets = setData.count
        if sets > 0 {
            let answer = Int(totalPushups / setData.count)
            return answer
        } else {
            return 0
        }
    }
    
    func fetchDayData() {
        let moc = CoreDataStack.shared.mainContext
        let dataFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Day")
        let sort = NSSortDescriptor(key: "date", ascending: true)
        dataFetch.sortDescriptors = [sort]
        
        do {
            let fetchedData = try moc.fetch(dataFetch) as! [Day]
            dayData = fetchedData
        } catch {
            fatalError("Failed to fetch pushup data: \(error)")
        }
    }
    
    func fetchSetData() {
        let moc = CoreDataStack.shared.mainContext
        let dataFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "SetOfPushups")
        let sort = NSSortDescriptor(key: "date", ascending: true)
        dataFetch.sortDescriptors = [sort]
        
        do {
            let fetchedData = try moc.fetch(dataFetch) as! [SetOfPushups]
            setData = fetchedData
        } catch {
            fatalError("Failed to fetch pushup data: \(error)")
        }
    }
    
    func deleteData(completion: (Bool) -> Void)  {
        let fetchRequestData = NSFetchRequest<NSFetchRequestResult>(entityName: "SetOfPushups")
        let batchDeleteRequestData = NSBatchDeleteRequest(fetchRequest: fetchRequestData)
        
        let fetchRequestDay = NSFetchRequest<NSFetchRequestResult>(entityName: "Day")
        let batchDeleteRequestDay = NSBatchDeleteRequest(fetchRequest: fetchRequestDay)

        do {
            try CoreDataStack.shared.mainContext.execute(batchDeleteRequestData)
            try CoreDataStack.shared.mainContext.execute(batchDeleteRequestDay)
            self.fetchDayData()
            self.fetchSetData()
            dayIsSet = false
        } catch {
            print("Error deleting Data")
            completion(false)
        }
        completion(true)
    }
}

    

