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
                // perform step 1 action
                getMapPositionByAddressString(inpLocationMapString.text!)

                btnState += 1
                
                break;
            
            case 2:
                
                btnAcceptLocation.isEnabled = true
                inpLocationMapString.isEnabled = false
                btnSubmit.setTitle("Confirm Location", for: .normal)
                // perform step 2 action
                updateMapLocationAnnotationAsConfirmed()

                btnState += 1
                
                break;
            
            case 3:
                
                btnAcceptLocation.isEnabled = true
                inpLocationMapString.isEnabled = false
                btnSubmit.setTitle("Set Your Profile", for: .normal)
                // perform stel 3 action
                btnAcceptLocationAction(sender)
                
                btnState += 1
                
                break;
            
            default:
                
                // leave view an any state below 1 or above 3
                btnSubmit.isEnabled = false
                btnCloseViewAction(sender)
                
                break;
        }
    }
    
    @IBAction func btnCloseViewAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func btnAcceptLocationAction(_ sender: Any) {
    
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        var vc: ProfileEditViewController!
        
        vc = storyBoard.instantiateViewController(withIdentifier: "profileEditView") as! ProfileEditViewController
        vc.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        vc.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        
        vc.useCurrentDeviceLocation = false
        vc.mapView = self.mapView
        
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func btnSetLocationToCurrentDeviceLocationAction(_ sender: Any) {}
}
