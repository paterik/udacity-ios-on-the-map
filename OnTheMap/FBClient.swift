//
//  FBClient.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 29.11.16.
//  Copyright © 2016 Patrick Paechnatz. All rights reserved.
//  
//  not really a client - may be more like a login client logic helper class
//

import Foundation
import FBSDKCoreKit
import FBSDKShareKit
import FBSDKLoginKit

class FBClient: NSObject {
    
    //
    // MARK: Constants (Static)
    //
    static let sharedInstance = FBClient()

    //
    // MARK: Constants (Normal)
    //
    let debugMode: Bool = true
    let dateFormatter = DateFormatter()
    let fbReqPermissions = ["public_profile", "email"]
    let fbGraphProperties = ["picture.type(large)", "email"]
    
    //
    // MARK: Variables
    //
    var clientSession: FBSession? = nil
    
    //* handle facebook graph request result and persist facebook session object inside app delegate */
    func getFacebookUserData(
         completionHandlerForGraph: @escaping (
       _ success: Bool,
       _ fbSession: FBSession?,
       _ message: String?) -> Void) {
        
        /* error 04: facebook token not available anymore */
        guard let currentFBAccessToken = FBSDKAccessToken.current() else {
            completionHandlerForGraph(false, nil, "Facebook token lost during graph api call!")
            return
        }
        
        FBSDKGraphRequest(
            graphPath: "me",
            parameters: ["fields": self.fbGraphProperties.joined(separator: ",")]
            ).start(completionHandler: { (connection, result, error) -> Void in
                
                if error != nil {
                    /* error 05: general exception/error during facebook graph call */
                    completionHandlerForGraph(false, nil, "\(error!.localizedDescription)")
                    return
                }
                
                guard let resultBlock = result as? [String: AnyObject],
                    let fbPictureBlock = resultBlock["picture"] as? [String: AnyObject],
                    let fbPictureDataBlock = fbPictureBlock["data"] as? [String: AnyObject],
                    let _fbPictureUrl = fbPictureDataBlock["url"] as? String,
                    let _fbEmail = resultBlock["email"] as? String else
                {
                    /* error 06: unable to parse json response object from facebook graph call */
                    completionHandlerForGraph(false, nil, "Unable to parse facebook user data!")
                    return
                }
                
                // will be normalized like PRSStudentData entity later!
                let fbSession = FBSession(
                    tokenString: currentFBAccessToken.tokenString!,
                    email: _fbEmail,
                    userID: currentFBAccessToken.userID!,
                    userImgUrl: _fbPictureUrl,
                    appID: currentFBAccessToken.appID!,
                    permissions: currentFBAccessToken.permissions,
                    expirationDate: currentFBAccessToken.expirationDate!,
                    refreshDate: currentFBAccessToken.refreshDate!,
                    created: Date()
                )
                
                /* everything went fine, save the facebook session token object using lambda function */
                completionHandlerForGraph(true, fbSession, "Facebook authentication successfully done!")
            }
        )
    }
    
    func removeUserSessionTokenAndLogOut(
         completionHandlerForLogOut: @escaping (
       _ success: Bool?,
       _ error: String?) -> Void) {
        
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        
        FBSDKAccessToken.setCurrent(nil)
        FBSDKProfile.setCurrent(nil)
        fbLoginManager.logOut()
        
        completionHandlerForLogOut(true, nil)
    }
    
    func getUserSessionToken(
         viewController: UIViewController!,
         completionHandlerForToken: @escaping (
       _ success: Bool,
       _ fbSession: FBSession?,
       _ message: String?) -> Void) {

        /* check if auth token still valid and return otherwise refresh FB Login */
        if FBSDKAccessToken.current() != nil {
        
            self.getFacebookUserData { (success: Bool?, fbSession: FBSession?, message: String?) in
                /* error 03: general exception/error during facebook graph call detected */
                if success == false {
                    completionHandlerForToken(false, nil, message)
                }
                
                /* authentication already done no 2nd login api call necessary, override result message for debugging/dev logs */
                completionHandlerForToken(true, fbSession, "Facebook authentication already done!")
            }
            
            return
        }
        
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
            fbLoginManager.logIn(withReadPermissions: self.fbReqPermissions, from: viewController) { (FBSDKLoginManagerLoginResult, error) in
                
            if error != nil {
                /* error 01: general exception/error during facebook login detected */
                completionHandlerForToken(false, nil, "\(String(describing: error?.localizedDescription))")
                return
                    
            } else if (FBSDKLoginManagerLoginResult?.isCancelled)! {
                /* error 02: authorization cancelled during facebook login */
                completionHandlerForToken(false, nil, "Facebook authorization process was cancelled!")
                return
                    
            }
                    
            self.getFacebookUserData { (success: Bool?, fbSession: FBSession?, message: String?) in
                /* error 03: general exception/error during facebook graph call detected */
                if success == false {
                    completionHandlerForToken(false, nil, message)
                    return
                }
                        
                /* everything went fine, save the facebook session token object using lambda result of previously graph call function */
                completionHandlerForToken(true, fbSession, message)
            }
        }
    }
}
