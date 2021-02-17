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
    var index: Int?
    var title: String
    var status: ElaspedStopwatchStatus = .idle
    var timer: Timer?
    var timerLabel: UILabel?
    var interval: TimeInterval
    lazy var finishDate = Date(timeIntervalSinceNow: self.savedLeftTime)
    var leftTime: TimeInterval {
        if self.status == .paused {
            return self.savedLeftTime
        }
        
        let NOW = Date()
        let _interval = self.finishDate.timeIntervalSince(NOW)
        if _interval > 0 {
            self.savedLeftTime = _interval
            return self.savedLeftTime
        } else {
            self.savedLeftTime = TimeInterval(0)
            return self.savedLeftTime
        }
    }
    private var savedLeftTime: TimeInterval // self.leftTime이 호출되어야 갱신되는 값
    
    // MARK:- Methods
    init(title: String, interval: TimeInterval) {
        self.title = title
        self.interval = interval
        self.savedLeftTime = interval
    }
    
    func start() {
        guard self.status == .idle || self.status == .paused else {
            print("toDo.start 실패")
            return
        }
        
        self.status = .going
        self.finishDate = Date(timeIntervalSinceNow: self.savedLeftTime)
        self.timer = scheduleTimer()
        timer?.fire()
    }
    
    func pause() {
        guard self.status == .going else {
            print("toDo.pause 실패")
            return
        }
        
        self.status = .paused
        self.timer?.invalidate()
        self.timer = nil
    }
    
    func finish() {
        guard self.status == .going else {
            print("toDo.finish 실패. 현재 타이머 상태=\(self.status)")
            return
        }
        
        self.status = .finished
        
        // TODO:- changeInterface 함수로 구현할 것
        let leftSecond = Int(self.leftTime)
        self.timerLabel?.text = "\(leftSecond)초. 종료"
        
        // TODO:- 로직상 이부분은 나중에 지워야함. savedLeftTime은 reInit 함수에서 재설정.
        self.savedLeftTime = self.interval
    }
    
    func reInit() {
        // must be ElaspedStopWatchStatus.finished
        guard self.status == .finished else {
            print("toDo.reinit 실패")
            return
        }
        
        self.status = .idle
        self.savedLeftTime = self.interval
    }
    
    func startWithOptimization() {
        // must be ElaspedStopWatchStatus.going
        guard self.status == .going && self.timer == nil else {
            print("startWithOptimization 실패")
            return
        }
        
        print("최적화 타이머 시작")
        if self.leftTime > 0 {
            self.timer = scheduleTimer()
            timer?.fire()
        } else {
            self.finish()
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
    
    func scheduleTimer() -> Timer {
        let timer = Timer.scheduledTimer(withTimeInterval: self.REFRESH_INTERVAL, repeats: true, block: self.timerBlock(timer:))
        timer.tolerance = self.REFRESH_INTERVAL * 0.1
        return timer
    }
    
    func timerBlock(timer: Timer) {
        if self.leftTime > 0 {
            // TODO:- changeInterface 함수 호출해야함
            let leftSecond = Int(self.leftTime)
            self.timerLabel?.text = "\(leftSecond)초 남음"
            print("Timer 객체 반복")
        } else {
            print("Timer 객체 invalidate")
            self.finish()
            timer.invalidate()
            self.timer = nil
        }
    }
    
    // TODO:- refreshInterface, finish 함수에서 라벨 변환에 사용될 함수
    func changeInterface() {
        
    }
}
