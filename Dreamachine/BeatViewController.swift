//
//  BeatViewController.swift
//  Dreamachine
//
//  Created by Ken on 5/15/17.
//  Copyright © 2017 charles. All rights reserved.
//

import UIKit
import AudioToolbox
import AVFoundation


func RenderTone1(inRefCon: UnsafeMutableRawPointer,
                ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
                inTimeStamp: UnsafePointer<AudioTimeStamp>,
                inBusNumber: UInt32,
                inNumberFrames: UInt32,
                ioData: UnsafeMutablePointer<AudioBufferList>?) -> OSStatus {
    // Get the tone parameters out of the view controller
    let viewController = unsafeBitCast(inRefCon, to: BeatViewController.self)
    let left_theta_increment: Float32 = 2.0 * Float32(M_PI) * viewController.leftFrequency / viewController.sampleRate
    let right_theta_increment: Float32 = 2.0 * Float32(M_PI) * viewController.rightFrequency / viewController.sampleRate
    let amplitude: Float32 = 0.25 * viewController.amplitude
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

protocol BeatViewControllerDelegate {
    func closeBeatView()
}

class BeatViewController: BaseViewController {
    
    var delegate: BeatViewControllerDelegate? = nil
    
    @IBOutlet weak var btnPlay: UIButton!
    @IBAction func playBtnClicked(_ sender: Any) {
        self.isPaused = !self.isPaused
        //TODO beat play & pause
        
        if (toneUnit != nil) {
            AudioOutputUnitStop(toneUnit!)
            AudioUnitUninitialize(toneUnit!)
            AudioComponentInstanceDispose(toneUnit!)
            toneUnit = nil
            
        } else {
            self.createToneUnit()
            
            // Stop changing parameters on the unit
            var err = AudioUnitInitialize(toneUnit!)
            //NSAssert1(err == noErr, @"Error initializing unit: %ld", (long)err)
            
            // Start playback
            err = AudioOutputUnitStart(toneUnit!)
            //NSAssert1(err == noErr, @"Error starting unit: %ld", (long)err)
        }
        
    }
    
    @IBAction func closeBtnClicked(_ sender: Any) {
        //TODO release the sound player
        
        self.delegate?.closeBeatView()
        self.dismiss(animated: true, completion: nil)
    }
    
    var _isPaused: Bool = false
    var isPaused: Bool {
        get {
            return _isPaused
        }
        
        set {
            _isPaused = newValue
            if _isPaused {
                self.btnPlay?.setImage(UIImage(named: "btn-play"), for: .normal)
            } else {
                self.btnPlay?.setImage(UIImage(named: "btn-pause"), for: .normal)
            }
        }
    }
    
    /////////////
    var sampleRate: Float32 = 44100.0
    var carrierFrequency: Float32 = 200
    var binauralFrequency: Float32 = 8
    var leftFrequency: Float32!
    var rightFrequency: Float32!
    var amplitude: Float32!
    var rightTheta: Float32 = 0
    var leftTheta: Float32 = 0
    var toneUnit: AudioComponentInstance?

    ///////////
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initVal()
        
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        try! AVAudioSession.sharedInstance().setActive(true)
        UIApplication.shared.beginReceivingRemoteControlEvents()
        self.ChangeFrequencies()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initVal() {
        self.isPaused = false
        
        /////////
        self.leftFrequency = self.carrierFrequency - (self.binauralFrequency / 2)
        self.rightFrequency = self.carrierFrequency + (self.binauralFrequency / 2)
        self.amplitude = 0.5
        ////////
    }
    
    /////////////
    
    func ChangeFrequencies()
    {
        //round carrier slider to only use two decimal places
        self.carrierFrequency = roundf(self.carrierFrequency * 100) / 100
        //round binaural to only use two decimal places
        self.binauralFrequency = roundf(self.binauralFrequency * 100) / 100
        //check for out of range and adjust accordingly
        if (self.carrierFrequency - (self.binauralFrequency / 2) < 0.1)
        {
            self.carrierFrequency = (self.binauralFrequency / 2) + 0.1
        }
        leftFrequency = self.carrierFrequency - (self.binauralFrequency / 2)
        rightFrequency = self.carrierFrequency + (self.binauralFrequency / 2)
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
        input.inputProc = RenderTone1
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
    
    
    
    
    ////////////
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
