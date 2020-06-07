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
    let defaults = UserDefaults.standard
    
    let date = Date()
//    var date: Date {
//        var dateComponents = DateComponents()
//        dateComponents.year = 2020
//        dateComponents.month = 6
//        dateComponents.day = 18
//        dateComponents.hour = 8
//        dateComponents.minute = 33
//
//        let userCalendar = Calendar.current // user calendar
//        return userCalendar.date(from: dateComponents)!
//    }
    
    var formatter = DateFormatter()
    var setData: [SetOfPushups] = []
    var dayData: [Day]?
    
    init() {
        formatter.dateFormat = "MM/dd"
        dateAsString = formatter.string(from: date)
    }
    
    func updateTodaysData(set: SetOfPushups) {
        guard let today = dayData?.last else { return }
        
        today.pushups += set.pushups
        
        let totalDays = getDaysSince(day1: dayData?.first?.date ?? date, day2: date) + 1
        let totalPushups = getTotalPushups()
        if totalDays == 0 {
            today.average += set.pushups
        } else {
            let avg = totalPushups / totalDays
            today.average = Int32(avg)
        }
        today.sets += 1
        
        //updates streak
        if today.sets == 1 {
            if let lastDay = dayData?.penultimate() {
                if lastDay.sets > 0 {
                    let streak = defaults.integer(forKey: "streak")
                    defaults.set(streak + 1, forKey: "streak")
                } else if lastDay.sets == 0 {
                    defaults.set(1, forKey: "streak")
                }
            } else {
                let streak = defaults.integer(forKey: "streak")
                defaults.set(streak + 1, forKey: "streak")
            }
        }
    }
    
    func createDays() { //Creates days for each day missed, for graphing daily average. Or just creates current day.
        guard let lastDay = dayData?.last else {
            let day = Day(pushups: 0, average: 0, sets: 0, date: date, count: 1)
            self.dayData?.append(day)
            defaults.set(0, forKey: "streak")
            return
        }
        let daysSinceLast = getDaysSince(day1: lastDay.date ?? date, day2: date)
        let dayCount = Int(lastDay.count)
        let totalPushups = getTotalPushups()
        
        if daysSinceLast == 1{
            
            let newCount = dayCount + 1
            let avg = totalPushups / (newCount)
            let day = Day(pushups: 0, average: avg, sets: 0, date: date, count: newCount)
            self.dayData?.append(day)
            
        } else if daysSinceLast > 1 {
            
            defaults.set(0, forKey: "streak")
        
            for i in 1...daysSinceLast {
                
                let newCount = dayCount + i
                let modifiedDate = Calendar.current.date(byAdding: .day, value: i, to: lastDay.date ?? date) ?? date
                let avg = totalPushups / (newCount)
                let day = Day(pushups: 0, average: avg, sets: 0, date: modifiedDate, count: newCount)
                self.dayData?.append(day)
            }
        }
        
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
    
    func getStreak() -> Int {
        let streak = defaults.integer(forKey: "streak")
        return streak
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
    
    func getHighestDayAvg() -> Int {
        guard let dayData = dayData else { return 0}
        var high = 0
        for day in dayData {
            if day.average > high {
                high = Int(day.average)
            }
        }
        return high
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
            createDays()
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
        } catch {
            print("Error deleting Data")
            completion(false)
        }
        completion(true)
    }
}

extension Array {
  func penultimate() -> Element? {
      if self.count < 2 {
          return nil
      }
      let index = self.count - 2
      return self[index]
  }
}
