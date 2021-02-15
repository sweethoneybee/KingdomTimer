import UIKit

class toDo {
    var idx: Int?
    var title: String
    var isOn: Bool = false
    var isFinish: Bool = false
    var finishTime: Date?
    var leftTime: TimeInterval {
        let now = Date()
        if let _interval = self.finishTime?.timeIntervalSince(now), _interval > 0 {
            return _interval
        }
        return 0
    }
    var interval: TimeInterval
    
    init(title: String, interval: TimeInterval) {
        self.title = title
        self.interval = interval
    }
    
    func getStart() {
        guard self.isOn == false else {
            return
        }
        
        self.isOn = true
        self.finishTime = Date(timeIntervalSinceNow: self.interval)
    }
    
    func getStop() {
        guard self.isOn == true else {
            return
        }
        
        self.isOn = false
    }
    
    func getFinish() {
        guard self.isOn == true else {
            return
        }
        
        self.isFinish = true
    }
}
