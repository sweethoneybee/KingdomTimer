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
        // UNMutableNotificationContent()에 .body, .title, .sound  설정
        // UNTimeIntervalNotificationTrigger 생성
        // content, trigger를 가지고 UNNotificationRequest 생성(이때 identifier를 id 값으로 주자 -> data에 id가 들어있나..? 없으면 인자에 추가
        // center에 추가
    }
    
    func deleteLocalPush(id: String) {
        // removePendingNotificationRequests(withIdentifiers:)
    }
}
