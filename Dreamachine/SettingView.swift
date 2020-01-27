//
//  SettingView.swift
//  Dreamachine
//
//  Created by Ken on 5/05/17.
//  Copyright © 2017 charles. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation

protocol SettingViewDelegate {
    func amplitudeSliderChanged()
    func brightnessSliderChanged()
    func pinkBtnClicked()
    func whiteBtnClicked()
    func cloudBtnClicked()
    func musicBtnClicked()
    func flashLightBtnClicked()
}

class SettingView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: - Properties
    var delegate: SettingViewDelegate? = nil
    @IBOutlet weak var btnWhite: UIButton!
    @IBOutlet weak var btnPink: UIButton!
    @IBOutlet weak var btnCloud: UIButton!
    @IBOutlet weak var btnMusic: UIButton!
    @IBOutlet weak var btnFlashlight: UIButton!
    @IBOutlet weak var clvColorPicker: UICollectionView!
    @IBOutlet weak var sldAmplitude: UISlider!
    @IBOutlet weak var sldBrightness: UISlider!
    @IBOutlet weak var lblDescription: UILabel!
    
    
    
    @IBAction func whiteBtnClicked(_ sender: Any) {
        self.isPinkNoiseSelected = false
        self.isCloudNoiseSelected = false
        self.isMusicNoiseSelected = false
        self.isWhiteNoiseSelected = !self.isWhiteNoiseSelected
        if self.isWhiteNoiseSelected {
            self.lblDescription.text = "White Noise";
        } else {
            self.lblDescription.text = "";
        }
        self.delegate?.whiteBtnClicked()
    }
    
    @IBAction func pinkBtnClicked(_ sender: Any) {
        self.isWhiteNoiseSelected = false
        self.isCloudNoiseSelected = false
        self.isMusicNoiseSelected = false
        self.isPinkNoiseSelected = !self.isPinkNoiseSelected
        if self.isPinkNoiseSelected {
            self.lblDescription.text = "Pink Noise";
        } else {
            self.lblDescription.text = "";
        }
        self.delegate?.pinkBtnClicked()
    }
    
    @IBAction func cloudBtnClicked(_ sender: Any) {
        self.isWhiteNoiseSelected = false
        self.isPinkNoiseSelected = false
        self.isMusicNoiseSelected = false
        self.isCloudNoiseSelected = !self.isCloudNoiseSelected
        if self.isCloudNoiseSelected {
            self.lblDescription.text = "Rain Noise";
        } else {
            self.lblDescription.text = "";
        }
        self.delegate?.cloudBtnClicked()
    }
    
    @IBAction func musicBtnClicked(_ sender: Any) {
        self.isWhiteNoiseSelected = false
        self.isPinkNoiseSelected = false
        self.isCloudNoiseSelected = false
        self.isMusicNoiseSelected = !self.isMusicNoiseSelected
        if self.isMusicNoiseSelected {
            self.lblDescription.text = "Music";
            
        } else {
            self.lblDescription.text = "";
        }
        self.delegate?.musicBtnClicked()
       
    }
    
    @IBAction func amplitudeSliderChanged(_ sender: Any) {
        self.amplitude = self.sldAmplitude.value
        self.delegate?.amplitudeSliderChanged()
    }
    
    @IBAction func brightnessSliderChanged(_ sender: Any) {
        self.brightness = self.sldBrightness.value
        self.delegate?.brightnessSliderChanged()
    }

    @IBAction func flashLightBtnClicked(_ sender: Any) {
        self.isFlashLightOn = !self.isFlashLightOn
        self.delegate?.flashLightBtnClicked()
    }
    
    let nibName = "ColorPickerCollectionViewCell"
    let reuseIdentifier = "ColorPickerCollectionViewCell"
    var selectedIndexPath: IndexPath? = nil
    var selectedColorString: String? = nil
    var brightness: Float32 = 1.0
    
