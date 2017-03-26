//
//  PageSetProfileViewController.swift
//  OnTheMap
//
//  this class will handle the final student meta update/create profile process
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
    var metaUpdateSuccess: Bool = false
    var metaCreateSuccess: Bool = false
    
    //
    // MARK: IBOutlet Variables
    //
    
    @IBOutlet weak var inpFirstname: UITextField!
    @IBOutlet weak var inpLastname: UITextField!
    @IBOutlet weak var inpMediaURL: UITextField!
    @IBOutlet weak var btnCloseView: UIBarButtonItem!
    @IBOutlet weak var btnSaveProfile: UIBarButtonItem!
    
    //
    // MARK: Overrides
    //
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        loadStudentMetaData()
    }
    
    //
    // MARK: IBAction Methods
    //
    
    @IBAction func btnCloseViewAction(_ sender: Any) {
        
        self.dismiss(animated: true)
    }
    
    @IBAction func btnSaveProfileAction(_ sender: Any) {
        
        let btnOkAction = UIAlertAction(title: "OK", style: .default) { (action: UIAlertAction!) in return }
        let alertController = UIAlertController(
            title: "Alert",
            message: "Validation-Error in your user profile",
            preferredStyle: UIAlertControllerStyle.alert
        )
        
        alertController.addAction(btnOkAction)
        
        validateStudentMetaData() { (success, error, studentData) in
            
            if success == true {
                
                if self.editMode == false {
                
                    if self.createStudentMetaData(studentData) == true { self.btnCloseViewAction(sender) }
                    
                } else {
                
                    if self.updateStudentMetaData(studentData) == true { self.btnCloseViewAction(sender) }
                }
                
            } else {
                // validation error before saving profile? show corresponding message as dialog
                alertController.message = error
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
}
