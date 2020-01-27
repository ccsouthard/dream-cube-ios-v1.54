//
//  MainViewController
//  Dreamachine
//
//  Created by Ken on 4/26/16.
//  Copyright © 2017 charles. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
import AudioToolbox
import AVFoundation
import MediaPlayer

func RenderTone(inRefCon: UnsafeMutableRawPointer,
                ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
                inTimeStamp: UnsafePointer<AudioTimeStamp>,
                inBusNumber: UInt32,
                inNumberFrames: UInt32,
                ioData: UnsafeMutablePointer<AudioBufferList>?) -> OSStatus {
    // Get the tone parameters out of the view controller
    let viewController = unsafeBitCast(inRefCon, to: MainViewController.self)
    let left_theta_increment: Float32 = 2.0 * Float32(M_PI) * viewController.leftFrequency / viewController.sampleRate
    let right_theta_increment: Float32 = 2.0 * Float32(M_PI) * viewController.rightFrequency / viewController.sampleRate
    let amplitude: Float32 = 0.5 * viewController.amplitude
    let leftChannel: Int = 0
    let rightChannel: Int = 1
    let abl = UnsafeMutableAudioBufferListPointer(ioData)
    for frame in 0..<inNumberFrames {
        let leftBuffer = abl?[leftChannel].mData
        let leftVal = Float32(sin(viewController.leftTheta) * amplitude)
        leftBuffer?.assumingMemoryBound(to: Float32.self)[Int(frame)] = leftVal
        viewController.leftTheta = viewController.leftTheta + left_theta_increment
        if viewController.leftTheta > 2.0 * Float32(M_PI) {
            viewController.leftTheta = viewController.leftTheta - 2.0 * Float32(M_PI)
        }
    }
    for frame in 0..<inNumberFrames {
        let rightBuffer = abl?[rightChannel].mData
        let rightVal = Float32(sin(viewController.rightTheta) * amplitude)
        rightBuffer?.assumingMemoryBound(to: Float32.self)[Int(frame)] = rightVal
        viewController.rightTheta = viewController.rightTheta + right_theta_increment
        if viewController.rightTheta > 2.0 * Float32(M_PI) {
            viewController.rightTheta = viewController.rightTheta - 2.0 * Float32(M_PI)
        }
    }
    return noErr
}

class MainViewController : BaseViewController, UIScrollViewDelegate, HelpViewControllerDelegate, BeatViewControllerDelegate, FlashViewControllerDelegate, SettingViewDelegate, MPMediaPickerControllerDelegate {
    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    
    @IBOutlet weak var svMain: UIScrollView!
    @IBOutlet weak var ivWave: UIImageView!
    @IBOutlet weak var ivFrequency: UIImageView!
    @IBOutlet weak var ivPicker: UIImageView!
    @IBOutlet weak var vwSlider: UIView!
    @IBOutlet weak var vwSetting: SettingView!
    @IBOutlet weak var vwHelper: UIView!
    @IBOutlet weak var lblFrequency: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblMode: UILabel!
    @IBOutlet weak var lblModeBelow: UILabel!
    @IBOutlet weak var btnQuestion: UIButton!
    @IBOutlet weak var btnSetting: UIButton!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var btnChoose: UIButton!
    @IBOutlet weak var cntHelperViewHeight: NSLayoutConstraint!
    @IBOutlet weak var cntSettingViewHeight: NSLayoutConstraint!
    
    @IBAction func settingBtnClicked(_ sender: Any) {
        self.isSettingViewOpened = !self.isSettingViewOpened;
    }
    
