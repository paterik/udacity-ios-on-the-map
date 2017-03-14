//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 27.12.16.
//  Copyright © 2016 Patrick Paechnatz. All rights reserved.
//
import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    //
    // MARK: Constants (Statics)
    //
    static let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //
    // MARK: Constants (Normal)
    //
    let debugMode: Bool = false
    let clientParse = PRSClient.sharedInstance
    let clientUdacity = UDCClient.sharedInstance
    let mapViewLocationManager = MapViewLocationManager.sharedInstance
    let students = PRSStudentLocations.sharedInstance
    
    let locationAccuracy : CLLocationAccuracy = 10 // accuracy factor for device location
    let locationCheckTimeout : TimeInterval = 10   // timeout for device location fetch
    let locationMapZoom : CLLocationDegrees = 0.03 // zoom factor (0.03 seems best for max zoom)
    let locationDistanceDivider : Double = 1000.0  // rate for metric conversion (m -> km)
    let locationFetchMode : Int8 = 1               // 1: saveMode, 2: quickMode
    
    //
    // MARKS: Variables
    //
    var locationFetchTrying : Bool = false
    var locationFetchSuccess : Bool = false
    var locationFetchStartTime : Date!
    var locationManager : CLLocationManager { return self.mapViewLocationManager.locationManager }
    var currentDeviceLocations = MapViewLocations.sharedInstance.currentDeviceLocations
    var activitySpinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    var annotations = [PRSStudentMapAnnotation]()
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        activitySpinner.center = self.view.center
        locationFetchStart()
        updateStudentLocations()
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        mapView.delegate = self
        mapView.showsUserLocation = true
        locationManager.delegate = self
    }
    
    func prepareVC(_ identifier: String) -> UIViewController {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        var vc: UIViewController!
        
        switch true {
            case identifier == "profileEditView":
                vc = storyBoard.instantiateViewController(withIdentifier: identifier) as! ProfileEditViewController
                
            break
            
            case identifier == "locationEditView":
                vc = storyBoard.instantiateViewController(withIdentifier: identifier) as! LocationEditViewController
            
            break
            
            default: break
        }
        
        vc.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        vc.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        
        return vc
    }
    
    @IBAction func btnAddUserLocationAction(_ sender: Any) {
        
        let locationRequestController = UIAlertController(
            title: "Let's start ...",
            message: "Do you want to use your current device location as default for your next steps?",
            preferredStyle: UIAlertControllerStyle.alert
        )
        
        let dlgBtnYesAction = UIAlertAction(title: "Yes", style: .default) { (action: UIAlertAction!) in
        
            let vc = self.prepareVC("profileEditView") as! ProfileEditViewController
            self.present(vc, animated: true, completion: nil)
        }
        
        let dlgBtnNoAction = UIAlertAction(title: "No", style: .default) { (action: UIAlertAction!) in
            
            let vc = self.prepareVC("locationEditView") as! LocationEditViewController
            self.present(vc, animated: true, completion: nil)
        }
        
        locationRequestController.addAction(dlgBtnYesAction)
        locationRequestController.addAction(dlgBtnNoAction)
        
        present(locationRequestController, animated: true, completion:nil)
    }
    
    func handleUserLocation() {
        
        clientParse.getStudentLocations() { (success, error) in
            
            if success == true {
                
                let alertController = UIAlertController(
                    title: "Info",
                    message: "I've found valid student location(s) for your account",
                    preferredStyle: UIAlertControllerStyle.alert
                )
                
                let dlgBtnDeleteAction = UIAlertAction(title: "delete", style: .default) { (action:UIAlertAction!) in
                    print ("delete pressed")
                }
                
                let dlgBtnCancelAction = UIAlertAction(title: "cancel", style: .default) { (action:UIAlertAction!) in
                    print ("cancel pressed")
                }
                
                alertController.addAction(dlgBtnDeleteAction)
                alertController.addAction(dlgBtnCancelAction)
                
                switch true
                {
                // no locations found, load addLocation formular
                case self.clientParse.metaMyLocationsCount! == 0:
                    
                    print("success!!!")
                    break
                    
                // exactly one location found, let user choose between delete or update this location
                case self.clientParse.metaMyLocationsCount! == 1:
                    
                    alertController.title = "Warning"
                    alertController.message = "You've already set your student location, do you want to delete or update the last one?"
                    let dlgBtnUpdateAction = UIAlertAction(title: "UPDATE", style: .default) { (action:UIAlertAction!) in
                        print ("update pressed")
                    }
                    
                    alertController.addAction(dlgBtnUpdateAction)
                    
                    OperationQueue.main.addOperation {
                        self.present(alertController, animated: true, completion:nil)
                    }
                    
                    break
                    
                // more than one location found, let user choos betwwen delete all old ones
                case self.clientParse.metaMyLocationsCount! > 1:
                    
                    alertController.title = "Warning"
                    alertController.message = NSString(
                        format: "You've already set your student location, do you want to delete the %d old ones?",
                        self.clientParse.metaMyLocationsCount!) as String!
                    
                    OperationQueue.main.addOperation {
                        self.present(alertController, animated: true, completion:nil)
                    }
                    
                    break
                    
                default: break
                }
                
            } else {
                
                let alertController = UIAlertController(title: "Alert", message: error, preferredStyle: UIAlertControllerStyle.alert)
                let Action = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in }
                alertController.addAction(Action)
                OperationQueue.main.addOperation {
                    self.present(alertController, animated: true, completion:nil)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        if segue.identifier == "editLocation"{
            _ = segue.destination as! LocationEditViewController
            
            
        }
    }
}
