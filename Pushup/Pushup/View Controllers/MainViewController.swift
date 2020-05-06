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
    let dataController = DataController()
    
    //Time
    var countDownTime = 3
    var pSetTime = 0
    var timer = Timer()
    var finishedAlert: UIAlertController?
    
    //Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var pushupLabel: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var instructionView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet weak var soundButton: UIButton!
    @IBOutlet weak var startImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupControllers()
        
        //need to create a day, as well as all of the days since the last day. When creating a pushupSet it has to update the current day with the new info.
    }
    
    func prepareDark() {
        topView.isHidden = true
        instructionView.isHidden = true
        quoteLabel.isHidden = true
        pushupLabel.isHidden = false
        soundButton.isHidden = false
        pushupLabel.text = String(countDownTime)
        bottomView.backgroundColor = .black
        self.view.backgroundColor = .black
    }
    
    func prepareLight() {
        topView.isHidden = false
        instructionView.isHidden = false
        quoteLabel.isHidden = false
        soundButton.isHidden = true
        pushupLabel.isHidden = true
        bottomView.backgroundColor = self.topView.backgroundColor
        self.view.backgroundColor = self.topView.backgroundColor
    }
    
    func setupViews() {
        pushupLabel.isHidden = true
        soundButton.isHidden = true
        pushupLabel.text = String(countDownTime)
        instructionView.layer.cornerRadius = 40
        instructionView.layer.shadowColor = UIColor.lightGray.cgColor
        instructionView.layer.shadowOpacity = 0.3
        instructionView.layer.shadowOffset = .zero
        instructionView.layer.shadowRadius = 10
        //Nav Bar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    func setupControllers() {
        pushupController.delegate = self
        pushupController.dataController = dataController
        cameraController.setUpCamera()
        cameraController.audioController = audioController
        cameraController.pushupController = pushupController
    }
    

    @IBAction func buttonTapped(sender: UIButton) {
        
        if cameraController.captureSession.isRunning {
            cameraController.captureSession.stopRunning()
            stopTimer()
            startImage.image = UIImage(named: "StartButton")
            setupAlert()
            prepareLight()
            self.present(finishedAlert!, animated: true)
        } else {
            cameraController.captureSession.startRunning()
            startImage.image = UIImage(named: "StopButton")
            startCountDown()
            prepareDark()
        }
    }
    
    @IBAction func soundTapped(sender: UIButton) {
        
    }
    
    //Timer Methods
    
    private func startCountDown() {
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countDownAction), userInfo: nil, repeats: true)
    }
    
    private func startTiming() {
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    
    private func stopTimer() {
        timer.invalidate()
    }
    
    private func reset() {
        pushupController.pushupCount = 0
        cameraController.reset()
        countDownTime = 3
        pSetTime = 0
    }
    
    @objc func countDownAction() {
        if countDownTime == 1 {
            pushupLabel.text = "Go!"
            stopTimer()
            startTiming()
            cameraController.captureStartingBrightness()
        } else {
            countDownTime -= 1
            pushupLabel.text = String(countDownTime)
        }
    }
    
    @objc func timerAction() {
        pSetTime += 1
    }
   
    private func setupAlert() {
        finishedAlert = UIAlertController(title: "\(pushupController.pushupCount) pushups in \(pSetTime) seconds ", message: "Save this set?", preferredStyle: .alert)
        finishedAlert?.addAction(UIAlertAction(title: "No", style: .destructive, handler: { (action) in
            self.reset()
        }))
        finishedAlert?.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            if self.dataController.dayIsSet == false {
                let day = Day(pushups: 0, average: 0, sets: 0)
                self.dataController.dayData?.append(day)
            }
            self.pushupController.createSetOfPushups(time: self.pSetTime)
            
            //TESTING
            self.testController.addSet()
            let thisSet = self.testController.counter - 1
            self.testController.printDataForSet(setNum: thisSet)
            //TESTING
            
            self.reset()
        }))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DataSegue" {
            if let viewController = segue.destination as? DataViewController {
                viewController.dataController = dataController
            }
        }
    }
}


extension MainViewController: PushupControllerDelegate {
    func updatePushupLabel(pushups: Int) {
        DispatchQueue.main.async {
            self.pushupLabel.text = String(pushups)
            UIView.animate(withDuration: 0.2) {
                self.pushupLabel.transform = CGAffineTransform(scaleX: 1.8, y: 1.8)
            }
            UIView.animate(withDuration: 0.2) {
                self.pushupLabel.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
        }
    }
}
