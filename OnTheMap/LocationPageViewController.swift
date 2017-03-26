//
//  LocationPageViewController.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 24.03.17.
//  Copyright © 2017 Patrick Paechnatz. All rights reserved.
//

import UIKit

class LocationPageViewController: UIPageViewController, PageSetViewControllerProtocol {
    
    //
    // MARK: Constants
    //
    
    let debugMode: Bool = false
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //
    // MARK: Variables
    //
    
    weak var locationDelegate: LocationPageViewControllerDelegate?
    var currentUserLocation: PRSStudentData? = nil
    
    // complete controller stack to handle location manually (followed by profile and details)
    fileprivate(set) lazy var completeViewControllers: [UIViewController] = {
        return [
            self.newLocationViewController("pageSetLocation"),
            self.newLocationViewController("pageSetProfile")
            // *** self.newLocationViewController("pageSetDetail") // disabled yet!
        ]
    }()
    
    // small (quick) controller stack to handle profile and details only
    fileprivate(set) lazy var quickViewControllers: [UIViewController] = {
        return [
            self.newLocationViewController("pageSetProfile")
            // *** self.newLocationViewController("pageSetDetail") // disabled yet!
        ]
    }()
    
    // my ordered controller stack to handle pageViewController based user input
    var orderedViewControllers: [UIViewController] = []
    
    //
    // MARK: Overrides
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        dataSource = self
        
        // if location of current device was choosen, load quick locationView controller stack
        orderedViewControllers = (self.appDelegate.useCurrentDeviceLocation == false)
            ? completeViewControllers
            : quickViewControllers
        
        if let initialViewController = orderedViewControllers.first {
            scrollToViewController(initialViewController)
        }
        
        locationDelegate?.locationPageViewController(self, didUpdatePageCount: orderedViewControllers.count)
    }
    
    //
    // MARK: Methods
    //
    
    /*
     * handle string based commands from embedded controllers, here we can force a scroll
     * inside our pageViewController given by our PageSetLocationViewController for example
     */
    func handleDelegateCommand(
       _ command: String) {
        
        if command == "scrollToNextViewController" {
            if debugMode == true { print ("_received: \(command), execute: scroll") }
            scrollToNextViewController()
        }
    }
    
    /*
     * scrolls/jump to the next view controller.
     */
    func scrollToNextViewController() {
        
        if let visibleViewController = viewControllers?.first,
           let nextViewController = pageViewController(self, viewControllerAfter: visibleViewController) {
            scrollToViewController(nextViewController)
        }
    }
    
    /*
     * scrolls/jump to the view controller on corresponding index (including autocalc of direction)
     */
    func scrollToViewController(
         index newIndex: Int) {
        
        if let firstViewController = viewControllers?.first,
           let currentIndex = orderedViewControllers.index(of: firstViewController) {
            
            let direction: UIPageViewControllerNavigationDirection = newIndex >= currentIndex ? .forward : .reverse
            let nextViewController = orderedViewControllers[newIndex]
            
            scrollToViewController(nextViewController, direction: direction)
        }
    }
    
    /*
     * notifies 'locationDelegate' about current page index is updated
     */
    func notifyLocationDelegateOfNewIndex() {
        
        if let firstViewController = viewControllers?.first,
            let index = orderedViewControllers.index(of: firstViewController) {
            
            locationDelegate?.locationPageViewController(self, didUpdatePageIndex: index)
        }
    }
    
    /*
     * fetch a new viewController by corresponding identifier
     */
    fileprivate func newLocationViewController(
       _ indent: String) -> UIViewController {
        
        let vc = UIStoryboard(name: "Main", bundle: nil) .
        instantiateViewController(withIdentifier: "\(indent)Controller") as! PageSetViewController
        vc.delegate = self
        
        return vc
    }
    
    /*
     * jump/scrolls to the corresponding viewController page
     */
    fileprivate func scrollToViewController(
       _ viewController: UIViewController,
         direction: UIPageViewControllerNavigationDirection = .forward) {
        
        setViewControllers(
            [ viewController ],
            direction: direction,
            animated: true,
            completion: { (finished) -> Void in
            
                self.notifyLocationDelegateOfNewIndex()
            }
        )
    }
}
