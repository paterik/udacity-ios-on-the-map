//
//  MapViewControllerExtension.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 09.03.17.
//  Copyright © 2017 Patrick Paechnatz. All rights reserved.
//

import UIKit
import MapKit
import YNDropDownMenu

extension MapViewController: MKMapViewDelegate, CLLocationManagerDelegate {
    
    //
    // MARK: Class internal methods
    //
    
    /*
     * update a specific user location from map annotation panel directly (not used yet)
     */
    func userLocationUpdate(
       _ userLocation: PRSStudentData!) {
    
        self.clientParse.updateStudentLocation(userLocation) {
            
            (success, error) in
            
            if success == true {
                
                OperationQueue.main.addOperation { self.updateStudentLocations() }
                
            } else {
                
                // client error updating location? show corresponding message and return ...
                let btnOkAction = UIAlertAction(title: "OK", style: .default) { (action: UIAlertAction!) in return }
                let alertController = UIAlertController(
                    title: "Alert",
                    message: error,
                    preferredStyle: UIAlertControllerStyle.alert
                )
                
                alertController.addAction(btnOkAction)
                OperationQueue.main.addOperation {
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    /*
     * action wrapper for update userLocation using button click call from annotation directly
     * try to fetch object by given object id and set it as appDelegate.currentUserStudentLocation
     * after that call method userLocationAdd(_ editMode = true)
     */
    func userLocationEditProfileAction(
       _ sender: UIButton) {
    
        let objectId = sender.accessibilityHint
        
        if objectId != nil && objectId?.isEmpty == false {
            
            if let userLocation: PRSStudentData = getOwndedStudentLocationByObjectId(objectId!) {
                
                appDelegate.currentUserStudentLocation = userLocation
                userLocationAdd( true )
                
            } else {
                
                let locationNotFoundWarning = UIAlertController(
                    title: "Location Warning ...",
                    message: "Location with objectId \(String(describing: objectId)) not found!",
                    preferredStyle: UIAlertControllerStyle.alert
                )
                
                let dlgBtnCancelAction = UIAlertAction(title: "Cancel", style: .default) { (action: UIAlertAction!) in
                    return
                }
                
                locationNotFoundWarning.addAction(dlgBtnCancelAction)
                
                self.present(locationNotFoundWarning, animated: true, completion: nil)
            }
        }
    }
    
    /*
     * action wrapper for delete userLocation using button click call from annotation directly
     */
    func userLocationDeleteAction(
       _ sender: UIButton) {
        
        // using accessibilityHint "hack" to fetch a specific id (here objectId of parse.com)
        let objectId = sender.accessibilityHint
        
        if objectId != nil && objectId?.isEmpty == false {
        
            let locationDestructionWarning = UIAlertController(
                title: "Removal Warning ...",
                message: "Do you really want to delete this location?",
                preferredStyle: UIAlertControllerStyle.alert
            )
            
            let dlgBtnYesAction = UIAlertAction(title: "Yes", style: .default) { (action: UIAlertAction!) in
                // execute api call to delete user location object
                self.userLocationDelete( objectId! )
            }
            
            let dlgBtnCancelAction = UIAlertAction(title: "Cancel", style: .default) { (action: UIAlertAction!) in
                return
            }
            
            locationDestructionWarning.addAction(dlgBtnYesAction)
            locationDestructionWarning.addAction(dlgBtnCancelAction)
            
            self.present(locationDestructionWarning, animated: true, completion: nil)
        }
    }
    
    /*
     * delete a specific userLocation from parse api persitence layer
     */
    func userLocationDelete(
       _ userLocationObjectId: String!) {
        
        self.clientParse.deleteStudentLocation (userLocationObjectId) {
            
            (success, error) in
            
            if success == true {
                
                // remove object id from all corresponding collections
                self.clientParse.students.removeByObjectId( userLocationObjectId )
                
                // update locations stack *** not required if lists are cleared natively
                OperationQueue.main.addOperation { self.updateStudentLocations() }
                
            } else {
                
                // client error deleting location? show corresponding message and return ...
                let btnOkAction = UIAlertAction(title: "OK", style: .default) { (action: UIAlertAction!) in return }
                let alertController = UIAlertController(
                    title: "Alert",
                    message: error,
                    preferredStyle: UIAlertControllerStyle.alert
                )
                
                alertController.addAction(btnOkAction)
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
            self.userLocationDelete(location.objectId)
        }
    }
    
    /*
     * this method will add a new or update an existing userLocation from parse api persistence layer
     */
    func userLocationAdd(
       _ editMode: Bool) {
        
        appDelegate.inEditMode = editMode
        appDelegate.useCurrentDeviceLocation = false
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "PageSetRoot") as! LocationEditViewController
        let locationRequestController = UIAlertController(
            title: "Let's start ...",
            message: "Do you want to use your current device location as default for your next steps?",
            preferredStyle: UIAlertControllerStyle.alert
        )
        
        vc.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        vc.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        
        // show user choice dialog for device based location service/preFetch
        // if no device location allowed or provided, load manual loacation mode
        if appDelegate.currentDeviceLocations.count == 0 {
            
            present(vc, animated: true, completion: nil)
            
        } else {
            
            let dlgBtnYesAction = UIAlertAction(title: "Yes", style: .default) { (action: UIAlertAction!) in
                // check device location again ...
                self.appLocation.updateDeviceLocation()
                // useCurrentDeviceLocation: true means our pageViewController will use a smaller stack of pageSetControllers
                self.appDelegate.useCurrentDeviceLocation = true
                // check if last location doesn't match the current one ... if app in create mode only
                if editMode == false && self.validateCurrentLocationAgainstLastPersistedOne() == false {
                    
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
        
        clientParse.getAllStudentLocations () {
            
            (success, error) in
            
            if success == true {
                
                self.generateMapAnnotationsArray()
                
            } else {
                
                // error? do something ... but for now just clean up the alert dialog
                let btnOkAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in }
                let alertController = UIAlertController(
                    title: "Alert",
                    message: error,
                    preferredStyle: UIAlertControllerStyle.alert
                )
                
                alertController.addAction(btnOkAction)
                OperationQueue.main.addOperation { self.present(alertController, animated: true, completion:nil) }
            }
            
            // deactivate and remove activity spinner
            self.activitySpinner.stopAnimating()
            self.view.willRemoveSubview(self.activitySpinner)
        }
    }
    
    /*
     * generate the student meta based map annoation array, render results by async queue transfer to mapView directly
     * and manipulate/enrich the origin location by further (calculated) meta-data (currently the device distance to
     * other students)
     */
    func generateMapAnnotationsArray () {
        
        let students = PRSStudentLocations.sharedInstance
        
        var renderDistance: Bool = false
        var sourceLocation: CLLocation?
        var targetLocation: CLLocation?
        var currentDeviceLocation: DeviceLocation?
        
        // remove all old annotations
        annotations.removeAll()
        
        appLocation.updateDeviceLocation()
        
        // render distance to other students only if device location meta data available
        if appDelegate.currentDeviceLocations.count > 0 {
            currentDeviceLocation = appDelegate.currentDeviceLocations.first
            sourceLocation = CLLocation(
                latitude: (currentDeviceLocation?.latitude)!,
                longitude: (currentDeviceLocation?.longitude)!
            )
            
            renderDistance = true
        }
        
        for (index, dictionary) in students.locations.enumerated() {
            
            // ignore zero index location, this one will be replaced by my statistic
            // cell in listView and should not be rendered as map valid annotation
            if dictionary.isHidden == true { continue }
            
            let coordinate = CLLocationCoordinate2D(latitude: dictionary.latitude!, longitude: dictionary.longitude!)
            let annotation = PRSStudentMapAnnotation(coordinate)
            
            annotation.objectId = dictionary.objectId
            annotation.url = dictionary.mediaURL ?? locationNoData
            annotation.subtitle = annotation.url ?? locationNoData
            annotation.title = NSString(
                format: "%@ %@",
                dictionary.firstName,
                dictionary.lastName) as String
            
            if renderDistance == true {
                targetLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                annotation.distance = appCommon.getDistanceWithUnitBetween(sourceLocation, targetLocation)

                students.locations[index].distance = annotation.distance!
                students.locations[index].distanceValue = sourceLocation?.distance(from: targetLocation!) ?? 0.0
            }
            
            if dictionary.uniqueKey == clientParse.clientUdacity.clientSession?.accountKey! {
                annotation.ownLocation = true
            }
            
            annotations.append(annotation)
        }
        
        DispatchQueue.main.async { self.mapView.addAnnotations(self.annotations) }
    }
    
    /*
     * get a owned student location by their corresponding objectId
     */
    func getOwndedStudentLocationByObjectId(
       _ objectId: String) -> PRSStudentData? {
        
        for location in clientParse.students.myLocations {
            
            // ignore hidden locations
            if location.isHidden == true { continue }
            if location.objectId == objectId {
                return location
            }
        }
        
        return nil
    }
    
    /*
     * check current device location against the last persisted studentLocation meta information.
     * If both locations seems to be "plausible equal" this validation method will be returned false.
     * For accuracy reasons I'll round the coordinates down to 6 decimal places (:locationCoordRound)
     */
    func validateCurrentLocationAgainstLastPersistedOne() -> Bool {
        
        let lastDeviceLocation = appDelegate.currentDeviceLocations.last
        let lastStudentLocation = clientParse.students.myLocations.last
        
        // no local studen location for my account found? fine ...
        if lastStudentLocation == nil {
            return true
        }
        
        // no device location found? fine ...
        if lastDeviceLocation == nil {
            return true
        }
        
        let _lastDeviceLongitude: Double = lastDeviceLocation!.longitude!.roundTo(appLocation.locationCoordRound)
        let _lastDeviceLatitude: Double = lastDeviceLocation!.latitude!.roundTo(appLocation.locationCoordRound)
        let _lastUserStudentLongitude: Double = lastStudentLocation!.longitude!.roundTo(appLocation.locationCoordRound)
        let _lastUserStudentLatitude: Double = lastStudentLocation!.latitude!.roundTo(appLocation.locationCoordRound)
        
        if _lastDeviceLongitude == _lastUserStudentLongitude &&
           _lastDeviceLatitude  == _lastUserStudentLatitude {
            
            return false
        }
        
        return true
    }
    
    /*
     * handle add user location (delegatable) method call
     */
    func _callAddUserLocationAction() {
        
        clientParse.getMyStudentLocations() { (success, error) in
            
            if success == true {
                
                self.handleUserLocation()
                
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
    
    /*
     * handle reload map (delegatable) method call
     */
    func _callReloadMapAction() {
        
        updateStudentLocations()
        appLocation.updateDeviceLocation()
    }
    
    /*
     * handle delegate commands from other view (e.g. menu calls)
     */
    func handleDelegateCommand(
       _ command: String) {
        
        if debugMode == true { print ("_received command: \(command)") }
        
        if command == "addUserLocationFromMenu" {
            appMenu!.hideMenu()
           _callAddUserLocationAction()
        }
        
        if command == "reloadUserLocationMapFromMenu" {
            appMenu!.hideMenu()
           _callReloadMapAction()
        }
        
        if command == "logOutUserFromMenu" {
            appMenu!.hideMenu()
           _callLogOutAction()
        }
    }
    
    func initMenu() {
        
        let menuViews = Bundle.main.loadNibNamed("StudentMapMenu", owner: nil, options: nil) as? [StudentMapMenu]
        
        if let _menuViews = menuViews {
            
            let backgroundView = UIView()
                backgroundView.backgroundColor = .black
            
            let _menuView = _menuViews[0] as StudentMapMenu
                _menuView.delegate = self
            
            appMenu = YNDropDownMenu(
                frame: CGRect(x: 0, y: 28, width: UIScreen.main.bounds.size.width, height: 38),
                dropDownViews: [_menuView],
                dropDownViewTitles: [""] // no title(s) required
            )
            
            appMenu!.setImageWhen(
                normal: UIImage(named: "icnMenu_v1"),
                selected: UIImage(named: "icnCancel_v1"),
                disabled: UIImage(named: "icnMenu_v1")
            )
            
            appMenu!.setLabelColorWhen(normal: .black, selected: UIColor(netHex: 0xFFA409), disabled: .gray)
            appMenu!.setLabelFontWhen(normal: .systemFont(ofSize: 12), selected: .boldSystemFont(ofSize: 12), disabled: .systemFont(ofSize: 12))
            appMenu!.backgroundBlurEnabled = true
            appMenu!.bottomLine.isHidden = false
            
            appMenu!.blurEffectView = backgroundView
            appMenu!.blurEffectViewAlpha = 0.7
            appMenu!.alwaysSelected(at: 0)
            
            self.view.addSubview(appMenu!)
        }
    }
    
    //
    // MARK: Delegates
    //
    
    func mapView(
       _ mapView: MKMapView,
         didUpdate userLocation: MKUserLocation) {
        
        appLocation.updateCurrentLocationMeta(mapView.userLocation.coordinate)
    }
    
    func mapView(
       _ mapView: MKMapView,
         viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var studentAnnotation: PRSStudentMapAnnotation?
        
        if !(annotation is PRSStudentMapAnnotation) {
            return nil
            
        } else {
            
            studentAnnotation = annotation as? PRSStudentMapAnnotation
        }
        
        let identifier = "locPin_1"
        var annotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            
            annotationView = StudentMapAnnotationView(annotation: studentAnnotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = false
            
        } else {
            
            annotationView?.annotation = studentAnnotation
        }
        
        annotationView?.image = UIImage(named: "icnUserDefault_v1")
        if studentAnnotation?.ownLocation == true {
            annotationView?.image = UIImage(named: "icnUserSelf_v2")
        }
        
        return annotationView
    }
    
    func mapView(
       _ mapView: MKMapView,
         didSelect view: MKAnnotationView) {
        
        if view.annotation is MKUserLocation { return }
        
        let studentAnnotation = view.annotation as! PRSStudentMapAnnotation
        let views = Bundle.main.loadNibNamed(locationAnnotationIdent, owner: nil, options: nil)
        let calloutView = views?[0] as! StudentMapAnnotation
        
        calloutView.center = CGPoint(x: view.bounds.size.width / 2, y: -calloutView.bounds.size.height * 0.65)
        calloutView.studentName.text = studentAnnotation.title
        calloutView.studentMediaURL.setTitle(studentAnnotation.url, for: .normal)
        
        if studentAnnotation.url != nil {
            calloutView.studentMediaURLLabel.text = studentAnnotation.url
        }
        
        if studentAnnotation.distance != nil {
            calloutView.studentDistance.text = studentAnnotation.distance
        }
        
        calloutView.studentImage.image = UIImage(named: "imgUserDefault_v2")
        if studentAnnotation.ownLocation == true {
            calloutView.studentImage.image = UIImage(named: "imgUserDefault_v1")
            
            let btnDeleteImage = UIImage(named: "icnDelete_v1") as UIImage?
            let btnDelete = UIButton(type: UIButtonType.custom) as UIButton
            
            let btnEditImage = UIImage(named: "icnEditProfile_v1") as UIImage?
            let btnEdit = UIButton(type: UIButtonType.custom) as UIButton
            
            btnDelete.frame = CGRect(x: 108, y: 65, width: 25, height: 25)
            btnDelete.setImage(btnDeleteImage, for: .normal)
            btnDelete.accessibilityHint = studentAnnotation.objectId
            btnDelete.addTarget(self, action: #selector(MapViewController.userLocationDeleteAction(_:)), for: .touchUpInside)
            
            btnEdit.frame = CGRect(x: 143, y: 65, width: 25, height: 25)
            btnEdit.setImage(btnEditImage, for: .normal)
            btnEdit.accessibilityHint = studentAnnotation.objectId
            btnEdit.addTarget(self, action: #selector(MapViewController.userLocationEditProfileAction(_:)), for: .touchUpInside)
            
            calloutView.addSubview(btnDelete)
            calloutView.addSubview(btnEdit)
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
}
