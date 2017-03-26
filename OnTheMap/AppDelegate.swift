//
//  AppDelegate.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 19.11.16.
//  Copyright © 2016 Patrick Paechnatz. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKShareKit
import FBSDKLoginKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    //
    // MARK: Variables for API SessionHandling
    //
    var facebookSession: FBSession? = nil
    var udacitySession: UDCSession? = nil
    var isAuthByUdacity: Bool = false
    var isAuthByFacebook: Bool = false
    var inEditMode: Bool = false
    var useCurrentDeviceLocation: Bool = false
    var useLongitude: Double?
    var useLatitude: Double?

    //
    // MARK: Variables for minor data "persitence" during app runtime
    //
    var currentDeviceLocations = [DeviceLocation]()
    var currentUserStudentLocation : PRSStudentData? = nil
    
    //
    // FIXME: refactoring of getter/setter functionally necessary !!!
    //
    func setUdacitySession(_ _udacitySession: UDCSession) {
        
        udacitySession = _udacitySession
    }

    func getUdacitySession() -> UDCSession {

        return udacitySession!
    }

    func setFacebookSession(_ _facebookSession: FBSession) {
        
        facebookSession = _facebookSession
    }

    func getFacebookSession() -> FBSession {

        return facebookSession!
    }

    //
    // MARK: FaceBookSDK overrides
    //
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
        FBSDKAppEvents.activateApp()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {

        FBSDKAppEvents.activateApp()
    }

    //
    // MARK: unused app delegates
    //
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

