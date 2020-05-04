//
//  DataViewController.swift
//  Pushup
//
//  Created by Dennis Rudolph on 4/18/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import CoreData
import Charts

class DataViewController: UIViewController {
    
    var setData: [SetOfPushups] = []
    
    @IBOutlet weak var totalPushupsLabel: UILabel!
    @IBOutlet weak var avgPushupsLabel: UILabel!
    @IBOutlet weak var totalSetsLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var chartFrameView: UIView!
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var noDataLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
        updateViews()
        setupChart()
        
        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(screenEdgeSwiped))
        edgePan.edges = .left
        
        view.addGestureRecognizer(edgePan)
    }
    
    @objc func screenEdgeSwiped(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        if recognizer.state == .recognized {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func setupChart() {
        //Fetch Data
        var entries: [ChartDataEntry] = []
        var count: Int = 0
        for set in setData {
            count += 1
            let entry = ChartDataEntry(x: Double(count), y: Double(set.pushups))
            entries.append(entry)
        }
        let set = LineChartDataSet(entries: entries, label: "")
        
        if setData.count < 2 {
            set.drawCirclesEnabled = true
            set.drawCircleHoleEnabled = false
            set.circleColors = [NSUIColor(red: 178/255, green: 255/255, blue: 176/255, alpha: 1.0)]
            set.circleRadius = 5
        } else {
            set.drawCirclesEnabled = false
        }
        
        set.mode = .cubicBezier
        set.lineWidth = 3
        set.setColor(NSUIColor(red: 178/255, green: 255/255, blue: 176/255, alpha: 1.0))
//        set.fill = Fill(.white)
        set.fillAlpha = 0.6
        set.drawHorizontalHighlightIndicatorEnabled = false
        set.highlightColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1.0)
        let data = LineChartData(dataSet: set)
        data.setDrawValues(false)
        lineChartView.data = data
        
        //Frame Setup
        chartFrameView.layer.cornerRadius = 40
        chartFrameView.layer.cornerRadius = 40
        chartFrameView.layer.shadowColor = UIColor.lightGray.cgColor
        chartFrameView.layer.shadowOpacity = 0.3
        chartFrameView.layer.shadowOffset = .zero
        chartFrameView.layer.shadowRadius = 10
        
        
        //Chart Setup
//        lineChartView.backgroundColor = chartFrameView.backgroundColor
        lineChartView.backgroundColor = .clear
        lineChartView.drawGridBackgroundEnabled = false
        lineChartView.rightAxis.enabled = false
        lineChartView.legend.enabled = false
        
        let yAxis = lineChartView.leftAxis
        yAxis.labelFont = .boldSystemFont(ofSize: 12) //Make custom font
        yAxis.setLabelCount(6, force: false)
        yAxis.axisLineColor = totalPushupsLabel.textColor
        yAxis.labelTextColor = totalPushupsLabel.textColor
        yAxis.gridColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1.0)
        
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.setLabelCount(8, force: false)
        lineChartView.xAxis.axisLineColor = totalPushupsLabel.textColor
        lineChartView.xAxis.labelTextColor = totalPushupsLabel.textColor
        lineChartView.xAxis.drawGridLinesEnabled = false
        
//        lineChartView.animate(xAxisDuration: 1)
    }
    
    
    @IBAction func backTapped(sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func resetTapped(sender: UIButton) {
        let resetAlert = UIAlertController(title: "Are you sure you want to do this?", message: "All of your saved data will be lost", preferredStyle: .actionSheet)
        resetAlert.addAction(UIAlertAction(title: "Reset", style: .destructive, handler: { (_) in
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SetOfPushups")

            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

            do {
                try CoreDataStack.shared.mainContext.execute(batchDeleteRequest)
                DispatchQueue.main.async {
                    self.fetchData()
                    self.updateViews()
                    self.setupChart()
                }
            } catch {
                let errorAlert = UIAlertController(title: "There was a problem deleting your data", message: "Please close the app and re-try", preferredStyle: .actionSheet)
                errorAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                DispatchQueue.main.async {
                    self.present(errorAlert, animated: true)
                }
            }
        }))
        resetAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(resetAlert, animated: true)
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
        
        if totalPushups == 0 {
            noDataLabel.isHidden = false
        } else {
            noDataLabel.isHidden = true
        }
    }
    
    private func getTotalTimeAsString() -> String {
        var sum = 0
        for set in setData {
            sum += Int(set.time)
            print(set.time)
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
    
    private func getDailyAvg() {
        
    }
    
    func fetchData() {
        let moc = CoreDataStack.shared.mainContext
        let dataFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "SetOfPushups")
        let sort = NSSortDescriptor(key: "date", ascending: true)
        dataFetch.sortDescriptors = [sort]
         
        do {
            let fetchedData = try moc.fetch(dataFetch) as! [SetOfPushups]
            self.setData = fetchedData
        } catch {
            fatalError("Failed to fetch pushup data: \(error)")
        }
    }
}

extension DataViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        // Handle selected data
    }
}
