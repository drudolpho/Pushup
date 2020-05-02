//
//  DataViewController.swift
//  Pushup
//
//  Created by Dennis Rudolph on 4/18/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import CoreData

class DataViewController: UIViewController {
    
    var setData: [SetOfPushups] = []
    
    @IBOutlet weak var totalPushupsLabel: UILabel!
    @IBOutlet weak var avgPushupsLabel: UILabel!
    @IBOutlet weak var totalSetsLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
        updateViews()
    }
    
    @IBAction func backTapped(sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func updateViews() {
        //Total Pushups
        let totalPushups = getTotalPushups()
        totalPushupsLabel.text = "\(totalPushups)"
        //Average Pushups per set
        let avgPushups = getAvgPushups(totalPushups: totalPushups)
        avgPushupsLabel.text = "\(avgPushups)"
        //Total Sets
        let totalSets = setData.count
        totalSetsLabel.text = "\(totalSets)"
        //Total time
        totalTimeLabel.text = getTotalTimeAsString()
        
    }
    
    private func getTotalTimeAsString() -> String {
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
    
    private func getTotalPushups() -> Int{
        var sum = 0
        for set in setData {
            sum += Int(set.pushups)
        }
        return sum
    }
    
    private func getAvgPushups(totalPushups: Int) -> Int{
        let sets = setData.count
        if sets > 0 {
            let answer = Int(totalPushups / setData.count)
            return answer
        } else {
            return 0
        }
    }
    
    func fetchData() {
        let moc = CoreDataStack.shared.mainContext
        let dataFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "SetOfPushups")
         
        do {
            let fetchedData = try moc.fetch(dataFetch) as! [SetOfPushups]
            self.setData = fetchedData
        } catch {
            fatalError("Failed to fetch pushup data: \(error)")
        }
    }
}
