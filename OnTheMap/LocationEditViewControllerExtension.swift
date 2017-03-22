//
//  LocationEditViewControllerExtension.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 22.03.17.
//  Copyright © 2017 Patrick Paechnatz. All rights reserved.
//


import UIKit
import MapKit

extension LocationEditViewController {

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
        btnSubmit.setTitle("Confirm Location", for: .normal)
        btnState = 2
        
        activitySpinner.stopAnimating()
        view.willRemoveSubview(activitySpinner)
    }
}