//    var _musicUrl: URL!
//    var musicUrl: URL {
//        get {
//            return _musicUrl
//        }
//        
//        set {
//            _musicUrl = newValue
//            self.playSoundWithPath(_musicUrl, "mp3")
//        }
//    }
    
    var _isFlashLightOn = false
    var isFlashLightOn: Bool {
        get {
            return _isFlashLightOn
        }
        
        set {
            _isFlashLightOn = newValue
            if _isFlashLightOn {
                self.btnFlashlight.setTitle("Flicker Flashlight: on", for: .normal)
            } else {
                self.btnFlashlight.setTitle("Flicker Flashlight: off", for: .normal)
            }
        }
    }
    
    var _amplitude: Float32 = 0.5
    var amplitude: Float32 {
        get {
            return _amplitude
        }
        
        set {
            _amplitude = newValue
        }
    }
    
    var _isWhiteNoiseSelected: Bool = false
    var isWhiteNoiseSelected: Bool {
        get {
            return _isWhiteNoiseSelected
        }
        
        set {
            _isWhiteNoiseSelected = newValue
            if _isWhiteNoiseSelected {
                self.btnWhite.setImage(UIImage(named: "ic-white-selected"), for: UIControlState.normal)
                
            } else {
                self.btnWhite.setImage(UIImage(named: "ic-white"), for: UIControlState.normal)
                
            }
        }
    }
    
    var _isPinkNoiseSelected: Bool = false
    var isPinkNoiseSelected: Bool {
        get {
            return _isPinkNoiseSelected
        }
        
        set {
            _isPinkNoiseSelected = newValue
            if _isPinkNoiseSelected {
                self.btnPink.setImage(UIImage(named: "ic-pink-selected"), for: UIControlState.normal)
                
            } else {
                self.btnPink.setImage(UIImage(named: "ic-pink"), for: UIControlState.normal)
                
            }
        }
    }
    
    var _isCloudNoiseSelected: Bool = false
    var isCloudNoiseSelected: Bool {
        get {
            return _isCloudNoiseSelected
        }
        
        set {
            _isCloudNoiseSelected = newValue
            if _isCloudNoiseSelected {
                self.btnCloud.setImage(UIImage(named: "ic-cloud-selected"), for: UIControlState.normal)
                
            } else {
                self.btnCloud.setImage(UIImage(named: "ic-cloud"), for: UIControlState.normal)
                
            }
        }
    }
    
    var _isMusicNoiseSelected: Bool = false
    var isMusicNoiseSelected: Bool {
        get {
            return _isMusicNoiseSelected
        }
        
        set {
            _isMusicNoiseSelected = newValue
            if _isMusicNoiseSelected {
                self.btnMusic.setImage(UIImage(named: "ic-itunes-selected"), for: UIControlState.normal)
            } else {
                self.btnMusic.setImage(UIImage(named: "ic-itunes"), for: UIControlState.normal)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    // Performs the initial setup.
    fileprivate func setupView() {
        let view = viewFromNibForClass()
        view.frame = bounds
        view.autoresizingMask = [
            UIViewAutoresizing.flexibleWidth,
            UIViewAutoresizing.flexibleHeight
        ]
        addSubview(view)
        
        let nib = UINib(nibName: nibName, bundle: nil)
        self.clvColorPicker.register(nib, forCellWithReuseIdentifier: reuseIdentifier)
        self.clvColorPicker.delegate = self;
        self.clvColorPicker.dataSource = self;
        self.initStyle()
        
    }
    
    // Loads a XIB file into a view and returns this view.
    fileprivate func viewFromNibForClass() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    func initStyle() {
        self.btnFlashlight.layer.cornerRadius = self.btnFlashlight.frame.height / 2
        self.btnFlashlight.layer.masksToBounds = true
        self.btnFlashlight.layer.borderWidth = 1
        self.btnFlashlight.layer.borderColor = UIColor.white.cgColor
    }
    
    // MARK: - UICollectionViewDataSource protocol
    
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return COLORS.count
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! ColorPickerCollectionViewCell
        
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        //cell.myLabel.text = self.items[indexPath.item]
        //cell.backgroundColor = UIColor.cyan // make cell more visible in our example project
        cell.colorString = COLORS[indexPath.item]
        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events

        let cell = collectionView.cellForItem(at: indexPath) as! ColorPickerCollectionViewCell
        //print("You selected cell #\(indexPath.item)!")
        if self.selectedIndexPath == nil {
            cell.isChecked = true
        }
        else if self.selectedIndexPath == indexPath {
            cell.isChecked = !cell.isChecked
        } else {
            let previousCell = collectionView.cellForItem(at: self.selectedIndexPath!) as! ColorPickerCollectionViewCell
            previousCell.isChecked = false
            cell.isChecked = true
        }
        self.selectedIndexPath = indexPath
        self.selectedColorString = cell.colorString
    }
}

