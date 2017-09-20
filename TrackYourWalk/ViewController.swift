//
//  ViewController.swift
//  TrackYourWalk
//
//  Created by Vikas on 12/09/17.
//  Copyright © 2017 Vikas. All rights reserved.
//
import UIKit
import CoreMotion

class ViewController: UIViewController {

    @IBOutlet weak var labelStart: UILabel!
    @IBOutlet weak var labelStop: UILabel!
    @IBOutlet weak var buttonStart: UIButton!
    @IBOutlet weak var buttonStop: UIButton!
    @IBOutlet weak var lblStepsCount: UILabel!
    @IBOutlet weak var imageViewSteps: UIImageView!
    @IBOutlet weak var lblDistance: UILabel!
    
    var currentStepsCount  = 0
    
    var currentDistance  = 0.0
    
    var totalStepsCount  = 0
    
    var totalDistance  = 0.0

    var isStart = false
    
    let pedometer = CMPedometer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageViewSteps.animationImages = [UIImage(named: "isteps2")!,UIImage(named: "isteps")!,UIImage(named: "isteps1")!]
        imageViewSteps.clipsToBounds = true
        imageViewSteps.animationDuration  = 0.8
        imageViewSteps.animationRepeatCount  = 0
        buttonStop.isEnabled = false
    }


    func startTracking() {
        // start live tracking
        lblDistance.text = "Getting disatnce walk..."
        lblStepsCount.text = "Getting your steps count..."
        pedometer.startUpdates(from: Date()) { (pedometerData, error) in
            print(error.debugDescription)
            if pedometerData != nil{
            self.updateLabels(pedometerData: pedometerData!)
            print(pedometerData!)
            }
        }
    }

    func updateLabels(pedometerData :CMPedometerData)  {
    
        if CMPedometer.isStepCountingAvailable(){
            currentStepsCount = totalStepsCount + Int(pedometerData.numberOfSteps)
            lblStepsCount.text = "Steps Walked:\(currentStepsCount)"
        }else{
            lblStepsCount.text = "Steps counter not avialable."
        }
    
        if CMPedometer.isDistanceAvailable(){
            currentDistance =  totalDistance + (pedometerData.distance as! Double)
            lblDistance.text = "Distance travelled: \(currentDistance) meters"
        }else{
            lblDistance.text = "Distance estimate not available.."
        }
    }
    
    
    @IBAction func startOrPauseTracking(_ sender: UIButton) {
        if  isStart {
            buttonStart.setBackgroundImage(UIImage(named: "play"), for: .normal)
            imageViewSteps.stopAnimating()
            labelStart.text = "Resume"
            isStart = false
            totalDistance = currentDistance
            totalStepsCount = currentStepsCount
        }else{
            startTracking()
            buttonStop.isEnabled = true
            imageViewSteps.startAnimating()
            buttonStart.setBackgroundImage(UIImage(named: "pause"), for: .normal)
            labelStart.text = "Pause"
            isStart = true
           
        }
    }
    
    @IBAction func stopTracking(_ sender: UIButton) {
      
        buttonStart.setBackgroundImage(UIImage(named: "play"), for: .normal)
        imageViewSteps.stopAnimating()
        labelStart.text = "Start"
        isStart = false
        buttonStop.isEnabled = false
        pedometer.stopUpdates()
        totalDistance = 0.0
        totalStepsCount = 0
    }
}


