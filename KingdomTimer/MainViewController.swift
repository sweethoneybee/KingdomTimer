import UIKit
import CoreData

class MainViewController: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView?
    var stopwatches = [TaskTimer]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let flowLayout: UICollectionViewFlowLayout
        flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = CGFloat(10)
        flowLayout.minimumLineSpacing = CGFloat(10)
        
        let width = UIScreen.main.bounds.width
        flowLayout.itemSize = CGSize(width: width * 0.28, height: width * 0.28)
        
        let inset = width * 0.02
        flowLayout.sectionInset = UIEdgeInsets(top: CGFloat(inset), left: CGFloat(inset), bottom: CGFloat(inset), right: CGFloat(inset))
        
        self.collectionView?.collectionViewLayout = flowLayout
        self.collectionView?.delaysContentTouches = false // for natural content shrinking animation
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(askEditing(_:)))
        self.collectionView?.addGestureRecognizer(gesture)
        
        // Fetching Data from Core data
        let request: NSFetchRequest<TaskTimerEntity> = NSFetchRequest(entityName: "TaskTimerEntity")
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        do {
            let fetchedObjects = try AppDelegate.viewContext.fetch(request)
            let fetchedStopwatches = fetchedObjects
            for fetchedStopwatch in fetchedStopwatches {
                let stopwatch = TaskTimer(fetchedObject: fetchedStopwatch)
                if stopwatch.state == .going && stopwatch.leftTime <= 0 {
                    stopwatch.finish()
                } else {
                    stopwatch.startWithOptimization()
                }
                self.stopwatches.append(stopwatch)
            }
        } catch {
            print("실패")
        }
        
        print("viewdidload")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        for stopwatch in self.stopwatches {
            stopwatch.startWithOptimization()
        }
        self.collectionView?.reloadData()
    }
    
    // TODO:- 저장이 정확히 언제 되는건지 모르겠음
    override func viewWillDisappear(_ animated: Bool) {
        for stopwatch in self.stopwatches {
            stopwatch.pauseWithOptimization()
        }
        let context = AppDelegate.viewContext
        if context.hasChanges {
            do {
                try context.save()
                print("저장성공")
            } catch {
                print("저장실패")
            }
        }
    }
    
    @IBAction func addStopwatch(_ sender: UIBarButtonItem) {
        let stopwatchObject = TaskTimerEntity(context: AppDelegate.viewContext)
        let id = UserDefaults.standard.integer(forKey: "autoIncrement")
        stopwatchObject.id = Int64(id)
        UserDefaults.standard.set(id + 1, forKey: "autoIncrement")
        
        stopwatchObject.title = "임시타이틀"
        stopwatchObject.interval = Int64(30)
        stopwatchObject.savedLeftTime = 0
        stopwatchObject.state = TaskTimer.State.idle.rawValue
        
        let stopwatch = TaskTimer(fetchedObject: stopwatchObject)
        self.stopwatches.append(stopwatch)
        
        // TODO:- viewWillAppear 에서 수행할 것이기 때문에 삭제해야함
        self.collectionView?.reloadData()
    }
    
    @objc func askEditing(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let touchedPoint = sender.location(in: self.collectionView)
            if let indexpath = self.collectionView?.indexPathForItem(at: touchedPoint) {
                let alert = UIAlertController(title: nil, message: "\(indexpath.item)번째", preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "리셋", style: .default))
                alert.addAction(UIAlertAction(title: "수정", style: .default))
                alert.addAction(UIAlertAction(title: "삭제", style: .destructive))
                alert.addAction(UIAlertAction(title: "취소", style: .cancel))
                self.present(alert, animated: true)
            }
        }
    }
}

extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stopwatches.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TaskTimerCell", for: indexPath) as? TaskTimerCell else {
            let errorCell = UICollectionViewCell()
            return errorCell
        }
        
        let stopwatch = self.stopwatches[indexPath.item]
        stopwatch.delegate = cell
                
        cell.stateLabel?.text = TaskTimerCell.changeStateToString(state: stopwatch.state)
        cell.titleLabel?.text = stopwatch.title
        cell.timeLabel?.text = TaskTimerCell.textLeftTime(left: stopwatch.leftTime)
        cell.contentView.backgroundColor = CellBackgroundColor.backgroundColor(withState: stopwatch.state)
        cell.contentView.layer.cornerRadius = CGFloat(20)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let stopwatch = self.stopwatches[indexPath.item]
        switch stopwatch.state {
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
        if let cell = collectionView.cellForItem(at: indexPath) as? TaskTimerCell {
            let pressedDownTransform = CGAffineTransform(scaleX: 0.98, y: 0.98)
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 3, options: [.curveEaseInOut], animations: { cell.transform = pressedDownTransform })
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? TaskTimerCell {
            let originalTransform = CGAffineTransform(scaleX: 1, y: 1)
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 3, options: [.curveEaseInOut], animations: { cell.transform = originalTransform })
        }
    }
}
