//
//  BaseController.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 03.04.17.
//  Copyright © 2017 Patrick Paechnatz. All rights reserved.
//

import UIKit
import MapKit
import YNDropDownMenu

class BaseController: UIViewController {

    //
    // MARK: Constants (Normal)
    //
    
    let debugMode: Bool = false
    let clientParse = PRSClient.sharedInstance
    let clientUdacity = UDCClient.sharedInstance
    let clientFacebook = FBClient.sharedInstance
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let metaDateTimeFormat = "dd.MM.Y hh:mm"
    
    //
    // MARK: Variables
    //
    var appMenu: YNDropDownMenu?
}
