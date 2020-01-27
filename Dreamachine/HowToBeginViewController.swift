//
//  HowToBeginViewController.swift
//  Dreamachine
//
//  Created by Ken on 5/25/17.
//  Copyright © 2017 charles. All rights reserved.
//

import UIKit

class HowToBeginViewController: BaseViewController {

    var delegate: BackHelpViewControllerDelegate? = nil
    @IBAction func closeBtnClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        self.delegate?.backToHelpView()
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
