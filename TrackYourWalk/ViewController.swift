//
//  ViewController.swift
//  TrackYourWalk
//
//  Created by Vikas on 12/09/17.
//  Copyright © 2017 Vikas. All rights reserved.
//
import UIKit
import CoreMotion

/// Provides infrastructure for managing Innerview .It is responsible for loading and disposing of those views, for managing interactions with those views, and for coordinating responses with any appropriate data objects.
class ViewController: UIViewController {
    
    /// This is Outlet of Label Start to display start and pause text
    @IBOutlet weak var labelStart: UILabel!
    
    /// This is Outlet of Label Stop to display Stop text
    @IBOutlet weak var labelStop: UILabel!
    
    /// This is Outlet of Label current Steps Count
    @IBOutlet weak var lblStepsCount: UILabel!
    
    /// This is Outlet of Label current Distance
    @IBOutlet weak var lblDistance: UILabel!
    
    /// This is Outlet of Button Start or Pause
    @IBOutlet weak var buttonStart: UIButton!
    
    /// This is Outlet of Button Stop
    @IBOutlet weak var buttonStop: UIButton!
    
    /// This Outlet of Imageview for Animating Steps
    @IBOutlet weak var imageViewSteps: UIImageView!
    
    /// Current Steps Count
    private var currentStepsCount  = 0
    
    /// Current Distance walked
    private var currentDistance  = 0.0
    
    /// Total Steps walked
    private var totalStepCount  = 10
    
    /// Total Distance walked
    private var totalDistance  = 10.0
    
    /// This variable is used for pedometer state weather start or stop.
    private var isStart = false
    
    /// Initialise Instance of CMPedometer.
    private let pedometer = CMPedometer()
    
    ///Start Date
    private var startDate : Date?
    
    /// This is called after view controller loaded into memory and initalise inner view
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Initialise imageview  with images
        imageViewSteps.animationImages = [UIImage(named: "isteps2")!,UIImage(named: "isteps")!,UIImage(named: "isteps1")!]
        imageViewSteps.clipsToBounds = true
        imageViewSteps.animationDuration  = 0.8
        imageViewSteps.animationRepeatCount  = 0
        
