//
//  TutorialViewController.swift
//  Dreamachine
//
//  Created by Ken on 6/8/17.
//  Copyright © 2017 charles. All rights reserved.
//

import UIKit

protocol IPageIndexView {
    var pageIndex: Int {get set}
}

class TutorialViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var btnDream: UIButton!
    
    var pageViewController: TutorialPageViewController! = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnDream.isHidden = true
        btnDream.layer.masksToBounds = true
        btnDream.layer.cornerRadius = btnDream.frame.height / 2
        self.pageViewController = self.storyboard?.instantiateViewController(withIdentifier: "TutorialPageViewController") as! TutorialPageViewController
        
        self.pageViewController.dataSource = self
        self.pageViewController.delegate = self
        
        let initialContenViewController = self.pageTutorialAtIndex(0) as UIViewController
        
        self.pageViewController.setViewControllers([initialContenViewController], direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
        
        self.pageViewController.view.frame = CGRect(x: 0, y: 20, width: self.view.frame.width, height: self.view.frame.height - 20)// self.view.frame
        self.containerView.frame = self.view.frame
        self.addChildViewController(self.pageViewController)
        self.containerView.addSubview(self.pageViewController.view)
        self.pageViewController.didMove(toParentViewController: self)
        self.view.layoutIfNeeded()
        // Do any additional setup after loading the view.
        //pageControl.addTarget(self, action: "didChangePageControlValue", for: .valueChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pageTutorialAtIndex(_ index: Int) ->UIViewController
    {
        
        let pageContentViewController = self.storyboard?.instantiateViewController(withIdentifier: "TutorialPageContentHolderViewController") as! TutorialPageContentHolderViewController
        pageContentViewController.pageIndex = index
        
        var pview: UIView!
        if (index == 0) {
            pview = UINib(nibName: "TutorialContentView1", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
        }
        else if (index == 1) {
            pview = UINib(nibName: "TutorialContentView2", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
        }
        else {
            pview = UINib(nibName: "TutorialContentView3", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
        }
        pview.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        pageContentViewController.view.addSubview(pview)
        pageContentViewController.view.frame = self.view.frame

        pageContentViewController.view.layoutIfNeeded()
        return pageContentViewController
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?
    {
        let viewController = viewController as! TutorialPageContentHolderViewController
        var index = viewController.pageIndex as Int
        
        if(index == 0 || index == NSNotFound)
        {
            return nil
        }
        
        index -= 1
        
        return self.pageTutorialAtIndex(index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        let viewController = viewController as! TutorialPageContentHolderViewController
        var index = viewController.pageIndex as Int
        
        if((index == 2))
        {
            return nil
        }
        
        index += 1
        
        return self.pageTutorialAtIndex(index)
    }
    
    
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int
    {
        return 3
    }
    
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int
    {
        return 0
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            let pageContentViewController = pageViewController.viewControllers?[0] as! TutorialPageContentHolderViewController
            if(pageContentViewController.pageIndex == 2) {
                btnDream.isHidden = false
            }
            else {
                btnDream.isHidden = true
            }
        }
    }
    
    
//    @IBAction func skipButtonTapped(_ sender: AnyObject) {
//        
//        //Remember user's choice, so we can skip tutorial when user starts the app again
//        let defaults = UserDefaults.standard
//        defaults.setValue(true, forKey: "skipTutorialPages")
//        defaults.synchronize()
//        
//        
//        let nextView: TheNextViewController = self.storyboard?.instantiateViewController(withIdentifier: "TheNextViewController") as! TheNextViewController
//        
//        let appdelegate = UIApplication.shared.delegate as! AppDelegate
//        
//        appdelegate.window!.rootViewController = nextView
//        
//    }


}
