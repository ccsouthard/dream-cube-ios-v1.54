//
//  TutorialPageViewController.swift
//  Dreamachine
//
//  Created by Ken on 6/8/17.
//  Copyright © 2017 charles. All rights reserved.
//

import UIKit

class TutorialPageViewController: UIPageViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
        // Do any additional setup after loading the view.

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        for subView in self.view.subviews as! [UIView] {
            if subView is UIScrollView {
                subView.frame = self.view.bounds
            } else if subView is UIPageControl {
                self.view.bringSubview(toFront: subView)
            }
        }
        super.viewDidLayoutSubviews()
    }
    
}
