//
//  UITextViewUnderline.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 22.11.16.
//  Copyright © 2016 Patrick Paechnatz. All rights reserved.
//

import UIKit
import JVFloatLabeledTextField

class UITextViewUnderline: JVFloatLabeledTextField {

    // -- constants
    let lineHeight: CGFloat = 1.0
    let lineMarginLeft: CGFloat = 8.0
    let lineMarginRight: CGFloat = 0.0
    let lineMarginTop: CGFloat = 35.0
    let lineBackgroundColor = UIColor(netHex: 0x1EB4E2)
    let screenSize: CGRect = UIScreen.main.bounds
    
    // -- variables
    var lblInputUnderline: UILabel!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        self.initInputField();
    }
    
    func initInputField() {
        
        lblInputUnderline = UILabel(
            frame:
            CGRect(
                x: lineMarginLeft,
                y: lineMarginTop,
                width: screenSize.size.width - (lineMarginLeft - lineMarginRight),
                height: lineHeight)
        )
        
        lblInputUnderline.layer.masksToBounds = false
        lblInputUnderline.textColor = UIColor.clear
        lblInputUnderline.backgroundColor = lineBackgroundColor
        lblInputUnderline.numberOfLines = 0
        
        addSubview(lblInputUnderline)
    }
}
