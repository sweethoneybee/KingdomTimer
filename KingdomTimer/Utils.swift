import UIKit

extension UIColor {
    static func fromRGB(rgbValue: UInt, alpha: CGFloat = CGFloat(0.7)) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat((rgbValue & 0x0000FF)) / 255.0,
            alpha: alpha)
    }
}

// TODO:- 두 개 메소드 구현. 권한 물어보면서 하기.
extension UNUserNotificationCenter {
    func createLocalPush(data: TimerData) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                var data = data
                
                let content = UNMutableNotificationContent()
                content.title = "[완료] - \(data.title)"
                content.sound = .default
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: data.finishDate.timeIntervalSinceNow, repeats: false)
                
                // TODO:- id가 String이라서 그냥 넣으면 중복될 수 있음
                let id = String(data.id) + String(data.title) + String(data.finishDate.description)
                let request = UNNotificationRequest(identifier: id, content: content , trigger: trigger)
                
                center.add(request)
            }
        }
        // UNMutableNotificationContent()에 .body, .title, .sound  설정/Users/aratishappy/Desktop/SwiftTest.playground
        // UNTimeIntervalNotificationTrigger 생성
        // content, trigger를 가지고 UNNotificationRequest 생성(이때 identifier를 id 값으로 주자 -> data에 id가 들어있나..? 없으면 인자에 추가
        // center에 추가
    }
    
    func deleteLocalPush(data: TimerData) {
        // removePendingNotificationRequests(withIdentifiers:)
        var data = data
        let id = String(data.id) + String(data.title) + String(data.finishDate.description)
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [String(id)])
    }
}
