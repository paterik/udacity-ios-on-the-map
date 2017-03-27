//
//  MapViewControllerExtension.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 09.03.17.
//  Copyright © 2017 Patrick Paechnatz. All rights reserved.
//

import UIKit
import MapKit

extension MapViewController: MKMapViewDelegate, CLLocationManagerDelegate {
    
    //
    // MARK: Class internal methods
    //
    
    /*
     * update a specific user location from map annotation panel directly (not used yet)
     */
    func userLocationUpdate(
       _ userLocation: PRSStudentData!) {
    
        self.clientParse.updateStudentLocation(userLocation) { (success, error) in
            
            if success == true {
                
                OperationQueue.main.addOperation { self.updateStudentLocations() }
                
            } else {
                
                // client error updating location? show corresponding message and return ...
                let Action = UIAlertAction(title: "OK", style: .default) { (action: UIAlertAction!) in return }
                let alertController = UIAlertController(
                    title: "Alert",
                    message: error,
                    preferredStyle: UIAlertControllerStyle.alert
                )
                
                alertController.addAction(Action)
                OperationQueue.main.addOperation {
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    /*
     * delete a specific userLocation from parse api persitence layer
     */
    func userLocationDelete(
       _ userLocation: PRSStudentData!) {
        
        self.clientParse.deleteStudentLocation (userLocation) { (success, error) in
            
            if success == true {
                
                OperationQueue.main.addOperation { self.updateStudentLocations() }
                
            } else {
                
                // client error deleting location? show corresponding message and return ...
                let Action = UIAlertAction(title: "OK", style: .default) { (action: UIAlertAction!) in return }
                let alertController = UIAlertController(
                    title: "Alert",
                    message: error,
                    preferredStyle: UIAlertControllerStyle.alert
                )
                
                alertController.addAction(Action)
                OperationQueue.main.addOperation {
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    /*
     * this method will delete all userLocations (studenLocations) from parse api persitence layer
     */
    func userLocationDeleteAll() {
        
        for location in clientParse.students.myLocations {
            self.userLocationDelete(location)
        }
    }
    
    /*
     * this method will add a new userLocation to our parse api persistence layer
     */
    func userLocationAdd(_ editMode: Bool) {
        
        appDelegate.inEditMode = editMode
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "PageSetRoot") as! LocationEditViewController
        let locationRequestController = UIAlertController(
            title: "Let's start ...",
            message: "Do you want to use your current device location as default for your next steps?",
            preferredStyle: UIAlertControllerStyle.alert
        )
        
        vc.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        vc.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        vc.editMode = editMode
        
        let dlgBtnYesAction = UIAlertAction(title: "Yes", style: .default) { (action: UIAlertAction!) in
            // check device location again ...
            self.locationFetchStart()
            // useCurrentDeviceLocation: true means our pageViewController will use a smaller stack of pageSetControllers
            self.appDelegate.useCurrentDeviceLocation = true
            // check if last location doesn't match the current one ...
            if self.validateCurrentLocationAgainstLastPersistedOne() == false {
                
                let locationDuplicateWarningController = UIAlertController(
                    title: "Duplication Warning ...",
                    message: "Your current device location is already in use by one of your previous locations!\n" +
                    "You can ignore this but you'll add a location duplicate doing this!",
                    preferredStyle: UIAlertControllerStyle.alert
                )
                
                let dlgBtnIgnoreWarningAction = UIAlertAction(title: "Ignore", style: .default) { (action: UIAlertAction!) in
                    self.present(vc, animated: true, completion: nil)
                }
                
                let dlgBtnCancelAction = UIAlertAction(title: "Cancel", style: .default) { (action: UIAlertAction!) in
                    return
                }
                
                locationDuplicateWarningController.addAction(dlgBtnIgnoreWarningAction)
                locationDuplicateWarningController.addAction(dlgBtnCancelAction)
                
                self.present(locationDuplicateWarningController, animated: true, completion: nil)
            
            } else {
                
                self.present(vc, animated: true, completion: nil)
            }
        }
        
        let dlgBtnNoAction = UIAlertAction(title: "No", style: .default) { (action: UIAlertAction!) in
            
            // useCurrentDeviceLocation: false means our pageViewController will use the full stack of pageSetControllers
            self.appDelegate.useCurrentDeviceLocation = false
            self.present(vc, animated: true, completion: nil)
        }
        
        locationRequestController.addAction(dlgBtnYesAction)
        locationRequestController.addAction(dlgBtnNoAction)
        
        present(locationRequestController, animated: true, completion: nil)
    }

    /*
     * this method will handle the 3 cases of user location persitence/validations
     */
    func handleUserLocation() {
        
        let dlgBtnCancelAction = UIAlertAction(title: "Cancel", style: .default) { (action: UIAlertAction!) in
            return }
        
        let dlgBtnDeleteAction = UIAlertAction(title: "Delete", style: .default) { (action: UIAlertAction!) in
            self.userLocationDeleteAll() }
        
        let dlgBtnAddLocationAction = UIAlertAction(title: "Add", style: .default) { (action: UIAlertAction!) in
            self.userLocationAdd( false ) }
        
        let dlgBtnUpdateAction = UIAlertAction(title: "Update", style: .default) { (action: UIAlertAction!) in
            self.userLocationAdd( true ) }
        
        let alertController = UIAlertController(title: "Warning", message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(dlgBtnDeleteAction)
        alertController.message = "You've already set your student location, do you want to delete or update the last one?"
        if self.clientParse.metaMyLocationsCount! > 1 {
            alertController.message = NSString(
                format: "You've already set your student location, do you want to delete the %d old locations?",
                self.clientParse.metaMyLocationsCount!) as String!
        }
        
        switch true {
            
            // no locations found, load addLocation formular
            case self.clientParse.metaMyLocationsCount! == 0: self.userLocationAdd( false ); break
            // moultiple locations found, let user choose between delete all or update the last persited location
            case self.clientParse.metaMyLocationsCount! > 0:
            
                alertController.addAction(dlgBtnAddLocationAction)
                alertController.addAction(dlgBtnUpdateAction)
                alertController.addAction(dlgBtnCancelAction)
            
                self.appDelegate.currentUserStudentLocation = self.clientParse.students.myLocations.last
                
                OperationQueue.main.addOperation { self.present(alertController, animated: true, completion: nil) }
            
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
        
        // deactivate and remove activity spinner
        self.activitySpinner.stopAnimating()
        self.view.willRemoveSubview(self.activitySpinner)
        
        clientParse.getAllStudentLocations () { (success, error) in
            
            if success == true {
                
                self.generateMapAnnotationsArray()
                
            } else {
                
                // error? do something ... but for now just clean up the alert dialog
                let Action = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in }
                let alertController = UIAlertController(
                    title: "Alert",
                    message: error,
                    preferredStyle: UIAlertControllerStyle.alert
                )
                
                alertController.addAction(Action)
                OperationQueue.main.addOperation { self.present(alertController, animated: true, completion:nil) }
            }
            
            // deactivate and remove activity spinner
            self.activitySpinner.stopAnimating()
            self.view.willRemoveSubview(self.activitySpinner)
        }
    }
    
    /*
     * generate the student meta based map annoation array and render results by async queue transfer to mapView directly
     */
    func generateMapAnnotationsArray () {
        
        let students = PRSStudentLocations.sharedInstance
        
        var renderDistance: Bool = false
        var sourceLocation: CLLocation?
        var targetLocation: CLLocation?
        var currentDeviceLocation: DeviceLocation?
        
        // remove all old annotations
        annotations.removeAll()
        
        // render distance to other students only if device location meta data available
        if appDelegate.currentDeviceLocations.count > 0 {
            currentDeviceLocation = appDelegate.currentDeviceLocations.first
            sourceLocation = CLLocation(
                latitude: (currentDeviceLocation?.latitude)!,
                longitude: (currentDeviceLocation?.longitude)!
            )
            
            renderDistance = true
        }
        
        for dictionary in students.locations {
            
            let coordinate = CLLocationCoordinate2D(latitude: dictionary.latitude!, longitude: dictionary.longitude!)
            let annotation = PRSStudentMapAnnotation(coordinate)
            
            annotation.url = dictionary.mediaURL ?? locationNoData
            annotation.subtitle = annotation.url ?? locationNoData
            annotation.title = NSString(
                format: "%@ %@",
                dictionary.firstName ?? locationNoData,
                dictionary.lastName ?? locationNoData) as String
            
            if renderDistance {
                targetLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                annotation.distance = getPrintableDistanceBetween(sourceLocation, targetLocation)
            }
            
            if dictionary.uniqueKey == clientParse.clientUdacity.clientSession?.accountKey! {
                annotation.ownLocation = true
            }
            
            annotations.append(annotation)
        }
        
        DispatchQueue.main.async { self.mapView.addAnnotations(self.annotations) }
    }
    
    /*
     * get the printable (human readable) distance between two locations (using fix metric system)
     */
    func getPrintableDistanceBetween(
       _ sourceLocation: CLLocation!,
       _ targetLocation: CLLocation!) -> String {
        
        let distanceValue = sourceLocation.distance(from: targetLocation)
        
        // todo(!) should be handle by localization manager instead using static metric definition
        var distanceOut: String! = NSString(format: "%.0f %@", distanceValue, "m") as String
        if distanceValue >= locationDistanceDivider {
            distanceOut = NSString(format: "%.0f %@", (distanceValue / locationDistanceDivider), "km") as String
        }
        
        return distanceOut
    }
    
    /*
     * check current device location against the last persisted studentLocation meta information.
     * If both locations seems to be plausible equal this validation method will be returned false.
     * For accuracy reasons I'll round the coordinates down to 6 decimal places (:locationCoordRound)
     */
    func validateCurrentLocationAgainstLastPersistedOne() -> Bool {
        
        let lastDeviceLocation = appDelegate.currentDeviceLocations.last
        let lastStudentLocation = clientParse.students.myLocations.last
        
        // no local studen location for my account found? fine ...
        if lastStudentLocation == nil {
            return true
        }
        
        let _lastDeviceLongitude: Double = lastDeviceLocation!.longitude!.roundTo(locationCoordRound)
        let _lastDeviceLatitude: Double = lastDeviceLocation!.latitude!.roundTo(locationCoordRound)
        let _lastUserStudentLongitude: Double = lastStudentLocation!.longitude!.roundTo(locationCoordRound)
        let _lastUserStudentLatitude: Double = lastStudentLocation!.latitude!.roundTo(locationCoordRound)
        
        if _lastDeviceLongitude == _lastUserStudentLongitude &&
           _lastDeviceLatitude  == _lastUserStudentLatitude {
            
            return false
        }
        
        return true
    }
    
    /*
     * update location meta information and (re)positioning current mapView
     */
    func updateCurrentLocationMeta(
       _ coordinate: CLLocationCoordinate2D) {
        
        let center = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let currentDeviceLocation : NSDictionary = [ "latitude": coordinate.latitude, "longitude": coordinate.longitude ]
        let region = MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: locationMapZoom, longitudeDelta: locationMapZoom)
        )
        
        appDelegate.currentDeviceLocations.removeAll() // currently we won't persist all evaluated device locations
        appDelegate.currentDeviceLocations.append(DeviceLocation(currentDeviceLocation)) // persist device location
        appDelegate.useCurrentDeviceLocation = true
        appDelegate.useLongitude = coordinate.longitude
        appDelegate.useLatitude = coordinate.latitude
        
        locationFetchSuccess = true
        
        mapView.setRegion(region, animated: true)
        
        if debugMode == true {
            print("-------------------------------------------------------------")
            print("You are at [\(coordinate.latitude)] [\(coordinate.longitude)]")
            print("-------------------------------------------------------------")
        }
    }
    
    /*
     * start location scan
     */
    func locationFetchStart() {
        
        deviceLocationManager.checkForLocationAccess {
            
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
                deviceLocationManager.doThisWhenAuthorized?()
                deviceLocationManager.doThisWhenAuthorized = nil
            
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
            
                // ignore first attempt
                if locationFetchStartTime == nil {
                    
                    locationFetchStartTime = Date()
                    
                    return
                }
            
                // ignore overtime requests
                if _determinationTime.timeIntervalSince(self.locationFetchStartTime) > locationCheckTimeout {
                    
                    locationFetchStop()
                
                    return
                }
                
                // wait for the next one
                if _accuracy < 0 || _accuracy > locationAccuracy { return }
            
                locationFetchStop()
            
                updateCurrentLocationMeta(_coordinate)
            
            case 2:
                
                updateCurrentLocationMeta(_coordinate)
            
            default: break
        }
    }
    
    func mapView(
       _ mapView: MKMapView,
         didUpdate userLocation: MKUserLocation) {
        
        updateCurrentLocationMeta(mapView.userLocation.coordinate)
    }
    
    func mapView(
       _ mapView: MKMapView,
         viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
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
        
        let studentAnnotation = view.annotation as! PRSStudentMapAnnotation
        let views = Bundle.main.loadNibNamed("StudentMapAnnotation", owner: nil, options: nil)
        let calloutView = views?[0] as! StudentMapAnnotation
        
        calloutView.center = CGPoint(x: view.bounds.size.width / 2, y: -calloutView.bounds.size.height * 0.65)
        calloutView.studentName.text = studentAnnotation.title
        calloutView.studentMediaURL.setTitle(studentAnnotation.url, for: .normal)
        if studentAnnotation.distance != nil {
            calloutView.studentDistance.text = studentAnnotation.distance
        }
        
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
