//
//  LoginViewControllerExtension.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 22.11.16.
//  Copyright © 2016 Patrick Paechnatz. All rights reserved.
//

import Foundation
import UIKit

extension LoginViewController {

    /*
     * show error message inside loginViewController
     */
    func showErrorMessage(_ _message: String) {
    
        // Instantiate the alertController, using _message as parameter
        let alertController = UIAlertController(
            title: "Login Failed",
            message: _message,
            preferredStyle: .alert)
        
        // Add Cancel action
        alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.cancel) {
            UIAlertAction in return self.activateUI(true)
        })
        
        present(alertController, animated: true, completion: nil)
    }
    
    /*
     * show redirect message(s) inside loginViewController
     */
    func showRedirectMessage(_ _message: String, _ _link: String) {

        // Instantiate the alertController, using _message as parameter
        let alertController = UIAlertController(
            title: "udacity.com",
            message: _message,
            preferredStyle: .alert)
        
        let redirectAction = UIAlertAction(title: "Okay, let's go", style: UIAlertActionStyle.default) {
            UIAlertAction in
            
            UIApplication.shared.open(
                NSURL(string: _link)! as URL,
                options: [:],
                completionHandler: nil
            )
        }
        
        // Add Redirect Action
        alertController.addAction(redirectAction)
        
        // Add Cancel Action
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
            UIAlertAction in return
        })
        
        present(alertController, animated: true, completion: nil)
    }
    
    /*
     * check input fields for udacity login process and return error on any kind of problem
     */
    func validateUsernameAndPassword(completionHandlerFieldValidator: @escaping (
       _ success: Bool,
       _ message: String?,
       _ username: String?,
       _ password: String?)
        
        -> Void) {
        
        guard let _username = inpUdacityUser.text else {
            completionHandlerFieldValidator(false, "Oops! Missing username in your authentication request!", nil, nil)
            
            return
        }
        
        guard let _password = inpUdacityPassword.text else {
            completionHandlerFieldValidator(false, "Oops! Missing password in your authentication request!", nil, nil)
            
            return
        }
        
        if _password.isEmpty || _username.isEmpty {
            completionHandlerFieldValidator(false, "Oops! Missing field data for your authentication request!", nil, nil)
            
            return
        }
        
        completionHandlerFieldValidator(true, nil, _username, _password)
    }

    /*
     * handly ui behaviour
     */
    func activateUI(_ enabled: Bool) {
        
        
        inpUdacityUser.isEnabled = enabled
        inpUdacityPassword.isEnabled = enabled
        
        btnLoginUdactiy.alpha = 1.0
        btnLoginFacebook.alpha = 1.0
        
        // deactivate and remove activity spinner
        activitySpinner.stopAnimating()
        view.willRemoveSubview(self.activitySpinner)

        if !enabled {
            // show activity spinner
            activitySpinner.startAnimating()
            view.addSubview(activitySpinner)
            
            btnLoginUdactiy.alpha = 0.5
            btnLoginFacebook.alpha = 0.5
        }
    }
    
    /*
     * load primary controller for handling studen locations after login
     */
    func loadLocationViewController() {
        
        activateUI(true)
        
        let locationViewController = self.storyboard!.instantiateViewController(
            withIdentifier: locationTabViewIndentifier) as! LocationTabViewController
        
        locationViewController.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        
        self.present(locationViewController, animated: true, completion: nil)
    }
}
