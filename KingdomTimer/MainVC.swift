import UIKit

class MainVC: UIViewController {
    var stopwatches = [ElapsedStopwatch]()
    var labels = [UILabel]()
    var labelIndex = 0
    var nextLabelY: Int = 400
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.makeTestEnv()
    }
}

// MARK:- 테스트환경 조성용 코드
extension MainVC {
    func makeTestEnv() {
        let CENTER_WIDTH =  self.view.frame.width / 2
        
        let makeBtn = makeTestButton(center: CGPoint(x: CENTER_WIDTH, y: 100), title: "5초짜리 타이머 생성하고 등록")
        makeBtn.addTarget(self, action: #selector(addStopwatch(_:)), for: .touchUpInside)
        self.view.addSubview(makeBtn)
        
        let startBtn = makeTestButton(center: CGPoint(x: CENTER_WIDTH, y: 150), title: "타이머 시작")
        startBtn.addTarget(self, action: #selector(startStopwatches(_:)), for: .touchUpInside)
        self.view.addSubview(startBtn)
        
        let pauseBtn = makeTestButton(center: CGPoint(x: CENTER_WIDTH, y: 200), title: "타이머 전부 중단")
        pauseBtn.addTarget(self, action: #selector(pauseStopwatches), for: .touchUpInside)
        self.view.addSubview(pauseBtn)
        
        let startWithOptimizationBtn = makeTestButton(center: CGPoint(x: CENTER_WIDTH, y: 250), title: "최적화를 위해 시작")
        startWithOptimizationBtn.addTarget(self, action: #selector(startWithOptimizationStopwatches(_:)), for: .touchUpInside)
        self.view.addSubview(startWithOptimizationBtn)
        
        let pauseWithOptimizationBtn = makeTestButton(center: CGPoint(x: CENTER_WIDTH, y: 300), title: "최적화를 위해 중단")
        pauseWithOptimizationBtn.addTarget(self, action: #selector(pauseWithOptimizationStopwatches(_:)), for: .touchUpInside)
        self.view.addSubview(pauseWithOptimizationBtn)
        
        let reInitBtn = makeTestButton(center: CGPoint(x: CENTER_WIDTH, y: 350), title: "타이머초기화")
        reInitBtn.addTarget(self, action: #selector(reInit(_:)), for: .touchUpInside)
        self.view.addSubview(reInitBtn)
    }
    
    @objc func addStopwatch(_ sender: Any) {
        self.makeTestLabel()
        let task = ElapsedStopwatch(title: "임시", interval: TimeInterval(5))
        task.timerLabel = self.labels[self.labelIndex]
        self.labelIndex += 1
        self.stopwatches.append(task)
        
        print("등록된 타이머 개수=\(self.stopwatches.count)")
    }
    
    @objc func startStopwatches(_ sender: Any) {
        print("시작할 타이머 개수=\(self.stopwatches.count)")
        for stopWatch in self.stopwatches {
            stopWatch.start()
        }
    }
    
    @objc func pauseStopwatches(_ sender: Any) {
        print("멈출 타이머 개수=\(self.stopwatches.count)")
        for stopwatch in self.stopwatches {
            stopwatch.pause()
        }
    }
    
    @objc func startWithOptimizationStopwatches(_ sender: Any) {
        print("최적화를 다시 시작할 타이머 개수=\(self.stopwatches.count)")
        for stopwatch in self.stopwatches {
            stopwatch.startWithOptimization()
        }
    }
    
    @objc func pauseWithOptimizationStopwatches(_ sender: Any) {
        print("최적화를 위해 중단할 타이머 개수=\(self.stopwatches.count)")
        for stopwatch in self.stopwatches {
            stopwatch.pauseWithOptimization()
        }
    }
    
    @objc func reInit(_ sender: Any) {
        for stopwatch in self.stopwatches {
            stopwatch.reInit()
        }
    }
    func makeTestButton(center: CGPoint, title: String) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        btn.center = center
        btn.sizeToFit()
        return btn
    }

    func makeTestLabel() {
        let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        lbl.font = .systemFont(ofSize: 18)
        lbl.textAlignment = .center
        lbl.center = CGPoint(x: self.view.frame.width / 2, y: CGFloat(nextLabelY))
        self.nextLabelY += 50
        
        self.labels.append(lbl)
        lbl.text = "\(self.labels.count)번째 테스트 라벨"
        lbl.sizeToFit()
        
        self.view.addSubview(lbl)
    }
}
