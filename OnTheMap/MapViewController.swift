//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 27.12.16.
//  Copyright © 2016 Patrick Paechnatz. All rights reserved.
//
import UIKit
import MapKit
import YNDropDownMenu

class MapViewController: BaseController, ControllerCommandProtocol {
    
    //
    // MARK: IBOutlet Variables
    //
    
    @IBOutlet weak var mapView: MKMapView!
    
    //
    // MARK: Constants (Statics)
    //
    
    static let sharedInstance = MapViewController()
    
    //
    // MARK: Constants (Special)
    //
    
    let appCommon = AppCommon.sharedInstance
    let appLocation = AppLocation.sharedInstance
    let students = PRSStudentLocations.sharedInstance
    
    //
    // MARK: Constants (Normal)
    //
    
    let locationMapZoom : CLLocationDegrees = 14.5       // zoom factor (0.03 seems best for max zoom, 14.5 for normal zoom)
    let locationNoData = "no meta data"                  // default for missing student meta data
    let locationAnnotationIdent = "StudentMapAnnotation" // map annotation xib identifier
    
    //
    // MARK: Variables
    //
    
    var annotations = [PRSStudentMapAnnotation]()
    var activitySpinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    //
    // MARK: UIView Methods (overrides)
    //
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        appDelegate.forceQueueExit = false
        
        activitySpinner.center = self.view.center
        if appDelegate.forceMapReload == true {
            appDelegate.forceMapReload = false
           _callReloadMapAction()
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        
       _callReloadMapAction()
        
        initMenu()
    }
}
