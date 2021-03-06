//
//  AddTaskTimerViewController.swift
//  KingdomTimer
//
//  Created by 정성훈 on 2021/02/25.
//

import UIKit
import CoreData

class AddTaskTimerViewController: UIViewController {

    lazy var inputContainer = TimerDataInputContainer()
    
    private let MAX_TEXT_LENGTH = 20
    private var timePickerData = [[Int]]()
    
    @IBOutlet weak var titleTf: UITextField?
    @IBOutlet weak var timeTf: UITextField?
    @IBOutlet weak var countLabel: UILabel?
    @IBOutlet weak var wholeTimeLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleTf?.delegate = self
        
        let timePickerView = UIPickerView()
        timePickerView.delegate = self
        self.timeTf?.inputView = timePickerView
        self.timeTf?.delegate = self
        self.setTimePickerData()
        
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
    
    @IBAction func addTaskTimer() {
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
        
        if TaskTimerDAO().create(data: inputContainer) {
            let center = UNUserNotificationCenter.current()
            center.getNotificationSettings { settings in
                guard (settings.authorizationStatus == .notDetermined) else {
                    return
                }
                
                center.requestAuthorization(options: [.alert, .sound]){ granted, error in
                    if let error = error {
                        NSLog("user noti request auth error: %s", error.localizedDescription)
                    }
                }
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func countStep(_ sender: UIStepper) {
        self.inputContainer.count = Int(sender.value)
        self.countLabel?.text = "\(self.inputContainer.count)개"
        self.wholeTimeLabel?.text = self.inputContainer.wholeTimeToString
    }
}

// MARK:- UIPickerView DataSource, Delegate
extension AddTaskTimerViewController: UIPickerViewDataSource, UIPickerViewDelegate {
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
extension AddTaskTimerViewController: UITextFieldDelegate {
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

struct TimerDataInputContainer {
    var title: String = ""
    var count: Int = 1
    var requiringHour: Int = 0
    var requiringMin: Int = 0
    var requiringSecond: Int = 0
    var wholeTime: Int {
        return (self.requiringSecond
                    + self.requiringMin * 60
                    + self.requiringHour * 60 * 60) * self.count
    }
    var wholeSecond: Int {
        return self.wholeTime % 60
    }
    var wholeMin: Int {
        return (self.wholeTime - self.wholeSecond) / 60 % 60
    }
    var wholeHour: Int {
        return (self.wholeTime - self.wholeSecond) / (60 * 60)
    }
    var requiringTimeToString: String {
        return "\(self.requiringHour)시간 \(self.requiringMin)분 \(self.requiringSecond)초"
    }
    var wholeTimeToString: String {
        return "총 \(self.wholeHour)시간 \(self.wholeMin)분 \(self.wholeSecond)초"
    }
    
    init() {}
    init(timerData data: TimerData) {
        self.title = data.title
        self.count = data.count
        
        let seconds = Int(data.interval) / count
        self.requiringSecond = seconds % 60
        self.requiringMin = (seconds - self.requiringSecond) / 60 % 60
        self.requiringHour = (seconds - self.requiringSecond) / (60 * 60)
    }
}
