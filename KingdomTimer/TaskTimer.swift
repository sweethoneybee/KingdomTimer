import Foundation
import CoreData

struct TimerData {
    var id = 0
    var title = ""
    var state = TaskTimer.State.idle
    var count = 1
    var savedLeftTime = TimeInterval.zero
    var interval = TimeInterval.zero
    lazy var finishDate = Date()
}

// MARK:- TaskTimer 클래스 정의
class TaskTimer {
    enum State: String {
        case idle = "idle"
        case paused = "paused"
        case going = "going"
        case finished = "finished"
        
        static func stateFrom(rawValue state: String?) -> State {
            switch state {
            case State.idle.rawValue:
                return .idle
            case State.going.rawValue:
                return .going
            case State.paused.rawValue:
                return .paused
            case State.finished.rawValue:
                return .finished
            default:
                return .idle
            }
        }
    }
    
    init(fetchedObject: TaskTimerEntity) {
        self.entity = fetchedObject
        
        self.timerData.id = Int(entity.id)
        self.timerData.title = entity.title ?? "이름불러오기실패"
        self.timerData.state = State.stateFrom(rawValue: entity.state)
        self.timerData.count = Int(entity.count)
        self.timerData.savedLeftTime = TimeInterval(entity.savedLeftTime)
        self.timerData.interval = TimeInterval(entity.interval)
        self.timerData.finishDate = entity.finishDate ?? Date()
    }
    
    deinit {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    // MARK:- Properties
    var entity: TaskTimerEntity
    private var REFRESH_INTERVAL = TimeInterval(1)
    var timerData = TimerData()
    
    var delegate: TaskTimerDelegate?
    var objectId: NSManagedObjectID {
        return self.entity.objectID
    }

    private var timer: Timer?
    
    var leftTime: TimeInterval {
        switch self.timerData.state {
        case .idle:
            return self.timerData.interval
        case .going:
            let NOW = Date()
            return self.timerData.finishDate.timeIntervalSince(NOW)
        case .paused:
            return self.timerData.savedLeftTime
        case .finished:
            return TimeInterval.zero
        }
    }
    
    // MARK:- Methods
    func start() {
        guard self.timerData.state == .idle || self.timerData.state == .paused else {
            print("ElapsedStopwatch.start 실패. 현재상태=\(self.timerData.state)")
            return
        }
        
        if self.timerData.state == .idle {
            self.timerData.finishDate = Date(timeIntervalSinceNow: self.timerData.interval)
        } else {
            self.timerData.finishDate = Date(timeIntervalSinceNow: self.timerData.savedLeftTime)
        }
        self.entity.finishDate = self.timerData.finishDate
        
        let oldState = self.timerData.state
        self.timerData.state = .going
        self.delegate?.DidChangeState(self, originalState: oldState, newState: self.timerData.state)
        self.entity.state = self.timerData.state.rawValue
        
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
        guard self.timerData.state == .going else {
            print("ElapsedStopwatch.pause 실패. 현재상태=\(self.timerData.state)")
            return
        }
        
        self.timer?.invalidate()
        self.timer = nil
        self.timerData.savedLeftTime = self.leftTime
        self.entity.savedLeftTime = Int64(self.timerData.savedLeftTime)
        
        let oldState = self.timerData.state
        self.timerData.state = .paused
        self.delegate?.DidChangeState(self, originalState: oldState, newState: self.timerData.state)
        self.entity.state = self.timerData.state.rawValue
    }
    
    func finish() {
        guard self.timerData.state == .going else {
            print("ElapsedStopwatch.finish 실패. 현재상태=\(self.timerData.state)")
            return
        }
        
        let oldState = self.timerData.state
        self.timerData.state = .finished
        self.delegate?.DidChangeState(self, originalState: oldState, newState: self.timerData.state)
        self.entity.state = self.timerData.state.rawValue
    }
    
    func reset() {
        self.timerData.savedLeftTime = self.timerData.interval
        self.entity.savedLeftTime = Int64(self.timerData.interval)
        
        self.timer?.invalidate()
        self.timer = nil
        
        let oldState = self.timerData.state
        self.timerData.state = .idle
        self.delegate?.DidChangeState(self, originalState: oldState, newState: self.timerData.state)
        self.entity.state = self.timerData.state.rawValue
    }
    
    func startWithOptimization() {
        guard self.timerData.state == .going && self.timer == nil else {
            return
        }
        
        if self.leftTime > 0 {
            self.timer = scheduleTimer()
            timer?.fire()
        } else {
            self.finish()
        }
    }
    
    func pauseWithOptimization() {
        guard self.timerData.state == .going else {
            return
        }
        
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
    
    func reflectEditedChangesOnEntity() {
        self.entity.title = self.timerData.title
        self.entity.count = Int64(self.timerData.count)
        self.entity.interval = Int64(self.timerData.interval)
    }
}

// MARK:- UI 로직을 위해서 구현해야하는 델리게이트
protocol TaskTimerDelegate {
    func TimerDidTick(leftTime: TimeInterval)
    func DidChangeState(_ taskTimer: TaskTimer, originalState from: TaskTimer.State, newState to: TaskTimer.State)
}
