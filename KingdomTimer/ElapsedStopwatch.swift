import UIKit

// MARK:- ElapsedStopwatchStatus 열거형 정의
enum ElapsedStopwatchStatus {
    case idle
    case paused
    case going
    case finished
}

// MARK:- ElapsedStopwatch 클래스 정의
class ElapsedStopwatch {
    // MARK:- Properties
    var delegate: ElapsedStopwatchDelegate?
    private var REFRESH_INTERVAL = TimeInterval(1)
    var refreshInterval: TimeInterval {
        get {
            return self.REFRESH_INTERVAL
        }
        set (newRefreshInterval) {
            if (newRefreshInterval > 0.1) {
                self.REFRESH_INTERVAL = newRefreshInterval
            }
        }
    }
    var index: Int?
    var title: String
    var status: ElapsedStopwatchStatus = .idle
    var timer: Timer?
    var interval: TimeInterval
    lazy var finishDate = Date(timeIntervalSinceNow: self.savedLeftTime)
    private var savedLeftTime: TimeInterval // self.leftTime이 호출되어야 갱신되는 값
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
    
    // MARK:- Methods
    init(title: String, interval: TimeInterval) {
        self.title = title
        self.interval = interval
        self.savedLeftTime = interval
    }
    
    func start() {
        guard self.status == .idle || self.status == .paused else {
            print("ElapsedStopwatch.start 실패. 현재상태=\(self.status)")
            return
        }
        
        self.finishDate = Date(timeIntervalSinceNow: self.savedLeftTime)
        self.timer = scheduleTimer()
        timer?.fire()
        
        let oldStatus = self.status
        self.status = .going
        self.delegate?.DidChangeStatus(self, originalStatus: oldStatus, newStatus: self.status)
    }
    
    func pause() {
        guard self.status == .going else {
            print("ElapsedStopwatch.pause 실패. 현재상태=\(self.status)")
            return
        }
        
        self.timer?.invalidate()
        self.timer = nil
        
        let oldStatus = self.status
        self.status = .paused
        self.delegate?.DidChangeStatus(self, originalStatus: oldStatus, newStatus: self.status)
    }
    
    func finish() {
        guard self.status == .going else {
            print("ElapsedStopwatch.finish 실패. 현재상태=\(self.status)")
            return
        }
        
        let oldStatus = self.status
        self.status = .finished
        self.delegate?.DidChangeStatus(self, originalStatus: oldStatus, newStatus: self.status)
    }
    
    func reset() {
        guard self.status == .finished else {
            print("ElapsedStopwatch.reinit 실패. 현재상태=\(self.status)")
            return
        }
        
        self.savedLeftTime = self.interval
        
        let oldStatus = self.status
        self.status = .idle
        self.delegate?.DidChangeStatus(self, originalStatus: oldStatus, newStatus: self.status)
    }
    
    func startWithOptimization() {
        guard self.status == .going && self.timer == nil else {
            print("startWithOptimization 실패. 현재상태=\(self.status)")
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
        guard self.status == .going else {
            print("pauseWithOptimization 실패. 현재상태=\(self.status)")
            return
        }
        
        print("최적화 타이머 종료")
        self.timer?.invalidate()
        self.timer = nil
    }
    
    private func scheduleTimer() -> Timer {
        let timer = Timer.scheduledTimer(withTimeInterval: self.REFRESH_INTERVAL, repeats: true) { timer in
            if self.leftTime <= 0 {
                print("Timer 객체 invalidate")
                self.finish()
                timer.invalidate()
                self.timer = nil
            }
            self.delegate?.TimerDidTick(leftTime: self.leftTime)
        }
        timer.tolerance = self.REFRESH_INTERVAL * 0.1
        return timer
    }
}

// TODO:- UI 로직을 위해서 구현해야하는 델리게이트
protocol ElapsedStopwatchDelegate {
    func TimerDidTick(leftTime: TimeInterval)
    func DidChangeStatus(_ elapsedStopwatch: ElapsedStopwatch, originalStatus from: ElapsedStopwatchStatus, newStatus to: ElapsedStopwatchStatus)
}
