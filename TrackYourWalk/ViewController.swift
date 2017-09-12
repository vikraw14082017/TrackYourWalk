//
//  ViewController.swift
//  TrackYourWalk
//
//  Created by Vikas on 12/09/17.
//  Copyright © 2017 Vikas. All rights reserved.
//http://pinkstone.co.uk/how-to-access-the-step-counter-and-pedometer-data-in-ios-9/
import UIKit
import CoreMotion
class ViewController: UIViewController {

    @IBOutlet weak var lblStepsCount: UILabel!
    
    
    @IBOutlet weak var lblStepsPerSecond: UILabel!
    
    @IBOutlet weak var lblDistance: UILabel!
    
    @IBOutlet weak var lblSpeed: UILabel!
    
    let pedometer = CMPedometer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func startTracking() {
        
        // start live tracking
        pedometer.startUpdates(from: Date()) { (pedometerData, error) in
            
            print(error.debugDescription)
            if pedometerData != nil{
            self.updateLabels(pedometerData: pedometerData!)
            print(pedometerData!)
            }
        }
//        [self.pedometer startPedometerUpdatesFromDate:[NSDate date] withHandler:^(CMPedometerData * _Nullable pedometerData, NSError * _Nullable error) {
//            
//            // this block is called for each live update
//            [self updateLabels:pedometerData];
//            
//            }];
    }

    func updateLabels(pedometerData :CMPedometerData)  {
    
        if CMPedometer.isStepCountingAvailable(){
            lblStepsCount.text = "Steps Walked:\(pedometerData.numberOfSteps)"
        }else{
            lblStepsCount.text = "Steps counter not avialable."
        }
    
        if CMPedometer.isDistanceAvailable(){
            lblDistance.text = "Distance travelled: \(String(describing: pedometerData.distance)) meters"
        }else{
            lblStepsCount.text = "Distance estimate not available.."
        }
        if CMPedometer.isCadenceAvailable() && pedometerData.currentCadence != nil{
            lblStepsPerSecond.text = "\(String(describing: pedometerData.currentCadence)) steps per second"
        }else{
            lblStepsCount.text = "Steps counter not avialable."
        }
        if CMPedometer.isPaceAvailable() && pedometerData.currentPace != nil{
            lblStepsCount.text = "Current speed:\(String(describing: pedometerData.currentPace))"
        }else{
            lblStepsCount.text = "Current speed not avialable."
        }
        
        
//    NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
//    formatter.maximumFractionDigits = 2;
//    
//    // step counting
//        
//    if ([CMPedometer isStepCountingAvailable]) {
//    self.stepsLabel.text = [NSString stringWithFormat:@"Steps walked: %@", [formatter stringFromNumber:pedometerData.numberOfSteps]];
//    } else {
//    self.stepsLabel.text = @"Step Counter not available.";
//    }
    
    // distance
//    if ([CMPedometer isDistanceAvailable]) {
//    self.distanceLabel.text = [NSString stringWithFormat:@"Distance travelled: \n%@ meters", [formatter stringFromNumber:pedometerData.distance]];
//    } else {
//    self.distanceLabel.text = @"Distance estimate not available.";
//    }
    
    // pace
//    if ([CMPedometer isPaceAvailable] && pedometerData.currentPace) {
//    self.paceLabel.text = [NSString stringWithFormat:@"Current Pace: \n%@ seconds per meter", [formatter stringFromNumber:pedometerData.currentPace]];
//    } else {
//    self.paceLabel.text = @"Pace not available.";
//    }
    
    // cadence
//    if ([CMPedometer isCadenceAvailable] && pedometerData.currentCadence) {
//    self.cadenceLabel.text = [NSString stringWithFormat:@"Cadence: \n%@ steps per second", [formatter stringFromNumber: pedometerData.currentCadence]];
//    } else {
//    self.cadenceLabel.text = @"Cadence not available.";
//    }
    
 
    }
    
    override func viewDidAppear(_ animated: Bool) {
        startTracking()
    }
    
    func stopTracking()  {
        pedometer.stopUpdates()
    }

}


