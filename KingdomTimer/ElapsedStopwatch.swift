import Foundation
import CoreData

// MARK:- ElapsedStopwatch 클래스 정의
class ElapsedStopwatch {
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
    private var id: Int {
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
    private var timer: Timer?
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
    
    var state: State {
        get {
            let state = self.entity.state
            return State.stateFrom(rawValue: state)
        }
        set (value) {
            self.entity.state = value.rawValue
        }
    }
    
    var leftTime: TimeInterval {
        switch self.state {
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
        let state = entity.state
        self.state = State.stateFrom(rawValue: state)
    }
    
    func start() {
        guard self.state == .idle || self.state == .paused else {
            print("ElapsedStopwatch.start 실패. 현재상태=\(self.state)")
            return
        }
        
        if self.state == .idle {
            self.finishDate = Date(timeIntervalSinceNow: self.interval)
        } else {
            self.finishDate = Date(timeIntervalSinceNow: self.savedLeftTime)
        }
        
        let oldState = self.state
        self.state = .going
        self.delegate?.DidChangeState(self, originalState: oldState, newState: self.state)
        
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
        guard self.state == .going else {
            print("ElapsedStopwatch.pause 실패. 현재상태=\(self.state)")
            return
        }
        
        self.timer?.invalidate()
        self.timer = nil
        self.savedLeftTime = self.leftTime
        
        let oldState = self.state
        self.state = .paused
        self.delegate?.DidChangeState(self, originalState: oldState, newState: self.state)
    }
    
    func finish() {
        guard self.state == .going else {
            print("ElapsedStopwatch.finish 실패. 현재상태=\(self.state)")
            return
        }
        
        let oldState = self.state
        self.state = .finished
        self.delegate?.DidChangeState(self, originalState: oldState, newState: self.state)
    }
    
    func reset() {
        guard self.state == .finished else {
            print("ElapsedStopwatch.reinit 실패. 현재상태=\(self.state)")
            return
        }
        
        self.savedLeftTime = self.interval
        
        let oldState = self.state
        self.state = .idle
        self.delegate?.DidChangeState(self, originalState: oldState, newState: self.state)
    }
    
    func startWithOptimization() {
        guard self.state == .going && self.timer == nil else {
            print("startWithOptimization 실패. 현재상태=\(self.state)")
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
        guard self.state == .going else {
            print("pauseWithOptimization 실패. 현재상태=\(self.state)")
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
    func DidChangeState(_ elapsedStopwatch: ElapsedStopwatch, originalState from: ElapsedStopwatch.State, newState to: ElapsedStopwatch.State)
}
