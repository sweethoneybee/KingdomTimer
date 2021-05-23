//
//  TaskTimerManager.swift
//  KingdomTimer
//
//  Created by 정성훈 on 2021/05/09.
//

import Foundation
import UserNotifications

class TaskTimerManager {
    static var shared = TaskTimerManager()
    private var taskTimers: [TaskTimer]
    private let taskTimerDao: TaskTimerDAO
    
    var count: Int { self.taskTimers.count }
    private init() {
        self.taskTimerDao = TaskTimerDAO()
        self.taskTimers = self.taskTimerDao.fetch()
    }
    
    func startAll() {
        let center = UNUserNotificationCenter.current()
        for timer in self.taskTimers {
            timer.start()
            center.createLocalPush(data: timer.timerData)
        }
    }
    
    func startAllWithOptimization() {
        for timer in self.taskTimers {
            timer.startWithOptimization()
        }
    }
    
    func pauseWithOptimization() {
        for timer in self.taskTimers {
            timer.pauseWithOptimization()
        }
    }
    
    func start(at index: Int) {
        guard !self.taskTimers.isEmpty && index < self.taskTimers.count else {
            return
        }
        self.taskTimers[index].start()
    }
    
    func pause(at index: Int) {
        guard !self.taskTimers.isEmpty && index < self.taskTimers.count else {
            return
        }
        self.taskTimers[index].pause()
    }
    
    func reset(at index: Int) {
        guard !self.taskTimers.isEmpty && index < self.taskTimers.count else {
            return
        }
        self.taskTimers[index].reset()
    }
 
    // MARK:- CRUD
    func create(data: TimerDataInputContainer) {
        guard let timer = taskTimerDao.create(data: data) else { return }
        self.taskTimers.append(timer)
    }
    
    func taskTimer(at index: Int) -> TaskTimer? {
        guard !self.taskTimers.isEmpty && index < self.taskTimers.count else {
            return nil
        }
        return self.taskTimers[index]
    }
    
    func update(at index: Int, newTimerData timerData: TimerDataInputContainer) -> Bool {
        guard !self.taskTimers.isEmpty && index < self.taskTimers.count else {
            return false
        }
        
        let oldTimer = self.taskTimers[index]
        self.taskTimerDao.update(target: oldTimer.entity, data: timerData)

        oldTimer.timerData.title = timerData.title
        oldTimer.timerData.count = timerData.count
        oldTimer.timerData.interval = TimeInterval(timerData.wholeTime)

        return true
    }
    
    func remove(at index: Int) -> Bool {
        guard !self.taskTimers.isEmpty && index < self.taskTimers.count else {
            return false
        }
        
        let id = self.taskTimers[index].objectId
        if self.taskTimerDao.delete(objectId: id) {
            self.taskTimers.remove(at: index)
            return true
        }
        return false
    }
    
    func fetch() {
        self.taskTimers = self.taskTimerDao.fetch()
    }
    
    func save() {
        self.taskTimerDao.save()
    }
}
