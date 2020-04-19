//
//  MainViewController.swift
//  Pushup
//
//  Created by Dennis Rudolph on 4/15/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData


class MainViewController: UIViewController{
   
    //Controllers
    let testController = TestController()
    let cameraController = CameraController()
    let audioController = AudioController()
    let pushupController = PushupController()
    
    //Time
    var countDownTime = 3
    var pSetTime = 0
    var timer = Timer()
    var finishedAlert: UIAlertController?
    
    //Outlets
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var countDownLabel: UILabel!
    @IBOutlet weak var pushupLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupControllers()
    }
    
    func setupViews() {
        countDownLabel.isHidden = true
        countDownLabel.text = String(countDownTime)
    }
    
    func setupControllers() {
        pushupController.delegate = self
        cameraController.setUpCamera()
        cameraController.audioController = audioController
        cameraController.pushupController = pushupController
    }

    
    @IBAction func buttonTapped(sender: UIButton) {
        
        if cameraController.captureSession.isRunning {
            cameraController.captureSession.stopRunning()
            button.setTitle("Start", for: .normal)
            stopTimer()
            setupAlert()
            self.present(finishedAlert!, animated: true)
        } else {
            cameraController.captureSession.startRunning()
            button.setTitle("Stop", for: .normal)
            startCountDown()
        }
    }
    
    //Timer Methods
    
    private func startCountDown() {
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countDownAction), userInfo: nil, repeats: true)
        countDownLabel.isHidden = false
    }
    
    private func startTiming() {
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        countDownLabel.isHidden = false
    }
    
    private func stopTimer() {
        timer.invalidate()
    }
    
    private func reset() {
        pushupController.pushupCount = 0
        cameraController.reset()
        countDownTime = 3
        pSetTime = 0
        countDownLabel.text = String(countDownTime)
        countDownLabel.isHidden = true
    }
    
    @objc func countDownAction() {
        if countDownTime == 1 {
            countDownLabel.text = "Go!"
            stopTimer()
            startTiming()
            cameraController.captureStartingBrightness()
        } else {
            countDownTime -= 1
            countDownLabel.text = String(countDownTime)
        }
    }
    
    @objc func timerAction() {
        pSetTime += 1
    }
   
    private func setupAlert() {
        finishedAlert = UIAlertController(title: "\(pushupController.pushupCount) pushups", message: "in \(pSetTime) seconds", preferredStyle: .alert)
        finishedAlert?.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) in
            self.reset()
        }))
        finishedAlert?.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            self.pushupController.createSetOfPushups(time: self.pSetTime)
            
            //TESTING
            self.testController.addSet()
            let thisSet = self.testController.counter - 1
            self.testController.printDataForSet(setNum: thisSet)
            //TESTING
            
            self.reset()
        }))
    }
}


extension MainViewController: PushupControllerDelegate {
    func updatePushupLabel(pushups: Int) {
        DispatchQueue.main.async {
            self.pushupLabel.text = String(pushups)
        }
    }
}
