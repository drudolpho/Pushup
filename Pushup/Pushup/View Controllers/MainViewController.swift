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


class MainViewController: UIViewController, UIGestureRecognizerDelegate {
   
    let defaults = UserDefaults.standard
    
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
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet weak var soundButton: UIButton!
    @IBOutlet weak var startImage: UIImageView!
    @IBOutlet weak var instructionCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupControllers()
        instructionCollectionView.delegate = self
        instructionCollectionView.dataSource = self
        instructionCollectionView.isPagingEnabled = true
        instructionCollectionView.backgroundColor = topView.backgroundColor
        instructionCollectionView.showsHorizontalScrollIndicator = false
        self.view.bringSubviewToFront(pageControl)
        //need to create a day, as well as all of the days since the last day. When creating a pushupSet it has to update the current day with the new info.
    }
    
    func prepareDark() {
        topView.isHidden = true
        instructionCollectionView.isHidden = true
        pageControl.isHidden = true
        quoteLabel.isHidden = true
        pushupLabel.isHidden = false
        soundButton.isHidden = false
        pushupLabel.text = String(countDownTime)
        setSpeakOn(bool: !defaults.bool(forKey: "sound"))
        bottomView.backgroundColor = .black
        self.view.backgroundColor = .black
        
    }
    
    func prepareLight() {
        topView.isHidden = false
        instructionCollectionView.isHidden = false
        pageControl.isHidden = false
        quoteLabel.isHidden = false
        soundButton.isHidden = true
        pushupLabel.isHidden = true
        bottomView.backgroundColor = self.topView.backgroundColor
        self.view.backgroundColor = self.topView.backgroundColor
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let x = targetContentOffset.pointee.x
        pageControl.currentPage = Int(x / instructionCollectionView.frame.width)
    }
    
    func setupViews() {
        pushupLabel.isHidden = true
        soundButton.isHidden = true
        pushupLabel.text = String(countDownTime)
//        instructionView.layer.cornerRadius = 40
//        instructionView.layer.shadowColor = UIColor.lightGray.cgColor
//        instructionView.layer.shadowOpacity = 0.3
//        instructionView.layer.shadowOffset = .zero
//        instructionView.layer.shadowRadius = 10
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
            startImage.image = UIImage(named: "ReadyButton")
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
        setSpeakOn(bool: audioController.speakOn)
    }
    
    //Timer Methods
    private func setSpeakOn(bool: Bool) {
        if bool == false {
            audioController.speakOn = true
            soundButton.setImage(UIImage(named: "speak"), for: .normal)
            defaults.set(true, forKey: "sound")
        } else if bool == true {
            audioController.speakOn = false
            soundButton.setImage(UIImage(named: "sound"), for: .normal)
            defaults.set(false, forKey: "sound")
        }
    }
    
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

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FirstCell", for: indexPath) as? InstructionCollectionViewCell else { return UICollectionViewCell()}
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SecondCell", for: indexPath) as? Instruction2CollectionViewCell else { return UICollectionViewCell()}
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.size.height
        let width = collectionView.frame.size.width
        return CGSize(width: width, height: height - 35)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
