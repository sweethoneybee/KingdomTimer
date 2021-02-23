import UIKit
import CoreData

class MainVC: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView?
    var stopwatches = [ElapsedStopwatch]()
    
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
        
        
        // coredata
//        let context = AppDelegate.viewContext
        
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
        
//        let task = ElapsedStopwatch(title: "임시", interval: TimeInterval(5))
//        self.stopwatches.append(task)
//
//        print("등록된 타이머 개수=\(self.stopwatches.count)")
//        self.collectionView?.reloadData()
//
        
        let stopwatchObject = ElapsedStopwatchEntity(context: AppDelegate.viewContext)
        let id = UserDefaults.standard.integer(forKey: "autoIncrement")
        stopwatchObject.id = Int64(id)
        UserDefaults.standard.set(id + 1, forKey: "autoIncrement")
        
        stopwatchObject.title = "임시타이틀"
        stopwatchObject.interval = Int64(5)
        stopwatchObject.savedLeftTime = 0
        stopwatchObject.status = ElapsedStopwatchStatus.idle.rawValue
        
        let stopwatch = ElapsedStopwatch(fetchedObject: stopwatchObject)
        self.stopwatches.append(stopwatch)
        self.collectionView?.reloadData()
    }
}
