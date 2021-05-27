//
//  EditTaskTimerController.swift
//  KingdomTimer
//
//  Created by 정성훈 on 2021/02/27.
//

import UIKit

class EditTaskTimerViewController: AddTaskTimerViewController {
    private lazy var taskTimerDao = TaskTimerDAO()
    var taskTimer: TaskTimer?
    @IBOutlet weak var countStepper: UIStepper?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let tT = taskTimer {
            self.inputContainer = TimerDataInputContainer(timerData: tT.timerData)
            self.timePicker?.selectRow(self.inputContainer.requiringHour, inComponent: 0, animated: true)
            self.timePicker?.selectRow(self.inputContainer.requiringMin, inComponent: 1, animated: true)
            self.timePicker?.selectRow(self.inputContainer.requiringSecond, inComponent: 2, animated: true)
        }
        
        let finishButton = UIBarButtonItem()
        finishButton.title = "수정"
        finishButton.target = self
        finishButton.action = #selector(finishEditing)
        
        self.navigationItem.rightBarButtonItem = finishButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.timeTf?.text = self.inputContainer.requiringTimeToString
        self.titleTf?.text = self.inputContainer.title
        
        self.countStepper?.value = Double(self.inputContainer.count)
        self.countLabel?.text = "\(self.inputContainer.count)개"
        
        self.wholeTimeLabel?.text = self.inputContainer.wholeTimeToString
    }
    
    @objc func finishEditing() {
        self.view.endEditing(true)
        guard self.inputContainer.title != "" else {
            let alert = self.makeSimpleAlert(message: "이름을 적어주세요")
            self.present(alert, animated: true)
            return
        }
        
        guard self.inputContainer.wholeTime > 0 else {
            let alert = self.makeSimpleAlert(message: "시간을 설정해주세요")
            self.present(alert, animated: true)
            return
        }
        
        if let tT = taskTimer {
            self.taskTimerDao.update(target: tT.managedObject, data: self.inputContainer)
            tT.reset()
            
            UNUserNotificationCenter.current().deleteLocalPush(data: tT.timerData)
            
            self.navigationController?.popViewController(animated: true)
        } else {
            let alert = UIAlertController(title: "편집 실패", message: "변경 사항을 저장하지 못했습니다", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default){ action in
                self.navigationController?.popViewController(animated: true)
            })
            self.present(alert, animated: true)
        }
    }
}
