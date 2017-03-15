//
//  LocationEditViewController.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 13.03.17.
//  Copyright © 2017 Patrick Paechnatz. All rights reserved.
//

import UIKit
import MapKit

class LocationEditViewController: UIViewController, EditViewProtocol {

    //
    // MARK: Constants
    //
    let debugMode: Bool = false
    let clientParse = PRSClient.sharedInstance
    let clientUdacity = UDCClient.sharedInstance
    
    //
    // MARK: Variables
    //
    var useCurrentDeviceLocation: Bool = false
    
    //
    // MARK: IBOutlet Variables
    //
    @IBOutlet weak var btnCloseView: UIBarButtonItem!
    @IBOutlet weak var btnAcceptLocation: UIBarButtonItem!
    
    //
    // MARK: IBOutlet Actions
    //
    @IBAction func btnCloseViewAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func btnAcceptLocationAction(_ sender: Any) {
    
    }
}
