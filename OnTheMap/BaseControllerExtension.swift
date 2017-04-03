//
//  BaseControllerExtension.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 03.04.17.
//  Copyright © 2017 Patrick Paechnatz. All rights reserved.
//

import Foundation
import UIKit
import MapKit

extension BaseController {

    /*
     * logout facebook authenticated user
     */
    func _callLogOutFacebookAction() {
        
        clientFacebook.removeUserSessionTokenAndLogOut {
            
            (success, error) in
            
            if success == true {
                
                self._callLogOutSystemAction()
                
            } else {
                
                // client error updating location? show corresponding message and return ...
                let btnOkAction = UIAlertAction(title: "OK", style: .default) { (action: UIAlertAction!) in return }
                let alertController = UIAlertController(
                    title: "Alert",
                    message: error,
                    preferredStyle: UIAlertControllerStyle.alert
                )
                
                alertController.addAction(btnOkAction)
                OperationQueue.main.addOperation {
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    /*
     * logout udacity authenticated user
     */
    func _callLogOutUdacityAction() {
        
        clientUdacity.removeUserSessionTokenAndLogOut {
            
            (success, error) in
            
            if success == true {
                
                self._callLogOutSystemAction()
                
            } else {
                
                // client error updating location? show corresponding message and return ...
                let btnOkAction = UIAlertAction(title: "OK", style: .default) { (action: UIAlertAction!) in return }
                let alertController = UIAlertController(
                    title: "Alert",
                    message: error,
                    preferredStyle: UIAlertControllerStyle.alert
                )
                
                alertController.addAction(btnOkAction)
                OperationQueue.main.addOperation {
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    /*
     * (finalize) system logout, cleanUp all local persited session data
     */
    func _callLogOutSystemAction() {
        
        self.appDelegate.currentUserStudentLocation = nil
        self.clientFacebook.clientSession = nil
        self.clientUdacity.clientSession = nil
        
        self.dismiss( animated: true )
    }
    
    /*
     * handle logout user (delegatable) method call for udacity and fb sessions
     */
    func _callLogOutAction() {
        
        // kill all running background / asynch operations
        if debugMode { print (" <logout> cancel all operations") }
        OperationQueue.main.cancelAllOperations()
        appDelegate.forceQueueExit = true
        
        if appDelegate.isAuthByFacebook == true {
            
            if debugMode { print (" <logout> execute facebook logout") }
            _callLogOutFacebookAction()
            
        } else if appDelegate.isAuthByUdacity == true {
            
            if debugMode { print (" <logout> execute udacity logout") }
            _callLogOutUdacityAction()
            
        } else {
            
            if debugMode { print (" <logout> execute fallback system logout") }
            _callLogOutSystemAction()
            
        }
    }
}
