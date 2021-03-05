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
        flowLayout.sectionInset = UIEdgeInsets(top: CGFloat(inset * 4), left: CGFloat(inset), bottom: CGFloat(inset), right: CGFloat(inset))
        
        self.collectionView?.collectionViewLayout = flowLayout
        self.collectionView?.delaysContentTouches = false // for natural content shrinking animation
        
        // navigationItems
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(movePageToAdd(_:)))
        let settingButton = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(startAllTimers(_:)))
        self.navigationItem.rightBarButtonItems = [addButton, settingButton]

        // TODO:- iOS 13 버전 이하만 제스처 적용
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(askEditing(_:)))
        self.collectionView?.addGestureRecognizer(gesture)
        
        print("viewdidload")
    }
    
    @objc func movePageToAdd(_ sender: Any) {
        let MAX_TIMER_COUNT = 50
        guard self.taskTimers.count < MAX_TIMER_COUNT else {
            let alertToMany = UIAlertController(title: "타이머 개수 초과", message: "타이머는 최대까지 \(MAX_TIMER_COUNT)개까지 설정할 수 있습니다", preferredStyle: .alert)
            alertToMany.addAction(UIAlertAction(title: "확인", style: .default))
            self.present(alertToMany, animated: true)
            return
        }
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddTaskTimer") as? AddTaskTimerViewController else {
            return
        }
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func startAllTimers(_ sender: Any) {
        print("startAllTimers")
        let center = UNUserNotificationCenter.current()
        for taskTimer in self.taskTimers {
            taskTimer.start()
            center.createLocalPush(data: taskTimer.timerData)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let ud = UserDefaults.standard
        if ud.bool(forKey: "tutorial") == false {
            if let tutorialVC = self.tutorialVC(withIdentifier: "Master") as? MasterViewController {
                tutorialVC.modalPresentationStyle = .fullScreen
                self.present(tutorialVC, animated: true)
                return
            }
        }
        
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
                            UNUserNotificationCenter.current().deleteLocalPush(data: item.timerData)
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
        let center = UNUserNotificationCenter.current()
        switch taskTimer.timerData.state {
        case .idle:
            taskTimer.start()
            center.createLocalPush(data: taskTimer.timerData)
        case .going:
            taskTimer.pause()
            center.deleteLocalPush(data: taskTimer.timerData)
        case .paused:
            taskTimer.start()
            center.createLocalPush(data: taskTimer.timerData)
        case .finished:
            taskTimer.reset()
            center.deleteLocalPush(data: taskTimer.timerData)
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
