import UIKit

class MainVC: UIViewController {
    var time: Date!
    var task: toDo!
    var lbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.time = Date(timeInterval: TimeInterval(100), since: Date())
        print("self.time = \(self.time!)")
        
        
        let btn = UIButton(type: .system)
        btn.setTitle("타이머 5초 시작", for: .normal)
        btn.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        btn.center = CGPoint(x: self.view.frame.width / 2, y: 100)
        btn.addTarget(self, action: #selector(startTimer(_:)), for: .touchUpInside)
        btn.sizeToFit()
        
        self.view.addSubview(btn)
        
        self.lbl = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        self.lbl.font = .systemFont(ofSize: 18)
        self.lbl.textAlignment = .center
        self.lbl.center = CGPoint(x: self.view.frame.width / 2, y: 400)
        self.lbl.text = "임시 텍스트"
        
        self.view.addSubview(self.lbl)
        
        
    }
    
    @objc func startTimer(_ sender: Any) {
        self.task = toDo(title: "임시", interval: TimeInterval(5))
        self.lbl.text = "\(self.task.leftSecond)초 남았습니다"
        self.task.start()
        self.addTimer(task: self.task)
    }

    @objc func timerBlock(_ timer: Timer) {
        if let task = timer.userInfo as? toDo {
            self.lbl.text = "\(task.leftSecond)초 남았습니다"
            if task.leftSecond <= 0 {
                print("종료")
                timer.invalidate()
                return
            }
            print("반복")
        }
    }

    // TODO: 인자에 NSArray 추가해서 timer 추가해주기
    func addTimer(task: toDo) {
        let timer = Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(timerBlock(_:)), userInfo: task, repeats: true)
    }
}