    @IBAction func playBtnClicked(_ sender: Any) {
        
        self.isSettingViewOpened = false
        if self.isBeatMode {
            if (toneUnit != nil) {
                AudioOutputUnitStop(toneUnit!)
                AudioUnitUninitialize(toneUnit!)
                AudioComponentInstanceDispose(toneUnit!)
                toneUnit = nil
                self.isBeatPlayed = false
            } else {
                self.isBeatPlayed = true
                self.createToneUnit()
                // Stop changing parameters on the unit
                var err = AudioUnitInitialize(toneUnit!)
                //NSAssert1(err == noErr, @"Error initializing unit: %ld", (long)err)
                
                // Start playback
                err = AudioOutputUnitStart(toneUnit!)
                //NSAssert1(err == noErr, @"Error starting unit: %ld", (long)err)
            }
            
//            self.isBeatViewOpened = true
//            let beatViewController = storyBoard.instantiateViewController(withIdentifier: "BeatViewController") as! BeatViewController
//            self.selectedColorString = self.vwSetting.selectedColorString
//            //TODO pass the data for beat
//            beatViewController.delegate = self
//            beatViewController.initVal()
//            self.present(beatViewController, animated: true, completion: nil)
        } else {
            self.isFlashPlayed = !self.isFlashPlayed
            let flashViewController = storyBoard.instantiateViewController(withIdentifier: "FlashViewController") as! FlashViewController
            self.selectedColorString = self.vwSetting.selectedColorString
            flashViewController.initVal(self.flashFrequency, self.selectedColorString, self.brightness, self.vwSetting.isFlashLightOn)
            flashViewController.delegate = self
            self.present(flashViewController, animated: false, completion: nil)
        }
    }
    
    @IBAction func chooseBtnClicked(_ sender: Any) {
        self.isBeatMode = !self.isBeatMode
        self.changeScroll();
    }
    
    @IBAction func questionBtnClicked(_ sender: Any) {
        self.isHelpViewOpened = true
        
        let helpViewController = storyBoard.instantiateViewController(withIdentifier: "HelpViewController") as! HelpViewController
        helpViewController.delegate = self
        self.present(helpViewController, animated: true, completion: nil)
    }
    
    
    var player: AVAudioPlayer?
    var mediaPicker: MPMediaPickerController?
    var _musicUrl: URL!
    var musicUrl: URL {
        get {
            return _musicUrl
        }
        
        set {
            _musicUrl = newValue
            if self.isBeatPlayed == true {
                self.playSoundWithPath(_musicUrl)
            }
        }
    }
    var flashFrequency: Float!
    var beatFrequency: Float!
    let carrierfrequency = 200;
    var selectedColorString: String!
    
    ///////
    var sampleRate: Float32 = 44100.0
    //var carrierFrequency: Float32 = 200
    var binauralFrequency: Float32 = 5
    var leftFrequency: Float32!
    var rightFrequency: Float32!
    
    var _volume: Float32 = 0.5
    var volume: Float32 {
        get {
            return _volume
        }
        
        set {
            _volume = newValue
            self.player?.volume = _volume
        }
    }
    var amplitude: Float32 = 0.5
    var brightness: Float32 = 1.0
    
    var rightTheta: Float32 = 0
    var leftTheta: Float32 = 0
    var toneUnit: AudioComponentInstance?
    ///////
    
    var _isTapped: Bool = false
    var isTapped: Bool! {
        get {
            return _isTapped;
        }
        
        set {
            _isTapped = newValue;
            if _isTapped {
                self.showFrequencyPicker()
            } else {
                self.hideFrequencyPicker()
            }
        }
    }
    
    var _isBeatPlayed: Bool = false
    var isBeatPlayed: Bool! {
        get {
            return _isBeatPlayed;
        }
        
        set {
            _isBeatPlayed = newValue;
            if _isBeatPlayed {
                btnPlay.setImage(UIImage(named: "btn-pause"), for: .normal);
                
                if self.vwSetting.isPinkNoiseSelected {
                    self.isPinkNoiseSelected = true
                } else if self.vwSetting.isWhiteNoiseSelected {
                    self.isWhiteNoiseSelected = true
                } else if self.vwSetting.isCloudNoiseSelected {
                    self.isCloudNoiseSelected = true
                } else if self.vwSetting.isMusicNoiseSelected {
                    self.playSoundWithPath(self.musicUrl)
                }
            } else {
                btnPlay.setImage(UIImage(named: "btn-play"), for: .normal);
                self.stopSound()
            }
        }
    }
    
    var _isFlashPlayed: Bool = false
    var isFlashPlayed: Bool! {
        get {
            return _isFlashPlayed;
        }
        
        set {
            _isFlashPlayed = newValue;
            if _isFlashPlayed {
                btnPlay.setImage(UIImage(named: "btn-pause"), for: .normal);
            } else {
                btnPlay.setImage(UIImage(named: "btn-play"), for: .normal);
            }
        }
    }
    
