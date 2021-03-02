import UIKit
import CoreData

class MainViewController: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView?
    private lazy var taskTimerDao = TaskTimerDAO()
    lazy var taskTimers: [TaskTimer] = self.taskTimerDao.fetch()
    
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
        
        // TODO:- iOS 13 버전 이하만 제스처 적용
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(askEditing(_:)))
        self.collectionView?.addGestureRecognizer(gesture)
        
        print("viewdidload")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.taskTimers = self.taskTimerDao.fetch()
        for taskTimer in self.taskTimers {
            taskTimer.startWithOptimization()
        }
        self.collectionView?.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("viewWillDisappear")
        for taskTimer in self.taskTimers {
            taskTimer.pauseWithOptimization()
        }
        self.taskTimerDao.save()
    }
    
    @objc func askEditing(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let touchedPoint = sender.location(in: self.collectionView)
            if let indexpath = self.collectionView?.indexPathForItem(at: touchedPoint) {
                let item = self.taskTimers[indexpath.item]
                
                let alert = UIAlertController(title: nil, message: item.timerData.title, preferredStyle: .actionSheet)
                
                alert.addAction(UIAlertAction(title: "리셋", style: .default){ action in
                    item.reset()
                })
                
                alert.addAction(UIAlertAction(title: "편집", style: .default){ action in
                    guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "EditTaskTimer")
                            as? EditTaskTimerController else {
                        return
                    }
                    
                    vc.taskTimer = item
                    self.navigationController?.pushViewController(vc, animated: true)
                })
                
                alert.addAction(UIAlertAction(title: "삭제", style: .destructive){ action in
                    let askAgain = UIAlertController(title: "정말 삭제할 건가요?", message: item.timerData.title, preferredStyle: .actionSheet)
                    askAgain.addAction(UIAlertAction(title: "취소", style: .cancel))
                    askAgain.addAction(UIAlertAction(title: "삭제", style: .destructive){ action in
                        if self.taskTimerDao.delete(objectId: item.objectId) {
                            self.taskTimers.remove(at: indexpath.item)
                            self.collectionView?.reloadData()
                        }
                    })
                    
                    self.present(askAgain, animated: true)
                })
                
                alert.addAction(UIAlertAction(title: "취소", style: .cancel))
                self.present(alert, animated: true)
            }
        }
    }
}

extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.taskTimers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TaskTimerCell", for: indexPath) as? TaskTimerCell else {
            let errorCell = UICollectionViewCell()
            return errorCell
        }
        
        let taskTimer = self.taskTimers[indexPath.item]
        taskTimer.delegate = cell
                
        cell.stateLabel?.text = TaskTimerCell.changeStateToString(state: taskTimer.timerData.state)
        cell.titleLabel?.text = taskTimer.timerData.title
        cell.timeLabel?.text = TaskTimerCell.textLeftTime(left: taskTimer.leftTime)
        cell.contentView.backgroundColor = CellBackgroundColor.backgroundColor(withState: taskTimer.timerData.state)
        cell.contentView.layer.cornerRadius = CGFloat(20)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let taskTimer = self.taskTimers[indexPath.item]
        switch taskTimer.timerData.state {
        case .idle:
            taskTimer.start()
            let center = UNUserNotificationCenter.current()
            center.createLocalPush(data: taskTimer.timerData)
        case .going:
            taskTimer.pause()
            let center = UNUserNotificationCenter.current()
            center.deleteLocalPush(data: taskTimer.timerData)
        case .paused:
            taskTimer.start()
            let center = UNUserNotificationCenter.current()
            center.createLocalPush(data: taskTimer.timerData)
        case .finished:
            taskTimer.reset()
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
