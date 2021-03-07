//
//  SettingViewController.swift
//  KingdomTimer
//
//  Created by 정성훈 on 2021/03/03.
//

import UIKit

class SettingViewController: UITableViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                print("사용법 클릭")
                if let tutorialVC = self.initTutorialVC(withIdentifier: "Master") as? TutorialMasterViewController {
                    tutorialVC.modalPresentationStyle = .fullScreen
                    self.present(tutorialVC, animated: true)
                }
            } else if indexPath.row == 1 {
                print("개발자 깃허브 클릭")
                
                guard let githubVC = self.storyboard?.instantiateViewController(withIdentifier: "Github") as? GithubViewController else {
                    return
                }
                
                githubVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(githubVC, animated: true)
            }
        }
        
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                let resetAlert = UIAlertController(title: nil, message: "모든 타이머를 삭제하겠습니까?", preferredStyle: .alert)
                resetAlert.addAction(UIAlertAction(title: "취소", style: .cancel))
                resetAlert.addAction(UIAlertAction(title: "네", style: .destructive){ action in
                    let taskTimerDao = TaskTimerDAO()
                    if taskTimerDao.deleteAll() {
                        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                        let finishAlert = UIAlertController(title: nil, message: "모든 타이머 삭제 완료", preferredStyle: .alert)
                        finishAlert.addAction(UIAlertAction(title: "확인", style: .default))
                        self.present(finishAlert, animated: true)
                    } else {
                        let finishAlert = UIAlertController(title: nil, message: "삭제를 실패하였습니다", preferredStyle: .alert)
                        finishAlert.addAction(UIAlertAction(title: "확인", style: .default))
                        self.present(finishAlert, animated: true)
                    }
                })
                self.present(resetAlert, animated: true)
            }
        }
    }
}
