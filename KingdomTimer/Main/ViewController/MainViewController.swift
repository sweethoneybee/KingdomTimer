import UIKit
import CoreData

class MainViewController: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView?
    private lazy var taskTimerDao = TaskTimerDAO()
    lazy var taskTimerManager = TaskTimerManager()
    
    // MARK:- Override
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(askEditing(_:)))
        self.collectionView?.addGestureRecognizer(gesture)
        self.collectionView?.delaysContentTouches = false // for natural content shrinking animation
        
        self.setupUI();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Show Tutorial if needed
        let ud = UserDefaults.standard
        if ud.bool(forKey: "tutorial") == false,
           let tutorialVC = self.initTutorialVC(withIdentifier: "Master") as? TutorialMasterViewController {
            tutorialVC.modalPresentationStyle = .fullScreen
            self.present(tutorialVC, animated: true)
            return
        }
        
        // set taskTimers
        self.taskTimerManager.fetch()
        self.taskTimerManager.startAllWithOptimization()
        self.collectionView?.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.taskTimerManager.pauseAllWithOptimization()
    }
    
    // MARK:- objc functions
    @objc func askEditing(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == .began,
              let indexPath = self.collectionView?.indexPathForItem(at: sender.location(in: self.collectionView)),
              let item = self.taskTimerManager.taskTimer(at: indexPath.item) else {
            return
        }
        
        // add ActionSheet
        let alert: UIAlertController = { alert in
            // Reset
            alert.addAction(UIAlertAction(title: "리셋", style: .default){ action in
                item.reset()
            })
            
            // Edit
            alert.addAction(UIAlertAction(title: "편집", style: .default){ action in
                guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "EditTaskTimer")
                        as? EditTaskTimerViewController else {
                    return
                }
                
                vc.taskTimerArgument = item
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            })
            
            // Delete
            alert.addAction(UIAlertAction(title: "삭제", style: .destructive){ action in
                let askAgain = UIAlertController(title: "정말 삭제할 건가요?", message: item.timerData.title, preferredStyle: .actionSheet)
                askAgain.addAction(UIAlertAction(title: "취소", style: .cancel))
                askAgain.addAction(UIAlertAction(title: "삭제", style: .destructive){ action in
                    if self.taskTimerManager.remove(at: indexPath.item) {
                        UNUserNotificationCenter.current().deleteLocalPush(data: item.timerData)
                        self.collectionView?.reloadData()
                    }
                })
                
                self.present(askAgain, animated: true)
            })
            alert.addAction(UIAlertAction(title: "취소", style: .cancel))
            
            return alert
        }(UIAlertController(title: nil, message: item.timerData.title, preferredStyle: .actionSheet))
        
        self.present(alert, animated: true)
    }
    
    @objc func movePageToAdd(_ sender: Any) {
        let MAX_TIMER_COUNT = 50
        guard self.taskTimerManager.count < MAX_TIMER_COUNT else {
            let alertTooMany = UIAlertController.makeSimpleAlert(title: "타이머 개수 초과",
                                                                 message: "타이머는 최대 \(MAX_TIMER_COUNT)개까지 설정할 수 있습니다",
                                                                 actionHandler: nil)
            self.present(alertTooMany, animated: true)
            return
        }
        
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddTaskTimer") as? AddTaskTimerViewController else {
            return
        }
        
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func startAllTimers(_ sender: Any) {
        self.taskTimerManager.startAll()
    }
    
    private func setupUI() {
        let flowLayout: UICollectionViewFlowLayout
        flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = CGFloat(10)
        flowLayout.minimumLineSpacing = CGFloat(10)
        
        let width = UIScreen.main.bounds.width
        flowLayout.itemSize = CGSize(width: width * 0.28, height: width * 0.28)
        
        let inset = width * 0.02
        flowLayout.sectionInset = UIEdgeInsets(top: CGFloat(inset * 4), left: CGFloat(inset), bottom: CGFloat(inset), right: CGFloat(inset))
        
        self.collectionView?.collectionViewLayout = flowLayout
        
        // navigationItems
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(movePageToAdd(_:)))
        let settingButton = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(startAllTimers(_:)))
        self.navigationItem.rightBarButtonItems = [addButton, settingButton]
    }
}

// MARK:- UICollectionView DataSource
extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.taskTimerManager.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TaskTimerCell", for: indexPath) as? TaskTimerCell else {
            let errorCell = UICollectionViewCell()
            return errorCell
        }
        
        guard let taskTimer = self.taskTimerManager.taskTimer(at: indexPath.item) else {
            let errorCell = UICollectionViewCell()
            return errorCell
        }
        taskTimer.delegate = cell
        
        cell.stateLabel?.text = TaskTimerCell.changeStateToString(state: taskTimer.timerData.state)
        cell.titleLabel?.text = taskTimer.timerData.title
        cell.timeLabel?.text = TaskTimerCell.textLeftTime(left: taskTimer.leftTime)
        cell.contentView.backgroundColor = CellBackgroundColor.backgroundColor(withState: taskTimer.timerData.state)
        cell.contentView.layer.cornerRadius = CGFloat(20)
        
        return cell
    }
}

// MARK:- UICollectionView Delegate
extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let taskTimer = self.taskTimerManager.taskTimer(at: indexPath.item) else {
            return
        }
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
