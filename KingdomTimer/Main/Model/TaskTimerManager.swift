//
//  TaskTimerManager.swift
//  KingdomTimer
//
//  Created by 정성훈 on 2021/05/09.
//

import Foundation

struct TaskTimerManager {
    static private var taskTimers = [TaskTimer]()
    static private let taskTimerDao = TaskTimerDAO()
    
    static func startAll() {
        for timer in taskTimers {
            timer.start()
        }
    }
    
    static func startAllWithOptimization() {
        for timer in taskTimers {
            timer.startWithOptimization()
        }
    }
    
    static func pauseWithOptimization() {
        for timer in taskTimers {
            timer.startWithOptimization()
        }
    }
    
    static func start(at index: Int) {
        guard !self.taskTimers.isEmpty && index < self.taskTimers.count else {
            return
        }
        taskTimers[index].start()
    }
    
    static func pause(at index: Int) {
        guard !self.taskTimers.isEmpty && index < self.taskTimers.count else {
            return
        }
        taskTimers[index].pause()
    }
    
    static func reset(at index: Int) {
        guard !self.taskTimers.isEmpty && index < self.taskTimers.count else {
            return
        }
        taskTimers[index].reset()
    }
 
    // MARK:- CRUD
    static func create(data: TimerDataInputContainer) {
        guard let timer = taskTimerDao.create(data: data) else { return }
        self.taskTimers.append(timer)
    }
    
    static func taskTimer(at index: Int) -> TaskTimer? {
        guard !self.taskTimers.isEmpty && index < self.taskTimers.count else {
            return nil
        }
        return self.taskTimers[index]
    }
    
    static func update(at index: Int, newTimerData timerData: TimerDataInputContainer) -> Bool {
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
    
    static func remove(at index: Int) -> Bool {
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
}
