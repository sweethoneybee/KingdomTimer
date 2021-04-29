//
//  GitHubViewController.swift
//  KingdomTimer
//
//  Created by 정성훈 on 2021/03/03.
//

import UIKit
import SafariServices

class GithubViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func moveToGithubPage(_ sender: UIButton) {
        guard let url = URL(string: "https://github.com/sweethoneybee/KingdomTimer") else {
            return
        }
        
        let sf = SFSafariViewController(url: url)
        self.present(sf, animated: true)
    }
}
