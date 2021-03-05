//
//  ContentsViewController.swift
//  KingdomTimer
//
//  Created by 정성훈 on 2021/03/03.
//

import UIKit

class ContentsViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var contentImage: UIImageView?
    
    var contentTitle: String?
    var imageName: String?
    var index: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleLabel?.text = contentTitle
        self.titleLabel?.sizeToFit()
        
        if let imageName = self.imageName {
            self.contentImage?.image = UIImage(named: imageName)
            self.contentImage?.contentMode = .scaleAspectFit
        }
    }
}
