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

    func activateUI(enabled: Bool) {
        
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