        //initially stop button is disabled
        buttonStop.isEnabled = false
        healthKitAuthorisation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //Check weather device support motion sensor or not
        if !CMMotionActivityManager.isActivityAvailable(){
            alertViewWithMessage(message: "Your doesn't support Motion sensor")
            lblStepsCount.text = "Your doesn't support Motion sensor"
            buttonStart.isEnabled = false
            buttonStop.isEnabled = false
        }
    }

    /**
     This function is used to start updates from pedometer and update label to display current steps count and distance
     */
    func startTracking() {
        // start live tracking
        if totalStepCount == 0 {
            lblDistance.text = "Getting disatnce walk..."
            lblStepsCount.text = "Getting your steps count..."
        }
        else{
            lblDistance.text = "Distance travelled: \(totalDistance) meters"
            lblStepsCount.text = "Steps Walked: \(totalStepCount)"
        }
        
        startDate = Date()
        //pedometer start
        pedometer.startUpdates(from: startDate!) { (pedometerData, error) in
            
            //Main thread called to update date on UI
            DispatchQueue.main.async {
                
                //Pedmerter Data checked for nil values
                if pedometerData != nil{
                    self.updateLabels(pedometerData: pedometerData!)
                }else if let error = error {
                    self.handleError(error: error as NSError)
                    self.lblDistance.text = "Unable to get distance."
                    self.lblStepsCount.text = "Unable to get count."
                    
                    //Pedometer stop due to error
                    self.stopTracking()
                }
            }
        }
    }
    
    /**
     This function takes CMPedometerData as parameter and update stepscount and distance travel
     - Parameter  pedometerData: CMPedometerData given by pedometer
     */
    func updateLabels(pedometerData :CMPedometerData){
        //StepCount Availability Check
        if CMPedometer.isStepCountingAvailable(){
            
            //StepsCount with stored value when pause called
            currentStepsCount = Int(pedometerData.numberOfSteps)
            totalStepCount = totalStepCount + Int(pedometerData.numberOfSteps)
            lblStepsCount.text = "Steps Walked: \(totalStepCount)"
        }else{
            lblStepsCount.text = "Steps counter not avialable."
        }
        
        //Distance Availability Check
        if CMPedometer.isDistanceAvailable(){
            //Diatance with stored value when pause called
            currentDistance =  (pedometerData.distance as! Double)
            totalDistance =  totalDistance + currentDistance
            lblDistance.text = "Distance travelled: \(totalDistance) meters"
        }else{
            lblDistance.text = "Distance estimate not available.."
        }
    }
    
    /**
     button action to start or pause pedometer
     - Parameter  sender: UIButton
     */
    @IBAction func startOrPauseTracking(_ sender: UIButton) {
        if isStart{
            buttonStart.setBackgroundImage(UIImage(named: "play"), for: .normal)
            imageViewSteps.stopAnimating()
            labelStart.text = "Resume"
            isStart = false
            
            //Pedometer Stopped and disatnce and step value stored
            pedometer.stopUpdates()
            totalDistance = currentDistance
            totalStepCount = currentStepsCount
        }else{
            startTracking()
            buttonStop.isEnabled = true
            imageViewSteps.startAnimating()
            buttonStart.setBackgroundImage(UIImage(named: "pause"), for: .normal)
            labelStart.text = "Pause"
            isStart = true
        }
    }
    
    /**
     Button action to stop pedometer
     - Parameter  sender: UIButton
     */
    @IBAction func stopTracking(_ sender: UIButton) {
        stopTracking()
    }
    
    /**
     Function to stop pedometer
     */
    func stopTracking() {
        buttonStart.setBackgroundImage(UIImage(named: "play"), for: .normal)
        imageViewSteps.stopAnimating()
        labelStart.text = "Start"
        isStart = false
        buttonStop.isEnabled = false
        pedometer.stopUpdates()
        totalDistance = 0.0
        totalStepCount = 0
        saveDataToHealthKit()
    }
    
    /**
     Function to save data to heathkit
     */
    func saveDataToHealthKit() {
        if HealthKitSetup.checkDistanceWalkHealthKitAuthorizationStatus() == .sharingAuthorized {
            HealthKitSetup.saveDistanceWalkSample(distance: currentDistance, startDate: startDate!, endDate: Date())
        }else{
            self.alertViewWithMessage(message: "\n please give distanceWalkingRunning authorisation in health kit from healthkit  to track your health record in health kit ")
        }
        if HealthKitSetup.checkStepCountHealthKitAuthorizationStatus() == .sharingAuthorized {
            HealthKitSetup.saveStepsSample(steps: Double(currentStepsCount), startDate: startDate!, endDate: Date())
        }else{
            self.alertViewWithMessage(message: "\n please give step count authorisation in health kit from healthkit  to track your health record in health kit ")
        }
    }
    
    /// function to display alert
    /// Parameter message : String message to display on alert
    func alertViewWithMessage(message :String) {
        let alertController = UIAlertController(title: "Track Your Walk", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (UIAlertAction) in
            self.navigationController?.dismiss(animated: true, completion: nil)
        })
        )
        self.navigationController?.present(alertController, animated: true, completion: nil)
    }
    
    
    func handleError(error: NSError) {
        alertViewWithMessage(message: error.localizedDescription)
        
        if error.code == Int(CMErrorMotionActivityNotAuthorized.rawValue) {
            print("here")
            // delegate?.didEncounterAuthorizationError(self)
        }
        else {
            print(error)
        }
    }
    
    /// Function for healthkit autorisation
    func healthKitAuthorisation() {
            HealthKitSetup.authorizeHealthKit { (authorized, error) in
            guard authorized else {
                let baseMessage = "HealthKit Authorization Failed"
                if let error = error {
                    print("\(baseMessage). Reason: \(error.localizedDescription)")
                } else {
                    print(baseMessage)
                }
                self.alertViewWithMessage(message: baseMessage + "\n please give health kit authorisation from setting to track your health record in health kit ")
                return
            }
            print("HealthKit Successfully Authorized.")
        }
        
    }
}






