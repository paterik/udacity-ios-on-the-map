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

    @IBOutlet weak var btnCloseView: UIBarButtonItem!
    @IBOutlet weak var btnAcceptLocation: UIBarButtonItem!
    
    @IBAction func btnCloseViewAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func btnAcceptLocationAction(_ sender: Any) {
    
    }

}
