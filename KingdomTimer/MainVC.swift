import UIKit

class MainVC: UIViewController {
    // for test
    var labels = [UILabel]()
    var labelIndex = 0
    var nextLabelY: Int = 400

    var stopwatches = [ElapsedStopwatch]()
    @IBOutlet var collectionView: UICollectionView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let item = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addStopwatch(_:)))
        self.navigationItem.rightBarButtonItem = item
        
        
        let flowLayout: UICollectionViewFlowLayout
        flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = CGFloat(10)
        flowLayout.minimumLineSpacing = CGFloat(10)
        
        let width = UIScreen.main.bounds.width
        flowLayout.itemSize = CGSize(width: width * 0.28, height: width * 0.28)
        
        let inset = width * 0.02
        flowLayout.sectionInset = UIEdgeInsets(top: CGFloat(inset), left: CGFloat(inset), bottom: CGFloat(inset), right: CGFloat(inset))
        
        self.collectionView?.collectionViewLayout = flowLayout
        
        // for natural content shrinking animation
        self.collectionView?.delaysContentTouches = false
    }
}

extension MainVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stopwatches.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ElapsedStopwatchCell", for: indexPath) as? ElapsedStopwatchCell else {
            let errorCell = UICollectionViewCell()
            return errorCell
        }
        
        let stopwatch = self.stopwatches[indexPath.item]
        stopwatch.delegate = cell
        
        // 테스트
        cell.statusLabel?.text = ElapsedStopwatchCell.textStatus(status: stopwatch.status)
        cell.titleLabel?.text = "쫀득쫀득 잼파이 생산하는 걸 텍스트로 표현하고 싶은데 어디까지 작성해야할지 모르겠습니다"
        cell.timeLabel?.text = "133시간 35분 34초"
        
        /*
         * 실제
         cell.statusLabel?.text = ElapsedStopwatchCell.textStatus(status: stopwatch.status)
         cell.titleLabel?.text = stopwatch.title
         cell.timeLabel?.text = ElapsedStopwatchCell.textLeftTime(left: stopwatch.leftTime)
         */
        
        
        cell.contentView.backgroundColor = CellBackgroundColor.backgroundColor(withStatus: stopwatch.status)
        cell.contentView.layer.cornerRadius = CGFloat(20)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let stopwatch = self.stopwatches[indexPath.item]
        switch stopwatch.status {
        case .idle:
            stopwatch.start()
        case .going:
            stopwatch.pause()
        case .paused:
            stopwatch.start()
        case .finished:
            stopwatch.reset()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        print("하이라이트아이템=\(indexPath.item)")
        
        if let cell = collectionView.cellForItem(at: indexPath) as? ElapsedStopwatchCell {
            let pressedDownTransform = CGAffineTransform(scaleX: 0.98, y: 0.98)
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 3, options: [.curveEaseInOut], animations: { cell.transform = pressedDownTransform })
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        print("언하이라이트=\(indexPath.item)")
        
        if let cell = collectionView.cellForItem(at: indexPath) as? ElapsedStopwatchCell {
            let originalTransform = CGAffineTransform(scaleX: 1, y: 1)
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 3, options: [.curveEaseInOut], animations: { cell.transform = originalTransform })
        }
    }
    
    @objc func addStopwatch(_ sender: Any) {
        
        let task = ElapsedStopwatch(title: "임시", interval: TimeInterval(5))
        self.stopwatches.append(task)
        
        print("등록된 타이머 개수=\(self.stopwatches.count)")
        self.collectionView?.reloadData()
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
        reInitBtn.addTarget(self, action: #selector(reset(_:)), for: .touchUpInside)
        self.view.addSubview(reInitBtn)
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
    
    @objc func reset(_ sender: Any) {
        for stopwatch in self.stopwatches {
            stopwatch.reset()
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
