//
//  MapViewControllerExtension.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 09.03.17.
//  Copyright © 2017 Patrick Paechnatz. All rights reserved.
//

import UIKit
import MapKit
import Foundation

extension MapViewController: MKMapViewDelegate, CLLocationManagerDelegate {
    
    //
    // MARK: Class internal methods
    //
    
    /*
     * the method will handle our ident based viewController switch for editView UserProfile and UserLocation
     */
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
            
            default:
                break
        }
        
        vc.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        vc.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        
        return vc
    }
    
    /*
     * this method will add a new userLocation to our parse api persistence layer
     */
    func userLocationAdd() {
        
        let locationRequestController = UIAlertController(
            title: "Let's start ...",
            message: "Do you want to use your current device location as default for your next steps?",
            preferredStyle: UIAlertControllerStyle.alert
        )
        
        let dlgBtnYesAction = UIAlertAction(title: "Yes", style: .default) { (action: UIAlertAction!) in
            
            let vc = self.prepareVC("profileEditView") as! ProfileEditViewController
                vc.useCurrentDeviceLocation = true
            
            self.present(vc, animated: true, completion: nil)
        }
        
        let dlgBtnNoAction = UIAlertAction(title: "No", style: .default) { (action: UIAlertAction!) in
            
            let vc = self.prepareVC("locationEditView") as! LocationEditViewController
                vc.useCurrentDeviceLocation = false
            
            self.present(vc, animated: true, completion: nil)
        }
        
        locationRequestController.addAction(dlgBtnYesAction)
        locationRequestController.addAction(dlgBtnNoAction)
        
        present(locationRequestController, animated: true, completion: nil)
    }
    
    func userLocationUpdate() {}
    func userLocationDelete() {}
    
    /*
     * this method will handle the 3 cases of user location persitence/validations
     */
    func handleUserLocation() {
        
        let alertController = UIAlertController(
            title: "Info",
            message: "I've found valid student location(s) for your account",
            preferredStyle: UIAlertControllerStyle.alert
        )
        
        let dlgBtnCancelAction = UIAlertAction(title: "cancel", style: .default) { (action:UIAlertAction!) in }
        let dlgBtnDeleteAction = UIAlertAction(title: "delete", style: .default) { (action:UIAlertAction!) in
            self.userLocationDelete()
        }
        
        alertController.addAction(dlgBtnDeleteAction)
        alertController.addAction(dlgBtnCancelAction)
        
        switch true {
            
            // no locations found, load addLocation formular
            case self.clientParse.metaMyLocationsCount! == 0:
            
                self.userLocationAdd()

                break
            
            // exactly one location found, let user choose between delete or update this location
            case self.clientParse.metaMyLocationsCount! == 1:
            
                alertController.title = "Warning"
                alertController.message = "You've already set your student location, do you want to delete or update the last one?"
                let dlgBtnUpdateAction = UIAlertAction(title: "update", style: .default) { (action:UIAlertAction!) in
                
                    self.userLocationUpdate()
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
    }
    
    /*
     * simple wrapper for fetchAll student locations call, used during map initialization and by updateButton process call
     */
    func updateStudentLocations () {
        mapView.removeAnnotations(annotations)
        fetchAllStudentLocations()
    }
    
    /*
     * load all available student locations and handle api error result if parse call won't be succesfully
     */
    func fetchAllStudentLocations () {
        
       clientParse.getAllStudentLocations () { (success, error) in
            
            if success == true {
                
                self.generateMapAnnotationsArray()
                
            } else {
                
                // error? do something ... but for now just clean up the alert dialog
                let alertController = UIAlertController(title: "Alert", message: error, preferredStyle: UIAlertControllerStyle.alert)
                let Action = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in }
                
                alertController.addAction(Action)
                OperationQueue.main.addOperation {
                    self.present(alertController, animated: true, completion:nil)
                }
            }
        }
    }
    
    /*
     * generate the student meta based map annoation array and render results by async queue transfer to mapView directly
     */
    func generateMapAnnotationsArray () {
        
        let students = PRSStudentLocations.sharedInstance
        
        var renderDistance: Bool = false
        var currentDeviceLocation: MapViewLocation?
        var sourceLocation: CLLocation?
        var targetLocation: CLLocation?
        
        /* render distance to other students only if device location meta data available */
        if MapViewController.appDelegate.currentDeviceLocations.count > 0 {
            currentDeviceLocation = MapViewController.appDelegate.currentDeviceLocations.first
            sourceLocation = CLLocation(latitude: (currentDeviceLocation?.latitude)!, longitude: (currentDeviceLocation?.longitude)!)
            
            renderDistance = true
        }
        
        for dictionary in students.locations {
            
            let coordinate = CLLocationCoordinate2D(latitude: dictionary.latitude!, longitude: dictionary.longitude!)
            let annotation = PRSStudentMapAnnotation(coordinate)
            
            annotation.title = NSString(format: "%@ %@", dictionary.firstName, dictionary.lastName) as String
            annotation.url = dictionary.mediaURL
            annotation.subtitle = annotation.url
            
            if renderDistance {
                targetLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                annotation.subtitle = getPrintableDistanceBetween(sourceLocation, targetLocation)
            }
            
            annotations.append(annotation)
        }
        
        DispatchQueue.main.async {
            self.mapView.addAnnotations(self.annotations)
        }
    }
    
    /*
     * get the printable (human readable) distance between two locations (using metric system)
     */
    func getPrintableDistanceBetween(_ sourceLocation: CLLocation!, _ targetLocation: CLLocation!) -> String {
        
        let distanceValue = sourceLocation.distance(from: targetLocation)
        var distanceOut: String! = NSString(format: "%.0f %@", distanceValue, "m") as String
        
        if distanceValue >= locationDistanceDivider {
            distanceOut = NSString(format: "%.0f %@", (distanceValue / locationDistanceDivider), "km") as String
        }
        
        return distanceOut
    }
    
    /*
     * update location meta information and (re)positioning current mapView
     */
    func updateCurrentLocationMeta(
        _ coordinate: CLLocationCoordinate2D) {
        
        let center = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: locationMapZoom, longitudeDelta: locationMapZoom))
        let currentDeviceLocation : NSDictionary = [ "latitude": coordinate.latitude, "longitude": coordinate.longitude ]
        
        MapViewController.appDelegate.currentDeviceLocations.removeAll() // currently we won't persist all evaluated device locations
        MapViewController.appDelegate.currentDeviceLocations.append(MapViewLocation(currentDeviceLocation)) // persist evaluated device location
        locationFetchSuccess = true
        
        mapView.setRegion(region, animated: true)
        
        print("-------------------------------------------------------------")
        print("You are at [\(coordinate.latitude)] [\(coordinate.longitude)]")
        print(MapViewController.appDelegate.currentDeviceLocations)
        print("-------------------------------------------------------------")
    }
    
    /*
     * start location scan
     */
    func locationFetchStart() {
        
        mapViewLocationManager.checkForLocationAccess {
            
            switch self.locationFetchMode
            {
                case 1:
                
                    if self.locationFetchTrying { return }
                
                    self.locationFetchTrying = true
                    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
                    self.locationManager.activityType = .fitness
                    self.locationFetchStartTime = nil
                
                    self.locationManager.startUpdatingLocation()
                
                case 2:
                
                    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
                    self.locationManager.requestLocation()
                
                default: break
            }
        }
    }
    
    /*
     * stop location scan
     */
    func locationFetchStop () {
        
        locationManager.stopUpdatingLocation()
        locationFetchStartTime = nil
        locationFetchTrying = false
    }
    
    //
    // MARK: Delegates
    //
    
    /*
     * handle authorization change for location fetch permission using corresponding delegate call of locationManager
     */
    func locationManager(
        _ manager: CLLocationManager,
          didChangeAuthorization status: CLAuthorizationStatus) {
        
        if debugMode { print("locationManager: permission/authorization mode changed -> \(status.rawValue)") }
        
        switch status {
            case .authorizedAlways, .authorizedWhenInUse:
                mapViewLocationManager.doThisWhenAuthorized?()
                mapViewLocationManager.doThisWhenAuthorized = nil
            
            default: break
        }
    }
    
    /*
     * error handling of location fetch using corresponding delegate call of locationManager
     */
    func locationManager(
        _ manager: CLLocationManager,
          didFailWithError error: Error) {
        
        if debugMode { print("locationManager: localization request finally failed -> \(error)") }
        
        locationFetchSuccess = false
        locationFetchStop()
    }
    
    /*
     * fetch current device location using corresponding delegate call of locationManager
     */
    func locationManager(
        _ manager: CLLocationManager,
          didUpdateLocations locations: [CLLocation]) {
        
        let _location = locations.last!
        let _coordinate = _location.coordinate
        
        switch locationFetchMode
        {
            case 1:
            
                let _accuracy = _location.horizontalAccuracy
                let _determinationTime = _location.timestamp
            
                /* ignore first attempt */
                if locationFetchStartTime == nil {
                    
                    locationFetchStartTime = Date()
                    
                    return
                }
            
                /* ignore overtime requests */
                if _determinationTime.timeIntervalSince(self.locationFetchStartTime) > locationCheckTimeout {
                    
                    locationFetchStop()
                
                    return
                }
                
                /* wait for the next one */
                if _accuracy < 0 || _accuracy > locationAccuracy { return }
            
                locationFetchStop()
            
                updateCurrentLocationMeta(_coordinate)
            
            case 2:
                
                updateCurrentLocationMeta(_coordinate)
            
            default: break
        }
    }
    
    /*
     * update map position to current location
     */
    func mapView(
        _ mapView: MKMapView,
          didUpdate userLocation: MKUserLocation) {
        
        updateCurrentLocationMeta(mapView.userLocation.coordinate)
    }
    
    func mapView(
        _ mapView: MKMapView,
          viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        /* ignore all given location annotation except the student ones */
        if !(annotation is PRSStudentMapAnnotation) { return nil }
        
        let identifier = "locPin_0"
        var annotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            
            annotationView = StudentMapAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = false
            
        } else {
            
            annotationView?.annotation = annotation
            
        }
        
        annotationView?.image = UIImage(named: "icnUserDefault_v1")
        
        return annotationView
    }
    
    func mapView(
        _ mapView: MKMapView,
          didSelect view: MKAnnotationView) {
        
        if view.annotation is MKUserLocation { return }
        
        // let studentsAnnotation = view.annotation as! PRSStudentMapAnnotation
        let views = Bundle.main.loadNibNamed("StudentMapAnnotation", owner: nil, options: nil)
        let calloutView = views?[0] as! StudentMapAnnotation
        
        calloutView.center = CGPoint(x: view.bounds.size.width / 2, y: -calloutView.bounds.size.height * 0.65)
        
        view.addSubview(calloutView)
        
        mapView.setCenter((view.annotation?.coordinate)!, animated: true)
    }
    
    func mapView(
        _ mapView: MKMapView,
          didDeselect view: MKAnnotationView) {
        
        if view.isKind(of: StudentMapAnnotationView.self) {
            for subview in view.subviews {
                subview.removeFromSuperview()
            }
        }
    }
    
    /*
     * handle pin-click to open corresponding url inside the subtitle
     */
    func mapView(
        _ mapView: MKMapView,
          annotationView view: MKAnnotationView,
          calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.rightCalloutAccessoryView {
            
            let app = UIApplication.shared
            
            if var mediaURL = (view.annotation?.subtitle!)! as String? {
                
                if (mediaURL.hasPrefix("www")) {
                    mediaURL = NSString(format: "https://%@", mediaURL) as String
                }
                
                let nsURL = URL(string: mediaURL)!
                if app.canOpenURL(nsURL) {
                    app.open(nsURL, options: [:], completionHandler: nil)
                }
            }
        }
    }
}
