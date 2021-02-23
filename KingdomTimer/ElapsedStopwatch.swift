import UIKit
import CoreData

// MARK:- ElapsedStopwatchStatus 열거형 정의
enum ElapsedStopwatchStatus: String {
    case idle = "idle"
    case paused = "paused"
    case going = "going"
    case finished = "finished"
}

// MARK:- ElapsedStopwatch 클래스 정의
class ElapsedStopwatch {
    // MARK:- Properties
    private var entity: ElapsedStopwatchEntity
    private var REFRESH_INTERVAL = TimeInterval(1)
    // self.leftTime과 같다는 것을 보장하지 않음
    private var savedLeftTime: TimeInterval {
        get {
            return TimeInterval(self.entity.savedLeftTime)
        }
        set(value) {
            self.entity.savedLeftTime = Int64(value)
        }
    }
    
    var delegate: ElapsedStopwatchDelegate?
    var id: Int {
        get {
            return Int(self.entity.id)
        }
        set(value) {
            self.entity.id = Int64(value)
        }
    }
    
    var title: String {
        get {
            return self.entity.title ?? "이름불러오기실패"
        }
        set(value) {
            self.entity.title = value
        }
    }
    
    // TODO:- 타이머 분리하기
    var timer: Timer?
    var interval: TimeInterval {
        get {
            TimeInterval(self.entity.interval)
        }
        set(value) {
            self.entity.interval = Int64(value)
        }
    }
    
    var finishDate: Date {
        get {
            return self.entity.finishDate ?? Date(timeIntervalSinceNow: self.savedLeftTime)
        }
        set (value) {
            self.entity.finishDate = value
        }
    }
    
    var status: ElapsedStopwatchStatus {
        get {
            let status = self.entity.status
            switch status {
            case ElapsedStopwatchStatus.idle.rawValue:
                return .idle
            case ElapsedStopwatchStatus.going.rawValue:
                return .going
            case ElapsedStopwatchStatus.paused.rawValue:
                return .paused
            case ElapsedStopwatchStatus.finished.rawValue:
                return .finished
            default:
                return .idle
            }
        }
        set (value) {
            self.entity.status = value.rawValue
        }
    }
    
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
    
    var leftTime: TimeInterval {
        switch self.status {
        case .idle:
            return self.interval
        case .going:
            let NOW = Date()
            return self.finishDate.timeIntervalSince(NOW)
        case .paused:
            return self.savedLeftTime
        case .finished:
            return TimeInterval.zero
        }
    }
    
    // MARK:- Methods
    init(fetchedObject: ElapsedStopwatchEntity) {
        self.entity = fetchedObject
        print(fetchedObject.savedLeftTime)
        let status = entity.status
        switch status {
        case ElapsedStopwatchStatus.idle.rawValue:
            self.status = .idle
        case ElapsedStopwatchStatus.going.rawValue:
            self.status = .going
        case ElapsedStopwatchStatus.paused.rawValue:
            self.status = .paused
        case ElapsedStopwatchStatus.finished.rawValue:
            self.status = .finished
        default:
            self.status = .idle
        }
    }
    
    func start() {
        guard self.status == .idle || self.status == .paused else {
            print("ElapsedStopwatch.start 실패. 현재상태=\(self.status)")
            return
        }
        
        if self.status == .idle {
            self.finishDate = Date(timeIntervalSinceNow: self.interval)
        } else {
            self.finishDate = Date(timeIntervalSinceNow: self.savedLeftTime)
        }
        
        let oldStatus = self.status
        self.status = .going
        self.delegate?.DidChangeStatus(self, originalStatus: oldStatus, newStatus: self.status)
        
        // timer 블록에서는 finish()가 호출될 수 있는데 .going 상태에서만 호출 가능하기 때문에
        // 상태를 먼저 변경하고 타이머를 설정하는 것.
        if self.leftTime > 0 {
            self.timer = scheduleTimer()
            timer?.fire()
        } else {
            self.finish()
        }
    }
    
    func pause() {
        guard self.status == .going else {
            print("ElapsedStopwatch.pause 실패. 현재상태=\(self.status)")
            return
        }
        
        self.timer?.invalidate()
        self.timer = nil
        self.savedLeftTime = self.leftTime
        
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

// MARK:- UI 로직을 위해서 구현해야하는 델리게이트
protocol ElapsedStopwatchDelegate {
    func TimerDidTick(leftTime: TimeInterval)
    func DidChangeStatus(_ elapsedStopwatch: ElapsedStopwatch, originalStatus from: ElapsedStopwatchStatus, newStatus to: ElapsedStopwatchStatus)
}
