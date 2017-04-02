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

    //
    // MARKS: Outlets
    //
    
    @IBOutlet weak var inpUdacityUser: UITextField!
    @IBOutlet weak var inpUdacityPassword: UITextField!
    @IBOutlet weak var btnLoginUdactiy: UIButton!
    @IBOutlet weak var btnLoginFacebook: UIButton!
    @IBOutlet weak var btnCreateUdacityAccount: UIButton!
    @IBOutlet weak var btnForgotUdacityPassword: UIButton!
    
    //
    // MARKS: Constants
    //
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let clientUdacity = UDCClient.sharedInstance
    let clientFacebook = FBClient.sharedInstance
    let locationTabViewIndentifier = "LocationTabViewController"
    
    //
    // MARKS: Variables
    //
    
    var activitySpinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activitySpinner.center = self.view.center
    }
    
    @IBAction func createUdacityAccountAction(_ sender: AnyObject) {
        
        // show redirect message dialog for creating new udacity account
        showRedirectMessage(
            "You have no udacity account yet? No Problem, create a new account right now ...",
            "https://auth.udacity.com/sign-up?next=https%3A%2F%2Fclassroom.udacity.com%2Fauthenticated"
        )
    }
    
    @IBAction func forgotUdacityPasswordAction(_ sender: AnyObject) {
        
        // show redirect message dialog for credential lost of your udactiy account
        showRedirectMessage(
            "You've lost your password? No problem, accept this redirect to your udacity login page and click the forgot password link",
            "https://auth.udacity.com/sign-in?next=https%3A%2F%2Fclassroom.udacity.com%2Fauthenticated"
        )
    }
    
    /*
     * handle login / session persistence using udacity normal auth
     */
    @IBAction func loginUdacityAction(_ sender: AnyObject) {
        
        activateUI(false)
        
        validateUsernameAndPassword() {
        
            (success, message, username, password) in
            
            if success == true {
        
                self.clientUdacity.getUserSessionToken(username, password, nil) {
                    
                    (udcSession, error) in
                    
                    if error == nil {
                        
                        // cleanOut username and password after login done successfully
                        OperationQueue.main.addOperation {
                            
                            self.inpUdacityUser.text = ""
                            self.inpUdacityPassword.text = ""
                            
                            self.appDelegate.isAuthByUdacity = true
                            self.appDelegate.isAuthByFacebook = false
                            self.appDelegate.setUdacitySession(udcSession!)
                            self.clientUdacity.clientSession = self.appDelegate.getUdacitySession()
                            
                            self.loadLocationViewController()
                        }
                        
                    } else {
                        
                        self.showErrorMessage(error!)
                    }
                }
                
            } else {
            
                self.showErrorMessage(message!)
            }
        }
    }
    
    /*
     * handle login / session persistence using facebook auth
     */
    @IBAction func loginFacebookAction(_ sender: AnyObject) {
        
        activateUI(false)

        clientFacebook.getUserSessionToken (viewController: self) { (success: Bool?, fbSession: FBSession?, message: String?) in
            
            if success! == true {
                
                self.appDelegate.isAuthByFacebook = true
                self.appDelegate.isAuthByUdacity = false
                self.appDelegate.setFacebookSession(fbSession!)
                self.clientFacebook.clientSession = self.appDelegate.getFacebookSession()
                
                let fbSessionToken = self.clientFacebook.clientSession?.tokenString!
                
                self.clientUdacity.getUserSessionToken(nil, nil, fbSessionToken) {
                    
                    (udcSession, error) in
                
                    if error == nil {
                    
                        OperationQueue.main.addOperation {
                            self.appDelegate.setUdacitySession(udcSession!)
                            self.clientUdacity.clientSession = self.appDelegate.getUdacitySession()
                            self.loadLocationViewController()
                        }
                        
                    } else {
                        
                        self.showErrorMessage(error!)
                    }
                }
                
            } else {
                
                self.showErrorMessage(message!)
            }
        }
    }
    
    /*
     * load primary controller for handling studen locations after login
     */
    private func loadLocationViewController() {
    
        activateUI(true)
        
        let locationViewController = self.storyboard!.instantiateViewController(
            withIdentifier: locationTabViewIndentifier) as! LocationTabViewController
        
        locationViewController.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        
        self.present(locationViewController, animated: true, completion: nil)
    }
}
