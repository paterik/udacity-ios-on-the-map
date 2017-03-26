//
//  PageSetProfileViewController.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 13.03.17.
//  Copyright © 2017 Patrick Paechnatz. All rights reserved.
//

import UIKit
import MapKit

class PageSetProfileViewController: PageSetViewController {
    
    //
    // MARK: Constants
    //
    
    let debugMode: Bool = false
    
    //
    // MARK: Variables
    //
    
    var mapView: MKMapView!
    
    //
    // MARK: IBOutlet Variables
    //
    
    @IBOutlet weak var inpFirstname: UITextField!
    @IBOutlet weak var inpLastname: UITextField!
    @IBOutlet weak var inpMediaURL: UITextField!
    @IBOutlet weak var btnCloseView: UIBarButtonItem!
    @IBOutlet weak var btnSaveProfile: UIBarButtonItem!
    
    //
    // MARK: IBAction Methods
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
                
                //
                // weazL 1001: hier muss nach update oder createMode unterschieden werden !!!
                //
                self.clientParse.setStudentLocation (studentData) { (success, error) in
                    
                    if success == true {
                        
                        self.btnCloseViewAction(sender)
                        
                    } else {
                        
                        // client error saving profile? do something ... but for now just clean up the alert dialog
                        let alertController = UIAlertController(title: "Alert", message: error, preferredStyle: UIAlertControllerStyle.alert)
                        let Action = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in }
                        
                        alertController.addAction(Action)
                        OperationQueue.main.addOperation {
                            self.present(alertController, animated: true, completion:nil)
                        }
                    }
                }
                
            } else {
                // validation error before saving profile? show corresponding message as dialog
                alertController.message = error
                self.present(alertController, animated: true, completion:nil)
            }
        }
    }
}
