//
//  ColorPickerCollectionViewCell.swift
//  Dreamachine
//
//  Created by Ken on 5/13/17.
//  Copyright © 2017 charles. All rights reserved.
//

import UIKit

class ColorPickerCollectionViewCell: UICollectionViewCell {

    
    @IBOutlet weak var vwColor: UIView!
    @IBOutlet weak var ivCheck: UIImageView!
    
    var _isChecked = false;
    var isChecked: Bool {
        get {
            return _isChecked;
        }
        
        set {
            _isChecked = newValue
            if _isChecked {
                self.ivCheck.isHidden = false
            } else {
                self.ivCheck.isHidden = true
            }
        }
    }
    
    var _colorString: String!
    var colorString: String {
        get {
            return _colorString
        }
        
        set {
            _colorString = newValue
            self.vwColor.backgroundColor = Utils.hexStringToUIColor(hex: _colorString)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        self.intStyle()
    }
    
    func intStyle() {
        self.isChecked = false
        self.vwColor.layer.cornerRadius = self.vwColor.frame.height / 2
        self.vwColor.layer.masksToBounds = true
    }
    
}
