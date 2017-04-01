//
//  TableViewControllerExtension.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 01.04.17.
//  Copyright © 2017 Patrick Paechnatz. All rights reserved.
//

import Foundation
import UIKit

extension TableViewController {

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
