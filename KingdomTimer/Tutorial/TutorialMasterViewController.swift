//
//  MasterViewController.swift
//  KingdomTimer
//
//  Created by 정성훈 on 2021/03/03.
//

import UIKit

class TutorialMasterViewController: UIViewController, UIPageViewControllerDataSource {

    @IBOutlet weak private var closeButton: UIButton?
    private let contentsTitles = ["", "", "", ""]
    private let imageNames = ["page0", "page1", "page2", "page3"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let pageVC = self.initTutorialVC(withIdentifier: "Page") as? UIPageViewController {
            pageVC.dataSource = self
            
            if let firstVC = getContentsVC(index: 0) {
                pageVC.setViewControllers([firstVC], direction: .forward, animated: true)
            }
            pageVC.view.frame.origin = CGPoint.zero
            pageVC.view.bounds.size = CGSize(width: self.view.bounds.width, height: self.view.bounds.height)
            
            self.addChild(pageVC)
            self.view.addSubview(pageVC.view)
            pageVC.didMove(toParent: self)
        }
        if let btn = self.closeButton {
            btn.layer.cornerRadius = CGFloat(10)
            self.view.bringSubviewToFront(btn)
        }
    }
    
    @IBAction func close(_ sender: Any) {
        let ud = UserDefaults.standard
        ud.setValue(true, forKey: "tutorial")
        self.presentingViewController?.dismiss(animated: true)
    }
    
    private func getContentsVC(index: Int) -> ContentsViewController? {
        guard index >= 0, index < imageNames.count else {
            return nil
        }
        
        guard let vc = self.initTutorialVC(withIdentifier: "Contents") as? ContentsViewController else {
            return nil
        }
        
        vc.contentTitle = contentsTitles[index]
        vc.imageName = imageNames[index]
        vc.index = index
        
        return vc
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard var index = (viewController as? ContentsViewController)?.index else {
            return nil
        }
        
        guard index > 0 else {
            return nil
        }
        
        index -= 1
        return self.getContentsVC(index: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard var index = (viewController as? ContentsViewController)?.index else {
            return nil
        }
        
        guard index < self.imageNames.count - 1 else {
            return nil
        }
        
        index += 1
        return self.getContentsVC(index: index)
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.imageNames.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
}
