//
//  EditTaskTimerController.swift
//  KingdomTimer
//
//  Created by 정성훈 on 2021/02/27.
//

import UIKit

class EditTaskTimerViewController: UIViewController {
    
    var taskTimerArgument: TaskTimer?
    lazy var inputContainer = TimerDataInputContainer()

    private let MAX_TEXT_LENGTH = 20
    private var timePickerData = [[Int]]()
    
    @IBOutlet weak var titleTf: UITextField?
    @IBOutlet weak var timeTf: UITextField?
    @IBOutlet weak var countStepper: UIStepper?
    @IBOutlet weak var countLabel: UILabel?
    @IBOutlet weak var wholeTimeLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleTf?.delegate = self
        
        let timePicker = UIPickerView()
        timePicker.delegate = self
        self.timeTf?.inputView = timePicker
        self.timeTf?.delegate = self
        self.setTimePickerData()
        
        if let taskTimer = taskTimerArgument {
            self.inputContainer = TimerDataInputContainer(timerData: taskTimer.timerData)
            
            timePicker.selectRow(self.inputContainer.requiringHour, inComponent: 0, animated: true)
            timePicker.selectRow(self.inputContainer.requiringMin, inComponent: 1, animated: true)
            timePicker.selectRow(self.inputContainer.requiringSecond, inComponent: 2, animated: true)
            
            self.timeTf?.text = self.inputContainer.requiringTimeToString
            self.titleTf?.text = self.inputContainer.title
            
            self.countStepper?.value = Double(self.inputContainer.count)
            self.countLabel?.text = "\(self.inputContainer.count)개"
            
            self.wholeTimeLabel?.text = self.inputContainer.wholeTimeToString
        }

        self.setUI()
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChange(_:)), name: UITextField.textDidChangeNotification, object: nil)
    }
    
    private func setTimePickerData() {
        let hours = Array<Int>(0...240)
        self.timePickerData.append(hours)
        
        let mins = Array<Int>(0...59)
        self.timePickerData.append(mins)
        
        let seconds = Array<Int>(0...59)
        self.timePickerData.append(seconds)
    }
    
    private func setUI() {
        let finishButton = UIBarButtonItem(title: "수정", style: .done, target: self, action: #selector(finishEditing))
        self.navigationItem.rightBarButtonItem = finishButton
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 0, height: 35))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(timePickerDone(_:)))
        toolBar.setItems([flexibleSpace, done], animated: true)
        self.timeTf?.inputAccessoryView = toolBar
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK:- Methods
    @objc func timePickerDone(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    @objc func finishEditing() {
        self.view.endEditing(true)
        guard self.inputContainer.title != "" else {
            let alert = UIAlertController.makeSimpleAlert(message: "이름을 적어주세요")
            self.present(alert, animated: true)
            return
        }
        
        guard self.inputContainer.wholeTime > 0 else {
            let alert = UIAlertController.makeSimpleAlert(message: "시간을 설정해주세요")
            self.present(alert, animated: true)
            return
        }
        
        if let tT = taskTimerArgument {
            TaskTimerDAO().update(target: tT.managedObject, data: self.inputContainer)
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
    
    @IBAction func countStep(_ sender: UIStepper) {
        self.inputContainer.count = Int(sender.value)
        self.countLabel?.text = "\(self.inputContainer.count)개"
        self.wholeTimeLabel?.text = self.inputContainer.wholeTimeToString
    }
}

// MARK: - UIPickerView DataSource, Delegate
extension EditTaskTimerViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return self.timePickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.timePickerData[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return "\(self.timePickerData[component][row]) 시간"
        case 1:
            return "\(self.timePickerData[component][row]) 분"
        case 2:
            return "\(self.timePickerData[component][row]) 초"
        default:
            return "오류"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0: self.inputContainer.requiringHour = self.timePickerData[component][row]
        case 1: self.inputContainer.requiringMin = self.timePickerData[component][row]
        case 2: self.inputContainer.requiringSecond = self.timePickerData[component][row]
        default: ()
        }
        self.timeTf?.text = self.inputContainer.requiringTimeToString
        self.wholeTimeLabel?.text = self.inputContainer.wholeTimeToString
    }
}

// MARK:- UITextField Delegate
extension EditTaskTimerViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField === self.timeTf {
            textField.backgroundColor = UIColor.fromRGB(rgbValue: 0x8595a1, alpha: 0.2)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField === self.timeTf {
            textField.backgroundColor = UIColor.clear
        }
        
        if textField === self.titleTf, let text = textField.text {
            self.inputContainer.title = text.trimmingCharacters(in: .whitespacesAndNewlines)
            textField.text = inputContainer.title
        }
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField === self.timeTf {
            return false
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func textFieldDidChange(_ notification: Notification) {
        guard let textField = notification.object as? UITextField else {
            return
        }
        if var text = textField.text, text.count > self.MAX_TEXT_LENGTH {
            text.removeLast(text.count - self.MAX_TEXT_LENGTH)
            textField.text = text
        }
        
    }
}
