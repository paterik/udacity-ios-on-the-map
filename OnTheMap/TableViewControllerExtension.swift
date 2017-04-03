//
//  TableViewControllerExtension.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 01.04.17.
//  Copyright © 2017 Patrick Paechnatz. All rights reserved.
//

import UIKit
import YNDropDownMenu

extension TableViewController {

    func initListView(_ loadOwnDataOnly: Bool) {
        
        locations = clientParse.students.locations
        if loadOwnDataOnly == true {
            locations = clientParse.students.myLocations
        }
        
        tableView.reloadData()
    }
    
    func initMenu() {
        
        let menuViews = Bundle.main.loadNibNamed("StudentListMenu", owner: nil, options: nil) as? [StudentListMenu]
        
        if let _menuViews = menuViews {
            
            // take first view definition as studentMapMenu and activate command delegation pipe
            let backgroundView = UIView()
            let _menuView = _menuViews[0] as StudentListMenu
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
            
            backgroundView.backgroundColor = .black
            appMenu!.blurEffectView = backgroundView
            appMenu!.blurEffectViewAlpha = 0.7
            appMenu!.alwaysSelected(at: 0)
            
            self.view.addSubview(appMenu!)
        }
    }
    
    /*
     * handle delegate commands from other view (e.g. menu calls)
     */
    func handleDelegateCommand(
        _ command: String) {
        
        if debugMode == true { print ("_received command: \(command)") }
        
        if command == "loadAllLocationsFromMenu" {
            
            initListView( false )
            appMenu!.hideMenu()
        }
        
        if command == "loadOwnLocationsFromMenu" {
            
            initListView( true )
            appMenu!.hideMenu()
        }
        
        if command == "logOutUserFromMenu" {
            appMenu!.hideMenu()
        }
    }
    
    /*
     * open the student given mediaURL
     */
    func openMediaURL(_ studentMediaUrl: String?) {
        
        let app = UIApplication.shared
        
        if var mediaURL = studentMediaUrl as String? {
            
            let btnOkAction = UIAlertAction(title: "OK", style: .default) { (action: UIAlertAction!) in return }
            let alertController = UIAlertController(
                title: "Alert",
                message: "UP's, unable to open students URL \(mediaURL)! May be this URL is invalid :(",
                preferredStyle: UIAlertControllerStyle.alert
            )
            
            alertController.addAction(btnOkAction)
            
            if (mediaURL.hasPrefix("www")) {
                mediaURL = NSString(format: "https://%@", mediaURL) as String
            }
            
            if mediaURL.validateMediaURL() == true, let nsURL = NSURL(string: mediaURL)  {
                
                if  app.canOpenURL(nsURL as URL) == true {
                    app.open(nsURL as URL, options: [:], completionHandler: nil)
                }
                
            } else {
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
}
