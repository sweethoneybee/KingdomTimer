//
//  AddTaskTimerViewController.swift
//  KingdomTimer
//
//  Created by 정성훈 on 2021/02/25.
//

import UIKit
import CoreData

struct TimerData {
    var title: String = "새로운임시타이틀"
    var count: Int = 1
    var requiringHour: Int = 0
    var requiringMin: Int = 0
    var requiringSecond: Int = 0
    var wholeMin: Int {
        return self.requiringMin * self.count
    }
    var wholeSecond: Int {
        return self.requiringSecond * self.count
    }
    private var wholeTime: Int {
        return (self.wholeHour * 60 * 60
                    + self.wholeMin * 60
                    + self.wholeSecond)
    }
    var wholeHour: Int {
        return self.requiringHour * self.count
    }
    var requiringTimeToString: String {
        return "\(self.requiringHour)시간 \(self.requiringMin)분 \(self.requiringSecond)초"
    }
    var wholeTimeToString: String {
        return "총 \(self.wholeHour)시간 \(self.wholeMin)분 \(self.wholeSecond)초"
    }
    
    func makeTaskTimer(context: NSManagedObjectContext) -> TaskTimer {
        let stopwatchObject = TaskTimerEntity(context: AppDelegate.viewContext)
        
        let id = UserDefaults.standard.integer(forKey: "autoIncrement")
        stopwatchObject.id = Int64(id)
        UserDefaults.standard.set(id + 1, forKey: "autoIncrement")
        
        stopwatchObject.title = self.title
        stopwatchObject.interval = Int64(self.wholeTime)
        
        return TaskTimer(fetchedObject: stopwatchObject)
    }
}

class AddTaskTimerViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate {

    private var timerData = TimerData()
    private var timePickerData = [[Int]]()
    
    @IBOutlet weak var timeTf: UITextField?
    @IBOutlet weak var countLabel: UILabel?
    @IBOutlet weak var wholeTimeLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpTimePickerData()
        
        let timePicker = UIPickerView()
        timePicker.delegate = self
        self.timeTf?.inputView = timePicker
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 0, height: 35))
        let done = UIBarButtonItem()
        done.title = "완료"
        done.target = self
        done.action = #selector(timePickerDone(_:))
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([flexibleSpace, done], animated: true)
        self.timeTf?.inputAccessoryView = toolBar
    }
    
    @objc func timePickerDone(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    private func setUpTimePickerData() {
        let hours = Array<Int>(0...240)
        self.timePickerData.append(hours)
        
        let mins = Array<Int>(0...59)
        self.timePickerData.append(mins)
        
        let seconds = Array<Int>(0...59)
        self.timePickerData.append(seconds)
    }
    
    @IBAction func addTaskTimer() {
        if let vc = self.navigationController?.viewControllers.first as? MainViewController {
            let stopwatch = self.timerData.makeTaskTimer(context: AppDelegate.viewContext)
            vc.stopwatches.append(stopwatch)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func countStepper(_ sender: UIStepper) {
        self.timerData.count = Int(sender.value)
        self.countLabel?.text = "\(self.timerData.count)개"
        self.wholeTimeLabel?.text = self.timerData.wholeTimeToString
    }
}

// MARK:- UIPickerView Protocols
extension AddTaskTimerViewController {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return self.timePickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.timePickerData[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(self.timePickerData[component][row])"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0: self.timerData.requiringHour = self.timePickerData[component][row]
        case 1: self.timerData.requiringMin = self.timePickerData[component][row]
        case 2: self.timerData.requiringSecond = self.timePickerData[component][row]
        default: ()
        }
        self.timeTf?.text = self.timerData.requiringTimeToString
        self.wholeTimeLabel?.text = self.timerData.wholeTimeToString
    }
}

// MARK:- UITextView Protocols
extension AddTaskTimerViewController {
    
}
