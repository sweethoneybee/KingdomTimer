import UIKit

class ElapsedStopwatchCell: UICollectionViewCell, ElapsedStopwatchDelegate {
    @IBOutlet var timerLabel: UILabel?
    
    func TimerDidTick(leftTime: TimeInterval) {
        let leftSecond: Int = Int(leftTime)
        self.timerLabel?.text = "\(leftSecond)"
    }
    
    func DidChangeStatus(_ elasedStopwatch: ElapsedStopwatch, originalStatus from: ElapsedStopwatchStatus, newStatus to: ElapsedStopwatchStatus) {
        
        print("DidChangeStatus from=.\(from) to=.\(to) ")
        switch (from, to) {
        case (.idle, .going):
            self.backgroundColor = CellBackgroundColor.going
        case (.going, .paused):
            self.backgroundColor = CellBackgroundColor.paused
        case (.paused, .going):
            self.backgroundColor = CellBackgroundColor.going
        case (.going, .finished):
            self.backgroundColor = CellBackgroundColor.finished
        case (.finished, .idle):
            self.backgroundColor = CellBackgroundColor.idle
            
            let defaultInterval = Int(elasedStopwatch.interval)
            self.timerLabel?.text = "\(defaultInterval)"
        default:
            ()
        }
    }
}

struct CellBackgroundColor {
    static let idle: UIColor = .gray
    static let going: UIColor = .green
    static let paused: UIColor = .blue
    static let finished: UIColor = .red
    
    static func backgroundColor(withStatus status: ElapsedStopwatchStatus) -> UIColor {
        switch status {
        case .idle:
            return self.idle
        case .going:
            return self.going
        case .paused:
            return self.paused
        case .finished:
            return self.finished
        }
    }
}