    var _isBeatMode: Bool = false
    var isBeatMode: Bool {
        get {
            return _isBeatMode
        }
        
        set {
            _isBeatMode = newValue
            if _isBeatMode {
                btnChoose.setImage(UIImage(named: "btn-color"), for: .normal)
                self.determindModeTitle()
                let con = isBeatPlayed
                isBeatPlayed = con
            } else {
                btnChoose.setImage(UIImage(named: "btn-beats"), for: .normal)
                if self.vwSetting.isFlashLightOn {
                    lblMode.text = "You are in flickering light mode"
                } else {
                    lblMode.text = "This is Light Mode"
                }
                
                let con = isFlashPlayed
                isFlashPlayed = con
            }
        }
    }
    
    var isWarnningShown: Bool = false
    var _isSettingViewOpened: Bool = false
    var isSettingViewOpened: Bool {
        get {
            return _isSettingViewOpened
        }
        
        set {
            _isSettingViewOpened = newValue
            if _isSettingViewOpened {
                self.btnSetting.setImage(UIImage(named: "btn-close"), for: .normal)
                self.ivFrequency.isHidden = true
                self.btnQuestion.isHidden = true
                self.lblMode.isHidden = true
                self.lblModeBelow.isHidden = true
                UIView.animate(withDuration: 0.4, animations: {
                    self.cntSettingViewHeight.constant = self.view.frame.height;
                    self.view.layoutIfNeeded()
                }, completion: nil)
                
                if !isWarnningShown {
                    isWarnningShown = true
                    let alertController = UIAlertController(title: "Change Auto-Lock", message: "Open Settings. \n Tap Display & Brightness. \n Select Auto-Lock. \n Set the sleep timer to the time that works best for you or select Never to turn off Auto-Lock on iPhone.", preferredStyle: UIAlertControllerStyle.alert) //Replace UIAlertControllerStyle.Alert by UIAlertControllerStyle.alert
                
                    // Replace UIAlertActionStyle.Default by UIAlertActionStyle.default
                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                        (result : UIAlertAction) -> Void in
                        print("OK")
                    }
                
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }
               
            } else {
                self.btnSetting.setImage(UIImage(named: "btn-settings"), for: UIControlState.normal)
                self.ivFrequency.isHidden = false
                self.btnQuestion.isHidden = false
                self.lblMode.isHidden = false
                self.lblModeBelow.isHidden = false
                self.selectedColorString = self.vwSetting.selectedColorString
                UIView.animate(withDuration: 0.4, animations: {
                    self.cntSettingViewHeight.constant = 0
                    self.view.layoutIfNeeded()
                }, completion: nil)
            }
        }
    }
    
    var _isHelpViewOpened: Bool = false;
    var isHelpViewOpened: Bool {
        get {
            return _isHelpViewOpened
        }
        
        set {
            _isHelpViewOpened = newValue
            if _isHelpViewOpened {
                self.vwHelper.isHidden = true
                self.ivFrequency.isHidden = true
                self.btnQuestion.isHidden = true
                self.lblMode.isHidden = true
                self.lblModeBelow.isHidden = true
            } else {
                self.vwHelper.isHidden = false
                self.ivFrequency.isHidden = false
                self.btnQuestion.isHidden = false
                self.lblMode.isHidden = false
                self.lblModeBelow.isHidden = false
            }
        }
    }
    
    var _isFlashLightOn = false
    var isFlashLightOn: Bool {
        get {
            return _isFlashLightOn
        }
        
        set {
            _isFlashLightOn = newValue
        }
    }
    
    var _isPinkNoiseSelected: Bool = false
    var isPinkNoiseSelected: Bool {
        get {
            return _isPinkNoiseSelected
        }
        
        set {
            _isPinkNoiseSelected = newValue
            if self.isBeatPlayed == true {
                if _isPinkNoiseSelected {
                    self.playSoundWithName("Sounds/pink_noise", "wav")
                } else {
                    self.stopSound()
                }
            }
        }
    }
    
    var _isWhiteNoiseSelected: Bool = false
    var isWhiteNoiseSelected: Bool {
        get {
            return _isWhiteNoiseSelected
        }
        
        set {
            _isWhiteNoiseSelected = newValue
            if self.isBeatPlayed == true {
                if _isWhiteNoiseSelected {
                    self.playSoundWithName("Sounds/white_noise", "wav")
                } else {
                    self.stopSound()
                }
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
            if self.isBeatPlayed == true {
                if _isCloudNoiseSelected {
                    self.playSoundWithName("Sounds/rain_noise", "mp3")
                } else {
                    self.stopSound()
                }
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

            } else {
                self.stopSound()
            }
        }
    }
    
    
//    var _isBeatViewOpened: Bool = false;
//    var isBeatViewOpened: Bool {
//        get {
//            return _isBeatViewOpened
//        }
//        
//        set {
//            _isBeatViewOpened = newValue
//            if _isBeatViewOpened {
//                self.vwHelper.isHidden = true
//                self.ivFrequency.isHidden = true
//                self.btnQuestion.isHidden = true
//            } else {
//                self.vwHelper.isHidden = false
//                self.ivFrequency.isHidden = false
//                self.btnQuestion.isHidden = false
//            }
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initVal()
        self.initStyle()
        svMain.delegate = self
        vwSetting.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initVal() {
        self.isSettingViewOpened = false
        self.isHelpViewOpened = false
//       self.isBeatViewOpened = false
        self.isBeatMode = false
        self.isFlashPlayed = false
        self.isBeatPlayed = false
        self.selectedColorString = COLORS[0]
        
        self.vwSetting.selectedColorString = COLORS[0]
        self.flashFrequency = FREQUENCY_MIN
        self.beatFrequency = FREQUENCY_MIN
        
        self.amplitude = 0.5
        self.brightness = 1.0
        
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        try! AVAudioSession.sharedInstance().setActive(true)
        UIApplication.shared.beginReceivingRemoteControlEvents()
        self.changeFrequencies()
    }
    
    func initStyle() {
        self.hideFrequencyPicker()
        let svHeight = self.svMain.frame.height
        let svWidth = self.svMain.frame.width
        self.btnQuestion.layer.cornerRadius = self.btnQuestion.frame.height / 2
        self.btnQuestion.layer.masksToBounds = true
        self.btnQuestion.layer.borderWidth = 1
        self.btnQuestion.layer.borderColor = UIColor.white.cgColor
        self.svMain.contentSize = CGSize(width: svWidth*5, height: svHeight)
        self.ivWave.frame = CGRect(x: 0, y: 0, width: svWidth * 5, height: svHeight)
    }
    
    //MARK Delegate functions
    func closeHelpView() {
        self.isHelpViewOpened = false
    }
    
    func closeBeatView() {
//        self.isBeatViewOpened = false
    }
    
    func closeFlashView() {
        self.isFlashPlayed = false
    }
    
    func amplitudeSliderChanged() {
        self.volume = vwSetting.amplitude
    }
    
    func brightnessSliderChanged() {
        self.brightness = vwSetting.brightness
    }
    
    func pinkBtnClicked() {
        self.isPinkNoiseSelected = self.vwSetting.isPinkNoiseSelected
        determindModeTitle()
    }
    
    func whiteBtnClicked() {
        self.isWhiteNoiseSelected = self.vwSetting.isWhiteNoiseSelected
        determindModeTitle()
    }
    
    func cloudBtnClicked() {
        self.isCloudNoiseSelected = self.vwSetting.isCloudNoiseSelected
        determindModeTitle()
    }
    
    func flashLightBtnClicked() {
        self.isFlashLightOn = self.vwSetting.isFlashLightOn
        determindModeTitle()
    }
    
    func musicBtnClicked() {
        self.isMusicNoiseSelected = self.vwSetting.isMusicNoiseSelected
        if self.isMusicNoiseSelected {
            mediaPicker = MPMediaPickerController.self(mediaTypes: MPMediaType.anyAudio)
            mediaPicker?.delegate = self
            mediaPicker?.allowsPickingMultipleItems = false
            
            self.present(mediaPicker!, animated: true, completion: nil)
        } else {
            
        }
        determindModeTitle()
    }
    
    func determindModeTitle() {
        if isBeatMode {
            if isWhiteNoiseSelected || isPinkNoiseSelected || isCloudNoiseSelected || isMusicNoiseSelected {
                lblMode.text = "This is Sound Mode"
            } else {
                lblMode.text = "You are in Binaural Beat mode"
            }
        } else {
            if isFlashLightOn {
                lblMode.text = "You are in flickering light mode"
            } else {
                lblMode.text = "This is Light Mode"
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset.x);
        self.getFrequency(scrollView.contentOffset.x)
        
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.isTapped = true
    }
    
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        self.isTapped = false
//    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
            self.isTapped = false
        }
    }
    
    
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        let item = mediaItemCollection.items.first! as MPMediaItem
        self.musicUrl = (item.value(forProperty: MPMediaItemPropertyAssetURL) as? URL)!
        mediaPicker.dismiss(animated: true, completion: nil)
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        self.vwSetting.isMusicNoiseSelected = false
        self.isMusicNoiseSelected = false
        mediaPicker.dismiss(animated: true, completion: nil)
        determindModeTitle()
    }
    
    // Change the frequency/description label, while frequency picker
    // is moving to the left and right.
    func getFrequency(_ offset_x: CGFloat) {
        if self.isBeatMode {
            if offset_x < 0 {
                self.beatFrequency = FREQUENCY_MIN
            } else {
                let rate = offset_x / (CGFloat)(SCREEN_WIDTH * (CHANNEL_COUNTS - 1))
                self.beatFrequency = FREQUENCY_MIN + Float(rate)  * (FREQUENCY_MAX - FREQUENCY_MIN)
                
                self.lblFrequency.text = String(self.beatFrequency.roundTo(places: 2)) + " Hz"
            }
            if self.beatFrequency < THRESHOLD_DELTA_THETA {
                self.lblDescription.text = FREQUENCY_DESCRIPTION["delta"]
                self.ivFrequency.image = UIImage(named: "ic-delta")
            } else if self.beatFrequency < THRESHOLD_THETA_ALPHA {
                self.lblDescription.text = FREQUENCY_DESCRIPTION["theta"]
                self.ivFrequency.image = UIImage(named: "ic-theta")
            } else if self.beatFrequency < THRESHOLD_ALPHA_BETA {
                self.lblDescription.text = FREQUENCY_DESCRIPTION["alpha"]
                self.ivFrequency.image = UIImage(named: "ic-alpha")
            } else if self.beatFrequency < THRESHOLD_BETA_GAMMA {
                self.lblDescription.text = FREQUENCY_DESCRIPTION["beta"]
                self.ivFrequency.image = UIImage(named: "ic-beta")
            } else {
                self.lblDescription.text = FREQUENCY_DESCRIPTION["gamma"]
                self.ivFrequency.image = UIImage(named: "ic-gamma")
            }
            self.changeFrequencies()
        } else {
            if offset_x < 0 {
                self.flashFrequency = FREQUENCY_MIN
            } else {
                let rate = offset_x / (CGFloat)(SCREEN_WIDTH * (CHANNEL_COUNTS - 1))
                self.flashFrequency = FREQUENCY_MIN + Float(rate) * (FREQUENCY_MAX - FREQUENCY_MIN)
                self.lblFrequency.text = String(self.flashFrequency.roundTo(places: 2)) + " Hz"
            }
            if self.flashFrequency < THRESHOLD_DELTA_THETA {
                self.lblDescription.text = FREQUENCY_DESCRIPTION["delta"]
                self.ivFrequency.image = UIImage(named: "ic-delta")
            } else if self.flashFrequency < THRESHOLD_THETA_ALPHA {
                self.lblDescription.text = FREQUENCY_DESCRIPTION["theta"]
                self.ivFrequency.image = UIImage(named: "ic-theta")
            } else if self.flashFrequency < THRESHOLD_ALPHA_BETA {
                self.lblDescription.text = FREQUENCY_DESCRIPTION["alpha"]
                self.ivFrequency.image = UIImage(named: "ic-alpha")
            } else if self.flashFrequency < THRESHOLD_BETA_GAMMA {
                self.lblDescription.text = FREQUENCY_DESCRIPTION["beta"]
                self.ivFrequency.image = UIImage(named: "ic-beta")
            } else {
                self.lblDescription.text = FREQUENCY_DESCRIPTION["gamma"]
                self.ivFrequency.image = UIImage(named: "ic-gamma")
            }
        }

    }
    
    // Show the frequency picker when tap is begun.
    func showFrequencyPicker() {
        self.ivPicker.isHidden = false
        self.lblDescription.isHidden = false
        self.lblFrequency.isHidden = false
        UIView.animate(withDuration: 0.2, animations: {
            self.cntHelperViewHeight.constant = 0
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    // Hide the frequency picker when tap is ended.
    func hideFrequencyPicker() {
        self.ivPicker.isHidden = true
        self.lblDescription.isHidden = true
        self.lblFrequency.isHidden = true
        UIView.animate(withDuration: 0.2, animations: {
            self.cntHelperViewHeight.constant = 100
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func changeScroll() {
        let freqency = (self.isBeatMode) ? self.beatFrequency : self.flashFrequency
        let rate = (CGFloat(freqency! - FREQUENCY_MIN)) / (CGFloat(FREQUENCY_MAX - FREQUENCY_MIN))
        let offset_x = rate * (CGFloat)(SCREEN_WIDTH * (CHANNEL_COUNTS - 1))
        svMain.setContentOffset(CGPoint(x: offset_x, y: 0), animated: true)
    }
    
    func changeFrequencies() {
        
//        self.leftFrequency = ((Float32(self.beatFrequency) - (self.binauralFrequency / 2)) < 0) ? 0.1 : Float32(self.beatFrequency) - (self.binauralFrequency / 2)
//        self.rightFrequency = ((Float32(self.beatFrequency) - (self.binauralFrequency / 2)) < 0) ? 0.1 + self.binauralFrequency / 2 : Float32(self.beatFrequency) + (self.binauralFrequency / 2)
        
        self.leftFrequency = (Float32)(self.carrierfrequency) - (Float32)(self.beatFrequency / 2)
        self.rightFrequency = (Float32)(self.carrierfrequency) + (Float32)(self.beatFrequency / 2)
    }
    
    func createToneUnit() {
        var defaultOutputDescription = AudioComponentDescription()
        defaultOutputDescription.componentType = kAudioUnitType_Output
        defaultOutputDescription.componentSubType = kAudioUnitSubType_RemoteIO
        defaultOutputDescription.componentManufacturer = kAudioUnitManufacturer_Apple
        defaultOutputDescription.componentFlags = 0
        defaultOutputDescription.componentFlagsMask = 0
        let defaultOutput: AudioComponent = AudioComponentFindNext(nil, &defaultOutputDescription)!
        //assert(defaultOutput==nil, "Can't find default output")
        var err = AudioComponentInstanceNew(defaultOutput, &toneUnit)
        //assert((toneUnit != nil), "Error creating unit: %ld", file: err)
        var input = AURenderCallbackStruct()
        input.inputProc = RenderTone
        input.inputProcRefCon =  UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        err = AudioUnitSetProperty(toneUnit!,
                                   kAudioUnitProperty_SetRenderCallback,
                                   kAudioUnitScope_Input,
                                   0,
                                   &input,
                                   UInt32(MemoryLayout<AURenderCallbackStruct>.size))
        //assert(err == noErr, "Error setting callback: %ld", file: err)
        
        let four_bytes_per_float: UInt32 = 4
        let eight_bits_per_byte: UInt32 = 8
        var streamFormat = AudioStreamBasicDescription()
        streamFormat.mSampleRate = Float64(sampleRate)
        streamFormat.mFormatID = kAudioFormatLinearPCM;
        streamFormat.mFormatFlags =
            kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved
        streamFormat.mBytesPerPacket = four_bytes_per_float
        streamFormat.mFramesPerPacket = 1
        streamFormat.mBytesPerFrame = four_bytes_per_float
        streamFormat.mChannelsPerFrame = 2
        streamFormat.mBitsPerChannel = four_bytes_per_float * eight_bits_per_byte
        err = AudioUnitSetProperty (toneUnit!,
                                    kAudioUnitProperty_StreamFormat,
                                    kAudioUnitScope_Input,
                                    0,
                                    &streamFormat,
                                    UInt32(MemoryLayout<AudioStreamBasicDescription>.size))
        //        NSAssert1(err == noErr, @"Error setting stream format: %ld", (long)err)
    }
    
    func playSoundWithName(_ fileName: String, _ type: String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: type) else {
            print("error")
            return
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            player.volume = self.volume
            player.numberOfLoops = 2000
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func playSoundWithPath(_ path: URL) {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: path as URL)
            guard let player = player else { return }
            player.volume = self.volume
            player.numberOfLoops = 2000
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func stopSound() {
        if self.player != nil {
            self.player?.stop()
            self.player = nil
            self.isPinkNoiseSelected = false
            self.isWhiteNoiseSelected = false
            self.isCloudNoiseSelected = false
            self.isMusicNoiseSelected = false
        }
    }
    
}
