//
//  PageSetLocationViewController.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 13.03.17.
//  Copyright © 2017 Patrick Paechnatz. All rights reserved.
//

import UIKit
import MapKit

class PageSetLocationViewController: PageSetViewController, UITextFieldDelegate, CLLocationManagerDelegate {

    //
    // MARK: Constants
    //
    
    let debugMode: Bool = false
    let locationMapZoom : CLLocationDegrees = 0.03 // zoom factor (0.03 seems best for max zoom)
    
    //
    // MARK: Variables
    //
    
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
    
    //
    // MARK: Overrides
    //
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.showsUserLocation = false
        inpLocationMapString.delegate = self
        
        prepareStep(1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        activitySpinner.center = self.view.center
    }
    
    //
    // MARK: Delegate Methods
    //
    
    func textFieldShouldReturn(
       _ textField: UITextField) -> Bool {
        
        self.view.endEditing(true)
        
        return false
    }
    
    //
    // MARK: IBAction Methods
    //
    
    @IBAction func btnAcceptLocationAction(_ sender: Any) {
        
        if let del = delegate { del.handleDelegateCommand("scrollToNextViewController") }
    }
    
    @IBAction func btnHandleLocationSubmitAction(_ sender: Any) {
        
        // evaluate state and define title and action
        switch btnState {
            
            case 1:
            
                // perform step 1 action
                getMapPositionByAddressString(inpLocationMapString.text!)
            
                break
            
            case 2:
            
                // perform step 2 action
                updateMapLocationAnnotationAsConfirmed()
            
                break
            
            case 3:
            
                // perform step 3 action
                btnAcceptLocationAction(sender)
            
                break
            
            default:
            
                // leave view on any state below 1 or above 3
                btnCloseViewAction(sender)
            
                break
        }
    }

    @IBAction func btnCloseViewAction(_ sender: Any) {
        
        self.dismiss(animated: true)
    }
    
    /*
     * set map location to current device location
     */
    @IBAction func btnSetLocationToCurrentDeviceLocationAction(_ sender: Any) {
    
        
    }
    
    
    
    
}
