//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 19.11.16.
//  Copyright © 2016 Patrick Paechnatz. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKShareKit
import FBSDKLoginKit

class LoginViewController: UIViewController {

    @IBOutlet weak var inpUdacityUser: UITextField!
    @IBOutlet weak var inpUdacityPassword: UITextField!
    @IBOutlet weak var btnLoginUdactiy: UIButton!
    @IBOutlet weak var btnLoginFacebook: UIButton!
    @IBOutlet weak var btnCreateUdacityAccount: UIButton!
    @IBOutlet weak var btnForgotUdacityPassword: UIButton!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let UDCClientInstance = UDCClient.sharedInstance
    let FBClientInstance = FBClient.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func createUdacityAccountAction(_ sender: AnyObject) {
        
        /* show redirect message dialog for creating new udacity account */
        showRedirectMessage(
            "You have no udacity account yet? No Problem, create a new account right now ...",
            "https://auth.udacity.com/sign-up?next=https%3A%2F%2Fclassroom.udacity.com%2Fauthenticated"
        )
    }
    
    @IBAction func forgotUdacityPasswordAction(_ sender: AnyObject) {
        
        /* show redirect message dialog for credential lost of your udactiy account */
        showRedirectMessage(
            "You've lost your password? No problem, accept this redirect to your udacity login page and click the forgot password link",
            "https://auth.udacity.com/sign-in?next=https%3A%2F%2Fclassroom.udacity.com%2Fauthenticated"
        )
    }

    @IBAction func loginUdacityAction(_ sender: AnyObject) {
        
        /* deactivate ui during http rest call */
        // activateUI(false)
        
        loadLocationViewController()
        
        // ----------------------------------------------------------------------------- override for fast development
        /* UDCClientInstance.getUserSessionToken(
            
            inpUdacityUser.text!,
            inpUdacityPassword.text!) { (udcSession, error) in
                
            if error == nil {
                    
                self.appDelegate.isAuthByUdacity = true
                self.appDelegate.setUdacitySession(udcSession!)
                self.loadLocationViewController()
                    
                // cleanOut username and password after login done successfully
                OperationQueue.main.addOperation {
                    self.inpUdacityUser.text = ""
                    self.inpUdacityPassword.text = ""
                }
                    
            } else {

                self.showErrorMessage(error!)
            }
                
            // (re)activate ui after http rest call result handling
            self.activateUI(true)
        } */
    }
    
    @IBAction func loginFacebookAction(_ sender: AnyObject) {
        
        /* deactivate ui during http rest call */
        activateUI(false)

        FBClientInstance.getUserSessionToken (viewController: self) { (success: Bool?, fbSession: FBSession?, message: String?) in

            if success! == true {
                
                /* persist udacity session model and provide it inside appDelegate globaly */
                self.appDelegate.isAuthByFacebook = true
                self.appDelegate.setFacebookSession(fbSession!)
                self.loadLocationViewController()

            } else {
                
                self.showErrorMessage(message!)
                
            }

            /* (re)activate ui after http rest call result handling */
            self.activateUI(true)
        }
    }
    
    private func loadLocationViewController() {
    
        let locationViewController = self.storyboard!.instantiateViewController(
            withIdentifier: "LocationViewController") as! LocationViewController
        
        locationViewController.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        
        self.present(locationViewController, animated: true, completion: nil)
    }
}
