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
}
