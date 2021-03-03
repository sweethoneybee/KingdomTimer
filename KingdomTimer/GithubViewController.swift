//
//  GitHubViewController.swift
//  KingdomTimer
//
//  Created by 정성훈 on 2021/03/03.
//

import UIKit
import SafariServices

class GithubViewController: UIViewController {
    @IBOutlet weak var githubLink: UIButton?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.githubLink?.addTarget(self, action: #selector(moveToGithubPage(_:)), for: .touchUpInside)
    }
    
    @objc func moveToGithubPage(_ sender: Any) {
        print("클릭")
        guard let url = URL(string: githubLink?.title(for: .normal)
                                ?? "https://github.com/sweethoneybee") else {
            return
        }
        
        let sf = SFSafariViewController(url: url)
        self.present(sf, animated: true)
    }
}
