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

class MapViewController: UIViewController, ControllerCommandProtocol {
    
    //
    // MARK: IBOutlet variables
    //
    
    @IBOutlet weak var mapView: MKMapView!
    
    //
    // MARK: Constants (Statics)
    //
    
    static let sharedInstance = MapViewController()
    
    //
    // MARK: Constants (Normal)
    //
    
    let debugMode: Bool = false
    let clientParse = PRSClient.sharedInstance
    let clientUdacity = UDCClient.sharedInstance
    let deviceLocationManager = DeviceLocationManager.sharedInstance
    let students = PRSStudentLocations.sharedInstance
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let locationAccuracy : CLLocationAccuracy = 10 // accuracy factor for device location
    let locationCheckTimeout : TimeInterval = 10   // timeout for device location fetch
    let locationMapZoom : CLLocationDegrees = 0.03 // zoom factor (0.03 seems best for max zoom)
    let locationDistanceDivider : Double = 1000.0  // rate for metric conversion (m -> km)
    let locationDistanceHook : Double = 50         // minimum distance (measured in meters) before an update
    let locationFetchMode : Int8 = 1               // 1: saveMode, 2: quickMode
    let locationCoordRound : Int = 6               // round factor for coordinate comparison
    let locationNoData : String = "no meta data"   // default for missing student meta data
    
    //
    // MARK: Variables
    //
    
    var locationFetchTrying : Bool = false
    var locationFetchSuccess : Bool = false
    var locationFetchStartTime : Date!
    var locationManager : CLLocationManager { return self.deviceLocationManager.locationManager }
    var annotations = [PRSStudentMapAnnotation]()
    var activitySpinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    var appMenu: YNDropDownMenu?
    
    //
    // MARK: UIView Methods (overrides)
    //
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
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
        locationManager.delegate = self
       _callReloadMapAction()
        
        initMenu()
    }
}
