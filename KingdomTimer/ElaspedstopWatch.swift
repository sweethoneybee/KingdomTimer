import UIKit

enum ElaspedStopwatchStatus {
    case idle
    case paused
    case going
    case finished
}

// MARK:- ToDo 클래스 정의
class ElaspedstopWatch {
    // MARK:- Properties
    let REFRESH_INTERVAL = TimeInterval(1)

    var isOn: Bool = false
    var isFinish: Bool = true
    var idx: Int?
    var title: String
    var timer: Timer?
    var timerLabel: UILabel?
    var interval: TimeInterval
    var finishDate: Date?
    var leftTime: TimeInterval {
        if self.status == .paused {
            return self.savedLeftTime
        }
        
        let now = Date()
        if let _interval = self.finishDate?.timeIntervalSince(now), _interval > 0 {
            self.savedLeftTime = _interval
            return self.savedLeftTime
        }
        
        self.savedLeftTime = TimeInterval(0)
        return self.savedLeftTime
    }
    private var savedLeftTime: TimeInterval // self.leftTime이 호출되어야 갱신되는 값
    
    var status: ElaspedStopwatchStatus {
        if self.isOn == false {
            if self.isFinish == true {
                return .idle
            } else {
                return .paused
            }
        } else {
            if self.isFinish == true {
                return .finished
            } else {
                return .going
            }
        }
    }
    
    // MARK:- Methods
    init(title: String, interval: TimeInterval) {
        self.title = title
        self.interval = interval
        self.savedLeftTime = interval
    }
    
    func start() -> Bool{
        // must not be ElaspedStopWatchStatus.going
        guard self.status != .going else {
            print("toDo.start 실패")
            return false
        }
        
        self.isOn = true
        self.isFinish = false
        self.finishDate = Date(timeIntervalSinceNow: self.savedLeftTime)
        
        self.timer = Timer.scheduledTimer(withTimeInterval: self.REFRESH_INTERVAL, repeats: true, block: refreshInterface(timer:))
        self.timer?.tolerance = self.REFRESH_INTERVAL * 0.1
        self.timer?.fire()
        
        return true
    }
    
    func pause() {
        // must be ElaspedStopWatchStatus.going
        guard self.status == .going else {
            print("toDo.pause 실패")
            return
        }
        
        self.isOn = false
        self.timer?.invalidate()
        self.timer = nil
    }
    
    func finish() {
        // must be ElaspedStopWatchStatus.going
        guard self.status == .going else {
            print("toDo.finish 실패. 현재 타이머 상태=\(self.status)")
            return
        }
        
        let leftSecond = Int(self.leftTime)
        self.timerLabel?.text = "\(leftSecond)초. 종료"
        self.isFinish = true
        // TODO:- 로직상 이부분은 나중에 지워야함. savedLeftTime은 reInit 함수에서 재설정.
        self.savedLeftTime = self.interval
    }
    
    func reInit() {
        // must be ElaspedStopWatchStatus.finished
        guard self.status == .finished else {
            print("toDo.reinit 실패")
            return
        }
        
        self.isOn = false
        self.isFinish = true
        self.savedLeftTime = self.interval
    }
    
    func startWithOptimization() {
        // must be ElaspedStopWatchStatus.going
        guard self.status == .going && self.timer == nil else {
            print("startWithOptimization 실패")
            return
        }
        
        print("최적화 타이머 시작")
        if self.leftTime <= 0 {
            
        } else {
            self.timer = Timer.scheduledTimer(withTimeInterval: self.REFRESH_INTERVAL, repeats: true, block: self.refreshInterface(timer:))
            self.timer?.tolerance = self.REFRESH_INTERVAL * 0.1
            self.timer?.fire()
        }
    }
    
    func pauseWithOptimization() {
        // must be ElaspedStopWatchStatus.going
        guard self.status == .going else {
            print("pauseWithOptimization 실패")
            return
        }
        
        print("최적화 타이머 종료")
        self.timer?.invalidate()
        self.timer = nil
    }
    
    func refreshInterface(timer: Timer) {
        if self.leftTime <= 0 {
            print("Timer 객체 invalidate")
            self.finish()
            timer.invalidate()
            self.timer = nil
            return
        } else {
            let leftSecond = Int(self.leftTime)
            self.timerLabel?.text = "\(leftSecond)초 남음"
            print("Timer 객체 반복")
        }
    }
    
    // TODO:- refreshInterface, finish 함수에서 라벨 변환에 사용될 함수
    func changeInterface() {
        
    }
}
