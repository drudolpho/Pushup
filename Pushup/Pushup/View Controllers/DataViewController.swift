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
    
    var dataController: DataController?
    var dayCache: [Double: (Date, String)] = [:]
    
    @IBOutlet weak var totalPushupsLabel: UILabel!
    @IBOutlet weak var avgPushupsLabel: UILabel!
    @IBOutlet weak var totalSetsLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var streakLabel: UILabel!
    @IBOutlet weak var chartFrameView: UIView!
    @IBOutlet weak var dailyAvgLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var lineChartView: LineChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataController?.fetchDayData()
        dataController?.fetchSetData()
        setupViews()

        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(sender:)))
        view.addGestureRecognizer(backSwipe)
    }
    
    @objc func handleSwipe(sender: UISwipeGestureRecognizer) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func backTapped(sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func resetTapped(sender: UIButton) {
        let resetAlert = UIAlertController(title: "Are you sure you want to do this?", message: "All of your saved data will be lost", preferredStyle: .actionSheet)
        resetAlert.addAction(UIAlertAction(title: "Reset", style: .destructive, handler: { (_) in
            
            self.dataController?.deleteData(completion: { (deletionWorked) in
                if deletionWorked {
                    DispatchQueue.main.async {
                        self.updateViews()
                        self.setupChart()
                    }
                } else {
                    let errorAlert = UIAlertController(title: "There was a problem deleting your data", message: "Please close the app and re-try", preferredStyle: .actionSheet)
                    errorAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    DispatchQueue.main.async {
                        self.present(errorAlert, animated: true)
                    }
                }
            })
        }))
        resetAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(resetAlert, animated: true)
    }
    
    func setupViews() {
        updateViews()
        setupChart()
    }
    
    func updateViews() {
        guard let dataController = dataController else { return }
        //Total Pushups
        let totalPushups = dataController.getTotalPushups()
        totalPushupsLabel.text = "\(totalPushups)"
        //Average Pushups per set
        let avgPushups = dataController.getAvgPushups(totalPushups: totalPushups)
        avgPushupsLabel.text = "\(avgPushups)"
        //Total Sets
        let totalSets = dataController.setData.count
        totalSetsLabel.text = "\(totalSets)"
        //Total time
        totalTimeLabel.text = dataController.getTotalTimeAsString()
        //Streak
        let streak = dataController.getStreak()
        streakLabel.text = String(streak)
        if streak == 0 {
            streakLabel.textColor = .red
        } else {
            streakLabel.textColor = .green
        }
        
        let dateAsString = dataController.formatter.string(from: dataController.dayData?.last?.date ?? Date())
        dailyAvgLabel.text = "Daily Avg: \(dataController.dayData?.last?.average ?? 0)"
        dateLabel.text = dateAsString
    }
    
    @objc func screenEdgeSwiped(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        if recognizer.state == .recognized {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func setupChart() {
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
        lineChartView.pinchZoomEnabled = false
        lineChartView.doubleTapToZoomEnabled = false
        lineChartView.delegate = self
//        lineChartView.dragEnabled = false
        
        guard let dataController = dataController, let dayData = dataController.dayData, let lastDay = dayData.last else { return }
        
        let yAxis = lineChartView.leftAxis
        yAxis.labelFont = UIFont(name: "SeoulNamsan", size: 12) ?? UIFont.boldSystemFont(ofSize: 10) //Make custom font
//        yAxis.setLabelCount(6, force: false)
        yAxis.axisMinimum = 0
        var highest = Double(dataController.getHighestDayAvg())
        if highest < 1 {
            highest = 30
        }
        yAxis.axisMaximum = highest * 1.5
        yAxis.axisMinLabels = 5
        yAxis.granularityEnabled = true
        yAxis.granularity = 1
        yAxis.axisLineColor = totalPushupsLabel.textColor
        yAxis.labelTextColor = totalPushupsLabel.textColor
        yAxis.gridColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1.0)
        
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.labelFont = UIFont(name: "SeoulNamsan", size: 12) ?? UIFont.boldSystemFont(ofSize: 10)
        lineChartView.xAxis.axisMinimum = 1
//        lineChartView.xAxis.axisMinLabels = 12
        if lastDay.count > 7 {
            lineChartView.xAxis.axisMaximum = Double(lastDay.count)
        } else {
            lineChartView.xAxis.axisMaximum = 7
        }
        lineChartView.xAxis.axisLineColor = totalPushupsLabel.textColor
        lineChartView.xAxis.labelTextColor = totalPushupsLabel.textColor
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.xAxis.granularityEnabled = true
        lineChartView.xAxis.granularity = 1
        lineChartView.xAxis.labelCount = 7
//        let numbers = ["1", "2", "3", "4", "5", "6", "7"]
//        lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:numbers)
//        lineChartView.xAxis.granularity = 1
//        lineChartView.xAxis.setLabelCount(7, force: true)
        
        
        //Data Setup
        if dayData.count <= 1 {
//            guard dayData.first?.pushups ?? 0 > Int32(0) else { return }
        }
        
        var entries: [ChartDataEntry] = []
        
        for day in dayData {
            dayCache[Double(day.count)] = (day.date ?? Date(), String(day.average))
            let entry = ChartDataEntry(x: Double(day.count), y: Double(day.average))
            entries.append(entry)
        }
        let set = LineChartDataSet(entries: entries, label: "")
        if dayData.count < 2 {
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
        let format = NumberFormatter()
        format.numberStyle = .none
        let formatter = DefaultValueFormatter(formatter: format)
        data.setValueFormatter(formatter)
        data.setDrawValues(false)
        lineChartView.data = data
        //        lineChartView.animate(xAxisDuration: 1)
    }
}
    

extension DataViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        let date = self.dayCache[entry.x]?.0
        let avg = self.dayCache[entry.x]?.1
        let dateAsString = dataController?.formatter.string(from: date ?? Date())
        
        dailyAvgLabel.text = "Daily Avg: \(avg ?? "")"
        dateLabel.text = dateAsString
    }
}
