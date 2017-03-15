//
//  ProfileEditViewController.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 13.03.17.
//  Copyright © 2017 Patrick Paechnatz. All rights reserved.
//

import UIKit

class ProfileEditViewController: UIViewController, EditViewProtocol {
    
    //
    // MARK: Convarnts
    //
    let debugMode: Bool = false
    let clientParse = PRSClient.sharedInstance
    let clientUdacity = UDCClient.sharedInstance
    
    //
    // MARK: Variables
    //
    var useCurrentDeviceLocation: Bool = false
    
    //
    // MARK: IBOutlet Variables
    //
    @IBOutlet weak var inpFirstname: UITextField!
    @IBOutlet weak var inpLastname: UITextField!
    @IBOutlet weak var inpMediaURL: UITextField!
    @IBOutlet weak var btnCloseView: UIBarButtonItem!
    @IBOutlet weak var btnSaveProfile: UIBarButtonItem!
    
    //
    // MARK: IBOutlet Actions
    //
    @IBAction func btnCloseViewAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func btnSaveProfileAction(_ sender: Any) {
    
        let alertController = UIAlertController(
            title: "Alert",
            message: "Validation-Error in your user profile",
            preferredStyle: UIAlertControllerStyle.alert
        )
        
        let Action = UIAlertAction(title: "OK", style: .default) { (action: UIAlertAction!) in }
            alertController.addAction(Action)
        
        validateStudentMetaData() { (success, error, studentData) in
            
            if success == true {
                
                print ("------------ data seems valid --------------")
                print (studentData ?? "no-data")
                
            } else {
                alertController.message = error
                self.present(alertController, animated: true, completion:nil)
            }
        }
        
    
        /*clientParse.getAllStudentLocations () { (success, error) in
            

                
            } else {
                
                // error? do something ... but for now just clean up the alert dialog
                alertController.message = error
                
                OperationQueue.main.addOperation {
                    self.present(alertController, animated: true, completion:nil)
                }
            }
        }*/
    }
    
    func validateStudentMetaData(
        _ completionHandlerForValidateData: @escaping (
            _ success: Bool?,
            _ error: String?,
            _ studentData: PRSStudentData?) -> Void) {
    
        if inpFirstname.text?.isEmpty ?? true && inpLastname.text?.isEmpty ?? true {
            
            completionHandlerForValidateData(false, "Up's, validation for your user profile failed! Check your firstname/lastname!", nil)
        }
        
        let currentStudentDict : NSDictionary =
            [
                "firstName": inpFirstname.text!,
                "lastName": inpLastname.text!,
                "mediaURL": "",
                "mapString": "test",
                "uniqueKey": "9999999999",
                "latitude": 51.053059,
                "longitude": 13.733758,
            ]
        
        completionHandlerForValidateData(true, nil, PRSStudentData(currentStudentDict))
   
    }
}
