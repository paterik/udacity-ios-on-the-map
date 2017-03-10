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
            
            if error == nil {
                
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
        
        let currentLocation = self.currentLocations.first
        let sourceLocation = CLLocation(latitude: (currentLocation?.latitude)!, longitude: (currentLocation?.longitude)!)
        
        for dictionary in students.locations {
            
            let coordinate = CLLocationCoordinate2D(latitude: dictionary.latitude, longitude: dictionary.longitude)
            let annotation = PRSStudentMapAnnotation(coordinate)
            
            let targetLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            
            annotation.title = NSString(format: "%@ %@", dictionary.firstName, dictionary.lastName) as String
            annotation.url = dictionary.mediaURL
            annotation.subtitle = getPrintableDistanceBetween(sourceLocation, targetLocation)
            annotation.image = dictionary.studentImage
            
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
        
        self.locationManager.stopUpdatingLocation()
        self.locationFetchStartTime = nil
        self.locationFetchTrying = false
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
                self.mapViewLocationManager.doThisWhenAuthorized?()
                self.mapViewLocationManager.doThisWhenAuthorized = nil
            
            default: break
        }
    }
    
    /*
     * error handling of location fetch using corresponding delegate call of locationManager
     */
    func locationManager(
        _ manager: CLLocationManager,
          didFailWithError error: Error) {
        
        if debugMode { print("locationManager: localization request finaly failed -> \(error)") }
        
        self.locationFetchStop()
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
                if self.locationFetchStartTime == nil {
                    self.locationFetchStartTime = Date()
                    
                    return
                }
            
                /* ignore overtime requests */
                if _determinationTime.timeIntervalSince(self.locationFetchStartTime) > locationCheckTimeout {
                    self.locationFetchStop()
                
                    return
                }
                
                /* wait for the next one */
                if _accuracy < 0 || _accuracy > locationAccuracy { return }
            
                self.locationFetchStop()
            
                updateCurrentLocationMeta(_coordinate)
            
            case 2:
                
                updateCurrentLocationMeta(_coordinate)
            
            default: break
        }
    }
    
    /*
     * update location meta information and (re)positioning current mapView
     */
    func updateCurrentLocationMeta(
        _ coordinate: CLLocationCoordinate2D) {
    
        let center = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: locationMapZoom, longitudeDelta: locationMapZoom))
        
        mapView.setRegion(region, animated: true)
        
        let currentLocation : NSDictionary = [ "latitude": coordinate.latitude, "longitude": coordinate.longitude ]
        self.currentLocations.removeAll() // currently we won't persist all evaluated device locations
        self.currentLocations.append(MapViewLocation(currentLocation))
        
        if debugMode { print("You are at [\(coordinate.latitude)] [\(coordinate.longitude)]") }
    }
    
    /*
     * update map position to current location
     */
    func mapView(
        _ mapView: MKMapView,
          didUpdate userLocation: MKUserLocation) {
        
        updateCurrentLocationMeta(self.mapView.userLocation.coordinate)
    }
    
    /*
     * render and setup a styled annotation pin within the current map
     */
    func mapView(
        _ mapView: MKMapView,
          viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        /* ignore all given location annotation except the student ones */
        if !(annotation is PRSStudentMapAnnotation){
            return nil
        }
        
        let identifier = "studentPin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView

        if pinView == nil {
            
            let linkButton = UIButton(type: .detailDisclosure)
                linkButton.tintColor = UIColor.black
            
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.red
            pinView!.rightCalloutAccessoryView = linkButton
            
        } else {
  
            pinView!.annotation = annotation
        }
        
        let studentAnnotation = annotation as! PRSStudentMapAnnotation
        pinView!.leftCalloutAccessoryView = UIImageView(image: studentAnnotation.image)
            
        return pinView
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
