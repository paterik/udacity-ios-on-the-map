//
//  LocationEditViewControllerExtension.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 22.03.17.
//  Copyright © 2017 Patrick Paechnatz. All rights reserved.
//


import UIKit
import MapKit

extension LocationEditViewController: MKMapViewDelegate {

    /*
     * get map location by parametric location string
     */
    func getMapPositionByAddressString (
        _ address: String) {
        
        activitySpinner.startAnimating()
        view.addSubview(activitySpinner)
        
        let _geocoder = CLGeocoder()
        
        if debugMode == true {
            print ("-------------------------------------------------------------------")
            print ("try to find: \(address)")
            print ("-------------------------------------------------------------------")
        }
        
        _geocoder.geocodeAddressString(
            address,
            completionHandler: {(placemarks, error) -> Void in
                
                if error != nil {
                    
                    self.activitySpinner.stopAnimating()
                    self.view.willRemoveSubview(self.activitySpinner)
                    
                    let alertController = UIAlertController(
                        title: "Alert",
                        message: "Up's, I'm unable to find your defined location '\(address)' ... try another one!",
                        preferredStyle: UIAlertControllerStyle.alert
                    )
                    
                    let Action = UIAlertAction(title: "Try again", style: .default) { (action:UIAlertAction!) in return }
                        alertController.addAction(Action)
                    
                    OperationQueue.main.addOperation { self.present(alertController, animated: true, completion:nil)}
                }
                
                if let placemark = placemarks?.first {
                    
                    let coordinate:CLLocationCoordinate2D = placemark.location!.coordinate
                    self.generateMapLocationByCoordinates(coordinate)
                }
            }
        )
    }
    
    /*
     * set mapView to parametric location coordinates
     */
    func generateMapLocationByCoordinates(
        _ coordinate: CLLocationCoordinate2D) {
        
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude),
            span: MKCoordinateSpan(latitudeDelta: locationMapZoom, longitudeDelta: locationMapZoom)
        )
        
        mapView.setRegion(region, animated: true)
        DispatchQueue.main.async { self.mapView.addAnnotation(PRSStudentMapAnnotation(coordinate)) }
        
        activitySpinner.stopAnimating()
        view.willRemoveSubview(activitySpinner)
        
        // prepare ui for step 2
        self.prepareStep(2)
    }
    
    /*
     * update temporary user location icon by a "solid" one
     */
    func updateMapLocationAnnotationAsConfirmed() {
        
        for annotation in mapView.annotations {
            let annotationView = mapView.view(for: annotation)
            
            if annotationView?.annotation is PRSStudentMapAnnotation {
                annotationView?.image = UIImage(named: "icnUserDefault_v1")
            }
        }
        
        // prepare ui for step 2
        prepareStep(3)
    }
    
    /*
     * simple ui element modifier for our corresponding steps (1-3)
     */
    func prepareStep(_ step: Int8) {
        
        switch step {
            
            case 1:
            
                inpLocationMapString.resignFirstResponder()
                btnSubmit.setTitle("Plot Location", for: .normal)
                btnState = 1
            
                break
            
            case 2:
            
            
                btnAcceptLocation.isEnabled = true
                inpLocationMapString.isEnabled = false
                btnSubmit.setTitle("Confirm Location", for: .normal)
                btnState = 2
            
                break
            
            case 3:
            
                btnAcceptLocation.isEnabled = true
                inpLocationMapString.isEnabled = false
                btnSubmit.setTitle("Set Your Profile", for: .normal)
                btnState = 3
            
                break
            
            default: break
        }
    }
    
    //
    // MARK: Delegates
    //
    
    func mapView(
        _ mapView: MKMapView,
        viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        // ignore all given location annotation except the student ones
        if !(annotation is PRSStudentMapAnnotation) {
            return nil
        }
        
        let identifier = "locPin_0"
        var annotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            
            annotationView = StudentMapAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = false
            
        } else {
            
            annotationView?.annotation = annotation
            
        }
        
        annotationView?.image = UIImage(named: "icnUserTemp_v1")
        
        return annotationView
    }
}
