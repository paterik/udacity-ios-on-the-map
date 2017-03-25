//
//  PageSetViewController.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 25.03.17.
//  Copyright © 2017 Patrick Paechnatz. All rights reserved.
//

import UIKit

class PageSetViewController: UIViewController {
    
    //
    // MARK: Constants
    //
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let clientParse = PRSClient.sharedInstance
    let clientUdacity = UDCClient.sharedInstance
    let metaNoData: String = "no data"
    
    //
    // MARK: Variables
    //
    var delegate: PageSetViewControllerProtocol?
}
