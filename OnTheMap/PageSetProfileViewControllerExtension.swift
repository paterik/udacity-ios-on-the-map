//
//  PageSetProfileViewController.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 17.03.17.
//  Copyright © 2017 Patrick Paechnatz. All rights reserved.
//

import UIKit
import MapKit

extension PageSetProfileViewController: UIPageViewControllerDelegate {

    /*
     * update student profile meta data using (parse) api call and parametric metaObject
     */
    func updateStudentMetaData(
       _ studentMetaData: PRSStudentData!) -> Bool! {
        
        metaUpdateSuccess = true
        
        self.clientParse.updateStudentLocation(studentMetaData) { (success, error) in
            
            if success == false {
                
                self.metaUpdateSuccess = false
                
                // client error updating location? show corresponding message and return ...
                let btnOkAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in }
                let alertController = UIAlertController(
                    title: "Alert",
                    message: error,
                    preferredStyle: UIAlertControllerStyle.alert
                )
                
                alertController.addAction(btnOkAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
        
        return metaUpdateSuccess
    }
    
    /*
     * create student profile meta data using (parse) api call and parametric metaObject
     */
    func createStudentMetaData(
       _ studentMetaData: PRSStudentData!) -> Bool! {
        
        metaCreateSuccess = true
        
        self.clientParse.setStudentLocation (studentMetaData) { (success, error) in
            
            if success == false {
                
                self.metaCreateSuccess = false
                
                // client error updating location? show corresponding message and return ...
                let btnOkAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in }
                let alertController = UIAlertController(
                    title: "Alert",
                    message: error,
                    preferredStyle: UIAlertControllerStyle.alert
                )
                
                alertController.addAction(btnOkAction)
                self.present(alertController, animated: true, completion: nil)
                
            }
        }
        
        return metaCreateSuccess
    }
    
    /*
     * load student default meta data based on the last (own) generated one
     */
    func loadStudentMetaData() {
        
        if appDelegate.currentUserStudentLocation != nil {
            
            inpFirstname.text = appDelegate.currentUserStudentLocation!.firstName
            inpLastname.text = appDelegate.currentUserStudentLocation!.lastName
            inpMediaURL.text = appDelegate.currentUserStudentLocation!.mediaURL
            
        }
    }
    
    /*
     * validate student meta data for plausibility
     */
    func validateStudentMetaData(
       _ completionHandlerForValidateData: @escaping (
       _ success: Bool?,
       _ error: String?,
       _ studentData: PRSStudentData?) -> Void) {
        
        // check for vaild input fields (firstName and lastName), return on any error here
        if inpFirstname.text?.isEmpty ?? true && inpLastname.text?.isEmpty ?? true {
            completionHandlerForValidateData(
                false, "Up's, validation for your user profile failed! Check your firstname/lastname!", nil
            )
            
            return
        }
        
        // check current session state, also return on any problem here
        guard let sessionUdacity = clientUdacity.clientSession else {
            completionHandlerForValidateData(
                false, "Up's, no active udacity user session were found! Are you still logged in?", nil
            )
            
            return
        }

        // check longitude availability
        guard let _longitude: Double = appDelegate.useLongitude else {
            completionHandlerForValidateData(
                false, "Up's, unable to fetch longitude from map or device location!", nil
            )
            
            return
        }
        
        // check latitude availability
        guard let _latitude: Double = appDelegate.useLatitude else {
            completionHandlerForValidateData(
                false, "Up's, unable to fetch latitude from map or device location!", nil
            )
            
            return
        }
        
        getStudentMetaProfile(sessionUdacity.accountKey, _latitude, _longitude)
        {
            (success, error, studentData) in
        
            if success == true {
                completionHandlerForValidateData(true, nil, studentData)
            } else {
                completionHandlerForValidateData(false, error, nil)
            }
        }
    }
    
    /*
     * get students profile as NSDictionary block from view input directly and generate (pre)json NSDictionary
     * format as return object block. The meta data will also be prepared (e.g. mediaUrl)
     */
    private func getStudentMetaProfile(
        _ _accountKey: String!,
        _ _latitude: Double!,
        _ _longitude: Double!,
        
        _ completionHandlerForStudentMetaProfile: @escaping (
        _ success: Bool?,
        _ error: String?,
        _ studentData: PRSStudentData?) -> Void) {
    
        let _geocoder = CLGeocoder()
        let _location = CLLocation(latitude: _latitude!, longitude: _longitude!)
        
        var _mapString: String?
        var _objectId: String! = ""
        
        _geocoder.reverseGeocodeLocation(_location)
        {
            (placemarks, error) in
            
            if error != nil {
                completionHandlerForStudentMetaProfile(false, error!.localizedDescription, nil)
            }
            
            _mapString = self.getMapPlacemarkAsString(withPlacemarks: placemarks, error: error) ?? self.metaNoData
            
            if self.appDelegate.inEditMode {
                _objectId = (self.appDelegate.currentUserStudentLocation?.objectId!)! as String
            }
            
            let currentStudentDict : NSDictionary =
                [
                    "objectId"  : _objectId!,
                    "uniqueKey" : _accountKey!,
                    "firstName" : self.inpFirstname.text! as String,
                    "lastName"  : self.inpLastname.text! as String,
                    "mediaURL"  : self.inpMediaURL.text! as String,
                    "latitude"  : _latitude! as Double,
                    "longitude" : _longitude! as Double,
                    "mapString" : _mapString! as String
                ]
            
            // handle firstName and lastName using capitalizing methods
            var meta: PRSStudentData = PRSStudentData(currentStudentDict)
                meta.firstName = self.inpFirstname.text!.capitalizingFirstLetter()
                meta.lastName = self.inpLastname.text!.capitalizingFirstLetter()
            
            completionHandlerForStudentMetaProfile(true, nil, meta)
        }
    }
    
    /*
     * tranlate current map coordinate based placemark to a human readable location string
     * try to render a compactAdress using my own CLPlacemark extension fallback (a) to city
     * name on any nil-return, fallback (b) return nil
     */
    private func getMapPlacemarkAsString(
        withPlacemarks placemarks: [CLPlacemark]?,
        error: Error?) -> String? {
        
        if let _error = error {
            
            if debugMode == true { print("problem to reverse ceocode location (\(_error))") }
            
        } else {
            
            if let placemarks = placemarks, let placemark = placemarks.first {
                
                return placemark.compactAdress ?? placemark.locality
            }
        }
        
        return nil
    }
}
