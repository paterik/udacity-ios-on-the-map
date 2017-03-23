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
    let locationMapZoom : CLLocationDegrees = 0.03 // zoom factor (0.03 seems best for max zoom)
    
    //
    // MARK: Variables
    //
    var useCurrentDeviceLocation: Bool = false
    var btnState: Int = 1 // initial state of confirm button 1: Plot Location, 2: Submit Location
    var activitySpinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    //
    // MARK: IBOutlet Variables
    //
    @IBOutlet weak var btnCloseView: UIBarButtonItem!
    @IBOutlet weak var btnAcceptLocation: UIBarButtonItem!
    @IBOutlet weak var inpLocationMapString: UITextField!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        activitySpinner.center = self.view.center
        
        mapView.delegate = self
        mapView.showsUserLocation = false
    }
    
    //
    // MARK: IBOutlet Actions
    //
    @IBAction func btnHandleLocationSubmitAction(_ sender: Any) {
        
        btnSubmit.isEnabled = true
        inpLocationMapString.isEnabled = false
        btnAcceptLocation.isEnabled = false
        
        // evaluate state and define title and action
        switch btnState {
        
            case 1:
                btnSubmit.setTitle("Plot Location", for: .normal)
                inpLocationMapString.resignFirstResponder()
                getMapPositionByAddressString(inpLocationMapString.text!)
                break;
            
            case 2:
                btnAcceptLocation.isEnabled = true
                inpLocationMapString.isEnabled = false
                btnSubmit.setTitle("Confirm Location", for: .normal)
                updateMapLocationAnnotationAsConfirmed()
                
                break;
            
            default:
                btnSubmit.isEnabled = false
                btnCloseViewAction(sender)
                break;
        }
        
        // switch button state 1->2, 2->1
        btnState = (btnState == 1) ? 2 : 1
    }
    
    @IBAction func btnCloseViewAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func btnAcceptLocationAction(_ sender: Any) {}
    @IBAction func btnSetLocationToCurrentDeviceLocationAction(_ sender: Any) {}
}
