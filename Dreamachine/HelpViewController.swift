//
//  HelpViewController.swift
//  Dreamachine
//
//  Created by Ken on 5/14/17.
//  Copyright © 2017 charles. All rights reserved.
//

import UIKit
import Social

protocol HelpViewControllerDelegate {
    func closeHelpView()
}

protocol BackHelpViewControllerDelegate {
    func backToHelpView()
}

class HelpViewController: BaseViewController, BackHelpViewControllerDelegate {

    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    var delegate: HelpViewControllerDelegate? = nil
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var vwContent: UIView!
    
    @IBAction func howToBeginBtnClicked(_ sender: Any) {
//        self.vwContent.isHidden = true
//        let howToBeginViewController = storyBoard.instantiateViewController(withIdentifier: "HowToBeginViewController") as! HowToBeginViewController
//        howToBeginViewController.delegate = self
        
        let startViewController = storyBoard.instantiateViewController(withIdentifier: "TutorialViewController") as! TutorialViewController
       UIApplication.shared.keyWindow?.rootViewController = startViewController
        //navigationController.setViewControllers([startViewController], animated: true)
        
    }
    
   
    @IBAction func howItWorksBtnClicked(_ sender: Any) {
        let url = URL(string: URL_OF_HOW_IT_WORKS)!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func aboutBtnClicked(_ sender: Any) {
        let url = URL(string: URL_OF_ABOUT)!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func twitterBtnClicked(_ sender: Any) {
        post(toService: SLServiceTypeTwitter)
    }

    @IBAction func facebookBtnClicked(_ sender: Any) {
        post(toService: SLServiceTypeFacebook)
    }
    
    @IBAction func googlePlusBtnClicked(_ sender: Any) {
        
    }
    
    @IBAction func faqBtnClicked(_ sender: Any) {
        let url = URL(string: URL_OF_FAQ)!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func closeBtnClicked(_ sender: Any) {
        self.delegate?.closeHelpView()
        self.dismiss(animated: true, completion: nil)
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initStyle() {
        btnClose.layer.cornerRadius = btnClose.layer.frame.height / 2
        btnClose.layer.masksToBounds = true
    }
    
    func initVal() {
        
    }
    
    func backToHelpView() {
        self.vwContent.isHidden = false;
    }
    
    func post(toService service: String) {
        if(SLComposeViewController.isAvailable(forServiceType: service)) {
            let socialController = SLComposeViewController(forServiceType: service)
            //            socialController.setInitialText("Hello World!")
            //            socialController.addImage(someUIImageInstance)
            //            socialController.addURL(someNSURLInstance)
            self.present(socialController!, animated: true, completion: nil)
        }
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
