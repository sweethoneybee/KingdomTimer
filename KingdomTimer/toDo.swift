import UIKit

enum toDoStatus {
    case normal
    case paused
    case started
    case finished
}

class toDo {
    var idx: Int?
    var title: String
    var isOn: Bool = false
    var isFinish: Bool = true
    var finishTime: Date?
    var interval: TimeInterval
    var savedLeftTime = TimeInterval(0)
    var leftTime: TimeInterval {
        if self.status == .paused {
            return self.savedLeftTime
        }
        
        let now = Date()
        if let _interval = self.finishTime?.timeIntervalSince(now), _interval > 0 {
            self.savedLeftTime = _interval
            return self.savedLeftTime
        }
        
        self.savedLeftTime = TimeInterval(0)
        return self.savedLeftTime
    }
    var leftSecond: Int {
        return Int(self.leftTime)
    }
    var status: toDoStatus {
        if self.isOn == false {
            if self.isFinish == true {
                return .normal
            } else {
                return .paused
            }
        } else {
            if self.isFinish == true {
                return .finished
            } else {
                return .started
            }
        }
    }
    
    init(title: String, interval: TimeInterval) {
        self.title = title
        self.interval = interval
    }
    
    func start() {
        guard self.isOn == false && self.isFinish == true else {
            return
        }
        
        self.isOn = true
        self.isFinish = false
        self.finishTime = Date(timeIntervalSinceNow: self.interval)
    }
    
    func pause() {
        guard self.isOn == true && self.isFinish == false else {
            return
        }
        
        self.isOn = false
    }
    
    func finish() {
        guard self.isOn == true && self.isFinish == false else {
            return
        }
        
        self.isFinish = true
    }
    
    func reInit() {
        self.isOn = false
        self.isFinish = true
    }
}
