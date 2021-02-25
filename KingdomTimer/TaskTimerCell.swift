import UIKit

class TaskTimerCell: UICollectionViewCell, TaskTimerDelegate {
    
    @IBOutlet var stateLabel: UILabel?
    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var timeLabel: UILabel?
    
    func TimerDidTick(leftTime: TimeInterval) {
        self.timeLabel?.text = TaskTimerCell.textLeftTime(left: leftTime)
    }
    
    func DidChangeState(_ elasedStopwatch: TaskTimer, originalState from: TaskTimer.State, newState to: TaskTimer.State) {

        print("DidChangeStatus from=.\(from) to=.\(to) ")
        
        self.stateLabel?.text = TaskTimerCell.changeStateToString(state: to)
        switch (from, to) {
        case (.idle, .going):
            self.contentView.backgroundColor = CellBackgroundColor.going
        case (.going, .paused):
            self.contentView.backgroundColor = CellBackgroundColor.paused
        case (.paused, .going):
            self.contentView.backgroundColor = CellBackgroundColor.going
        case (.going, .finished):
            self.contentView.backgroundColor = CellBackgroundColor.finished
        case (.finished, .idle):
            self.contentView.backgroundColor = CellBackgroundColor.idle

            let defaultInterval = elasedStopwatch.interval
            self.timeLabel?.text = TaskTimerCell.textLeftTime(left: defaultInterval)
        default:
            ()
        }
    }
    
    static func changeStateToString(state: TaskTimer.State) -> String {
        switch state {
        case .idle:
            return "[대기]"
        case .going:
            return "[진행중]"
        case .paused:
            return "[일시중지]"
        case .finished:
            return "[완료]"
        }
    }
    
    static func textLeftTime(left: TimeInterval) -> String {
        let pureSecond = Int(left)
        
        let sec = pureSecond % 60
        let min = (pureSecond - sec) / 60 % 60
        let hour = (pureSecond - sec) / (60 * 60)
        
        return (hour == 0 ? "" : "\(hour)시간 " )
            + (min == 0 ? "" : "\(min)분 ")
            + "\(sec)초"
    }
}

struct CellBackgroundColor {
    static let idle: UIColor = UIColor.fromRGB(rgbValue: 0xdeeed6)
    static let going: UIColor = UIColor.fromRGB(rgbValue: 0x6daa2c)
    static let paused: UIColor = UIColor.fromRGB(rgbValue: 0xdad45e)
    static let finished: UIColor = UIColor.fromRGB(rgbValue: 0xd04648)
    
    static func backgroundColor(withState state: TaskTimer.State) -> UIColor {
        switch state {
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
