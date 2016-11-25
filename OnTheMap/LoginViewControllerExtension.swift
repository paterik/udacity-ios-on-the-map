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
    
        // Create the subMenu controller (using alertViewController)
        let alertController = UIAlertController(
            title: "Login Failed",
            message: _message,
            preferredStyle: .alert)
        
        // Add Cancel action
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

        if !enabled {
            btnLoginUdactiy.alpha = 0.5
            btnLoginFacebook.alpha = 0.5
        }
    }
}
