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
    
    //* handle facebook graph request result and persist facebook session object inside app delegate */
    func getFacebookUserData(completionHandlerForGraph: @escaping (_ success: Bool, _ fbSession: FBSession?, _ message: String?) -> Void) {
        
        guard let currentFBAccessToken = FBSDKAccessToken.current() else {
            return
        }
        
        FBSDKGraphRequest(
            graphPath: "me",
            parameters: ["fields": self.fbGraphProperties.joined(separator: ",")]
            ).start(completionHandler: { (connection, result, error) -> Void in
                
                if error != nil {
                    completionHandlerForGraph(false, nil, "\(error!.localizedDescription)")
                    return
                }
                
                guard let resultBlock = result as? [String: AnyObject],
                    let fbPictureBlock = resultBlock["picture"] as? [String: AnyObject],
                    let fbPictureDataBlock = fbPictureBlock["data"] as? [String: AnyObject],
                    let _fbPictureUrl = fbPictureDataBlock["url"] as? String,
                    let _fbEmail = resultBlock["email"] as? String else
                {
                    completionHandlerForGraph(false, nil, "Unable to parse facebook user data!")
                    return
                }
                
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
                
                completionHandlerForGraph(true, fbSession, "Facebook authentication successfully done!")
            }
        )
    }
    
    func getUserSessionToken(
        viewController: UIViewController!,
        completionHandlerForToken: @escaping (_ success: Bool, _ fbSession: FBSession?, _ message: String?) -> Void) {

        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        
        fbLoginManager.logIn(withReadPermissions: self.fbReqPermissions, from: viewController) { (FBSDKLoginManagerLoginResult, error) in
            
            if error != nil {
                completionHandlerForToken(false, nil, "\(error?.localizedDescription)")
            } else if (FBSDKLoginManagerLoginResult?.isCancelled)! {
                completionHandlerForToken(false, nil, "Facebook authorization process was cancelled!")
            } else {
                
                self.getFacebookUserData { (success: Bool?, fbSession: FBSession?, message: String?) in
                    
                    if success == false {
                        completionHandlerForToken(false, nil, message)
                        return
                    }
                    
                    completionHandlerForToken(true, fbSession, message)
                }
            }
        }
    }
}
