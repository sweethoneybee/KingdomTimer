import UIKit

class MainVC: UIViewController {
    var time: Date!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.time = Date(timeInterval: TimeInterval(100), since: Date())
        print("self.time = \(self.time!)")
        
        
        let btn = UIButton(type: .system)
        btn.setTitle("시간 출력", for: .normal)
        btn.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        btn.center = CGPoint(x: self.view.frame.width / 2, y: 100)
        btn.addTarget(self, action: #selector(printDate(_:)), for: .touchUpInside)
        
        self.view.addSubview(btn)
    }
    
    @objc func printDate(_ sender: Any) {
        let tempTime = Date()
        print("now = \(tempTime)")
        
        let interval1 = tempTime.timeIntervalSince(self.time)
        print("time interval since 'self.time' = \(interval1)")
        
        
        let interval2 = self.time.timeIntervalSince(tempTime)
        print("time interval since 'tempTime' = \(interval2)")
    }
    
    
}
