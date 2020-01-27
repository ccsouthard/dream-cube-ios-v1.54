//
//  FlashViewController.swift
//  Dreamachine
//
//  Created by Ken on 5/14/17.
//  Copyright © 2017 charles. All rights reserved.
//

import UIKit
import AVFoundation

protocol FlashViewControllerDelegate {
    func closeFlashView()
}

class FlashViewController: BaseViewController {

    var delegate: FlashViewControllerDelegate? = nil
    @IBOutlet weak var vwFlash: UIView!
    @IBOutlet weak var lblNote: UILabel!
    @IBOutlet weak var vwBrightness: UIView!
    
    var timer : Timer!
    var T = 0.5 ;
    var colorString: String!
    var frequency: Float!
    var brightness: Float32!
    var isFlashLightOn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.vwBrightness.alpha = CGFloat(1.0 - Float(self.brightness))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapedOnView(_:)))
        self.view.addGestureRecognizer(tapGesture)
        self.doFlash()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func initVal(_ frequency: Float, _ colorString: String, _ brightness: Float, _ isFlashLightOn: Bool) {
        self.frequency = frequency
        self.colorString = colorString
        self.brightness = brightness
        self.isFlashLightOn = isFlashLightOn
    }
    
    func doFlash() {
        self.vwFlash.backgroundColor = Utils.hexStringToUIColor(hex: self.colorString)
        self.timer = Timer.scheduledTimer(timeInterval: (T/Double(self.frequency)), target: self, selector: #selector(self.onTimerEvent), userInfo: nil, repeats: true)
    }
    
    
    func onTimerEvent() {
        if self.isFlashLightOn {
            let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
            if (device?.hasTorch)! {
                do {
                    try device?.lockForConfiguration()
                    if (device?.torchMode == AVCaptureTorchMode.on) {
                        device?.torchMode = AVCaptureTorchMode.off
                    } else {
                        do {
                            try device?.setTorchModeOnWithLevel(1.0)
                        } catch {
                            print(error)
                        }
                    }
                    device?.unlockForConfiguration()
                } catch {
                    print(error)
                }
            }
        } else {
            self.vwFlash.isHidden = !self.vwFlash.isHidden;
        }
    }
    
    func tapedOnView(_ sender: UITapGestureRecognizer) {
        if self.timer != nil {
            self.timer.invalidate()
            self.timer = nil;
        }
        self.delegate?.closeFlashView()
        if self.isFlashLightOn {
            let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
            if (device?.hasTorch)! {
                do {
                    try device?.lockForConfiguration()
                    if (device?.torchMode == AVCaptureTorchMode.on) {
                        device?.torchMode = AVCaptureTorchMode.off
                    }
                    device?.unlockForConfiguration()
                } catch {
                    print(error)
                }
            }
        }
        self.dismiss(animated: false, completion: nil)
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
