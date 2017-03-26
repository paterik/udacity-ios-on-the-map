//
//  LocationEditViewController.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 24.03.17.
//  Copyright © 2017 Patrick Paechnatz. All rights reserved.
//

import UIKit

class LocationEditViewController: UIViewController {
    
    //
    // MARK: Variables
    //
    
    var editMode: Bool = false
    var locationPageViewController: LocationPageViewController? {
        didSet { locationPageViewController?.locationDelegate = self }
    }
    
    //
    // MARK: IBOutlet Variables
    //
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var btnNextStep: UIButton!
    
    //
    // MARK: Overrides
    //
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        prepareUI()
        pageControl.addTarget(
            self,
            action: #selector(LocationEditViewController.btnPageControlAction),
            for: .valueChanged
        )
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let locationPageViewController = segue.destination as? LocationPageViewController {
            self.locationPageViewController = locationPageViewController
        }
    }
    
    //
    // MARK: IBAction Methods
    //
    
    @IBAction func btnNextPageAction(_ sender: Any) {
        locationPageViewController?.scrollToNextViewController()
    }
    
    //
    // MARK: Methods
    //
    
    func btnPageControlAction() {
        locationPageViewController?.scrollToViewController(index: pageControl.currentPage)
    }
    
    /*
     * this method will disable feature implementation of more than 2 pages during profile/location setup
     */
    func prepareUI() {
        btnNextStep.isEnabled = false
        btnNextStep.isHidden = true
    }
}


