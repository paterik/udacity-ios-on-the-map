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
    
    var dict : [String : AnyObject]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func createUdacityAccountAction(_ sender: AnyObject) {
        
        /* show redirect message dialog for create new udacity account */
        showRedirectMessage(
            "You have no udacity account yet? No Problem, create a new account right now ...",
            "https://auth.udacity.com/sign-up?next=https%3A%2F%2Fclassroom.udacity.com%2Fauthenticated"
        )
    }
    
    @IBAction func forgotUdacityPasswordAction(_ sender: AnyObject) {
        
        /* show redirect message dialog for lost credentials of udactiy account */
        showRedirectMessage(
            "You've lost your password? No problem, accept this redirect to your udacity login page and click the forgot password link",
            "https://auth.udacity.com/sign-in?next=https%3A%2F%2Fclassroom.udacity.com%2Fauthenticated"
        )
    }

    @IBAction func loginUdacityAction(_ sender: AnyObject) {
        /* deactivate ui during http rest call */
        activateUI(false)
        
        UDCClientInstance.username = inpUdacityUser.text!
        UDCClientInstance.password = inpUdacityPassword.text!
        UDCClientInstance.getUserSessionToken { (success: Bool?, udcSession: UDCSession?, message: String?) in
            
            if success! == true {
                /* persist udacity session model and provide it inside appDelegate globaly */
                self.appDelegate.isAuthByUdacity = true
                self.appDelegate.setUdacitySession(udcSession!)
            
            } else {
                self.showErrorMessage(message!)
            }
            
            /* (re)activate ui after http rest call result handling */
            self.activateUI(true)
        }
    }
    
    func getFBUserData() {
        
        if let currentFBAccessToken = FBSDKAccessToken.current() {
            
            FBSDKGraphRequest(graphPath: "me", parameters: [
                "fields": "id, picture.type(large), email"]).start(completionHandler: { (connection, result, error)
                    -> Void in
                    
                    if (error == nil) {
                        
                        let fbSession = FBSession(
                        
                            tokenString: currentFBAccessToken.tokenString!,
                            email: "foo@bar.baz",
                            userID: currentFBAccessToken.userID!,
                            userImgUrl: "test.jpg",
                            appID: currentFBAccessToken.appID!,
                            permissions: currentFBAccessToken.permissions,
                            expirationDate: currentFBAccessToken.expirationDate!,
                            refreshDate: currentFBAccessToken.refreshDate!,
                            created: Date()
                        )
                        
                        self.dict = result as! [String : AnyObject]
                        
                        /* persist udacity session model and provide it inside appDelegate globaly */
                        self.appDelegate.isAuthByFacebook = true
                        self.appDelegate.setFacebookSession(fbSession)
                        
                        print("\n\n================================================\n")
                        print(fbSession.tokenString)
                        print("\n==================================================\n\n")
                        
                    } else {
                        self.showErrorMessage(error!.localizedDescription)
                    }
                }
            )
        }
    }
    
    @IBAction func loginFacebookAction(_ sender: AnyObject) {
        
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                if fbloginresult.grantedPermissions != nil {
                    if(fbloginresult.grantedPermissions.contains("email"))
                    {
                        self.getFBUserData()
                        fbLoginManager.logOut()
                    }
                }
            } else {
                self.showErrorMessage((error?.localizedDescription)!)
            }
        }
    }
}
