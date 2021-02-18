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
    let REFRESH_INTERVAL = TimeInterval(1)
    var index: Int?
    var title: String
    var status: ElapsedStopwatchStatus = .idle
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
    var delegate: ElapsedStopwatchDelegate?
    
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
        
        self.delegate?.willChangeStatus(from: self.status, to: .going)
        self.status = .going
        self.finishDate = Date(timeIntervalSinceNow: self.savedLeftTime)
        self.timer = scheduleTimer()
        timer?.fire()
    }
    
    func pause() {
        guard self.status == .going else {
            print("ElapsedStopwatch.pause 실패. 현재상태=\(self.status)")
            return
        }
        
        self.delegate?.willChangeStatus(from: self.status, to: .paused)
        self.status = .paused
        self.timer?.invalidate()
        self.timer = nil
    }
    
    func finish() {
        guard self.status == .going else {
            print("ElapsedStopwatch.finish 실패. 현재상태=\(self.status)")
            return
        }
        
        self.delegate?.willChangeStatus(from: self.status, to: .finished)
        self.status = .finished
    }
    
    func reInit() {
        guard self.status == .finished else {
            print("ElapsedStopwatch.reinit 실패. 현재상태=\(self.status)")
            return
        }
        
        self.delegate?.willChangeStatus(from: self.status, to: .idle)
        self.status = .idle
        self.savedLeftTime = self.interval
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
            self.delegate?.ElapsedStopwatch(leftTime: self.leftTime)
            if self.leftTime <= 0 {
                print("Timer 객체 invalidate")
                self.finish()
                timer.invalidate()
                self.timer = nil
            }
        }
        timer.tolerance = self.REFRESH_INTERVAL * 0.1
        return timer
    }
}

// TODO:- UI 로직을 위해서 구현해야하는 델리게이트
protocol ElapsedStopwatchDelegate {
    func ElapsedStopwatch(leftTime: TimeInterval)
    func willChangeStatus(from: ElapsedStopwatchStatus, to: ElapsedStopwatchStatus)
}
