//
//  StartViewController.swift
//  Dreamachine
//
//  Created by Ken on 4/27/16.
//  Copyright © 2017 charles. All rights reserved.
//

import Foundation
import UIKit

class StartViewController : BaseViewController {
    
    @IBOutlet weak var btnStartJourney: UIButton!
    @IBOutlet weak var ivBackground: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initStyle()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initStyle() {
        btnStartJourney.layer.cornerRadius = btnStartJourney.frame.height / 2
        btnStartJourney.clipsToBounds = true
        let imageData = try! Data(contentsOf: Bundle.main.url(forResource: "Images/splash-bg", withExtension: "gif")!)
        self.ivBackground.image = UIImage.gif(data: imageData)
    }
    
}


