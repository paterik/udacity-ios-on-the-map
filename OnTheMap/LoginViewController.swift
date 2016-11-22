//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 19.11.16.
//  Copyright © 2016 Patrick Paechnatz. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var inpUdacityUser: UITextField!
    @IBOutlet weak var inpUdacityPassword: UITextField!
    @IBOutlet weak var btnLoginUdactiy: UIButton!
    @IBOutlet weak var btnLoginFacebook: UIButton!
    
    let UDCClientInstance = UDCClient.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func loginUdacityAction(_ sender: AnyObject) {
        
        activateUI(enabled: false)
        UDCClientInstance.username = inpUdacityUser.text!
        UDCClientInstance.password = inpUdacityPassword.text!
        UDCClientInstance.getSession { (success, errorMessage, sessionToken) in
            self.activateUI(enabled: true)
            // print("\(success), \(errorMessage), \(sessionToken)")
        }
    }
    
    @IBAction func loginFacebookAction(_ sender: AnyObject) {
        
    }
}

