//
//  HealthKitSetup.swift
//  TrackYourWalk
//
//  Created by Vikas on 12/09/17.
//  Copyright © 2017 Vikas. All rights reserved.
//
import HealthKit


/// This class proivdes methods to get access to share app data with Health kit and app authorisation to health kit
class HealthKitSetup{
    
    
    private enum HealthkitSetupError: Error {
        case notAvailableOnDevice
        case dataTypeNotAvailable
    }
    
    /// Request for app Healthkit Authorization
     ///  Parameter completion : handler bool success or error
    class func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Swift.Void) {
        
        // Check to see if HealthKit Is Available on this device
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, HealthkitSetupError.notAvailableOnDevice)
            return
        }
        
        //. Prepare the data types that will interact with HealthKit
        guard let stepCount = HKObjectType.quantityType(forIdentifier: .stepCount),
            let distanceWalkingRunning = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning) else {
                completion(false, HealthkitSetupError.dataTypeNotAvailable)
                return
        }
        
        //. Prepare a list of types you want HealthKit to read and write
        let healthKitTypesToWrite: Set<HKSampleType> = [stepCount,
                                                        distanceWalkingRunning]
        
        let healthKitTypesToRead: Set<HKObjectType> = [stepCount,
                                                       distanceWalkingRunning]
        
        //. Request Authorization
        HKHealthStore().requestAuthorization(toShare: healthKitTypesToWrite,
                                             read: healthKitTypesToRead) { (success, error) in
                                                
                                                completion(success, error)
        }
    }
    
     /// Check HKObjectType Stepcount HKAuthorizationStatus
      /// - Returns: HKAuthorizationStatus
    class func checkStepCountHealthKitAuthorizationStatus() -> HKAuthorizationStatus {
        guard let stepCount = HKObjectType.quantityType(forIdentifier: .stepCount)
            else {
                return .notDetermined
        }
        return HKHealthStore().authorizationStatus(for: stepCount)
    }
    
    /** Check HKObjectType distanceWalkingRunning HKAuthorizationStatus
     - Return HKAuthorizationStatus
     */
    class func checkDistanceWalkHealthKitAuthorizationStatus() -> HKAuthorizationStatus {
        guard let distanceWalkingRunning = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)
            else {
                return .notDetermined
        }
        return HKHealthStore().authorizationStatus(for: distanceWalkingRunning)
    }
    
    
    ///Save steps count sample to health kit.
    ///  - Parameter steps: steps walk
   ///  - Parameter startDate: initial sample gathering time
   ///  - Parameter endDate: sample gathering end time
    class func saveStepsSample(steps: Double, startDate: Date ,endDate: Date) {
        
        //  Make sure stepCount type exists
        guard let stepCount = HKObjectType.quantityType(forIdentifier: .stepCount)
            else {
                return
        }
        //  Using the Count HKUnit to create HKQuantitySample
        let stepsWalk = HKQuantity(unit: HKUnit.count(),
                                   doubleValue: steps)
        
        let stepsWalkSample = HKQuantitySample(type: stepCount,
                                               quantity: stepsWalk,
                                               start: startDate,
                                               end: endDate)
        
        //3.  Save the same to HealthKit
        HKHealthStore().save(stepsWalkSample) { (success, error) in
            if let error = error {
                print("Error Saving BMI Sample: \(error.localizedDescription)")
            } else {
                print("Successfully saved BMI Sample")
            }
        }
    }
    
 
 
    /** Save distance sample to health kit
    - Parameter  distance: distance walk
     - Parameter startDate: initial sample gathering time
     - Parameter endDate:  sample gathering end time
    */
    class func saveDistanceWalkSample(distance: Double, startDate: Date ,endDate : Date) {
        
        //1.  Make sure the body mass type exists
        guard let distanceWalkingRunning = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)
            else {
                return
        }
        //2.  Use the Count HKUnit to create a body mass quantity
        
        let totalDistance = HKQuantity(unit: HKUnit.meter(),
                                       doubleValue: distance)
        
        let distanceSample = HKQuantitySample(type: distanceWalkingRunning,
                                              quantity: totalDistance,
                                              start: startDate,
                                              end: endDate)
        
        //3.  Save the same to HealthKit
        HKHealthStore().save(distanceSample) { (success, error) in
            
            if let error = error {
                print("Error Saving BMI Sample: \(error.localizedDescription)")
            } else {
                print("Successfully saved BMI Sample")
            }
        }
    }
}
