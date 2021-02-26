//
//  TaskTimerDAO.swift
//  KingdomTimer
//
//  Created by 정성훈 on 2021/02/26.
//

import Foundation
import CoreData

class TaskTimerDAO {
    
    func fetch() -> [TaskTimer] {
        print("fetching 시작")
        let viewContext = AppDelegate.viewContext
        var taskTimers = [TaskTimer]()
        
        // Fetching Data from Core data
        let request: NSFetchRequest<TaskTimerEntity> = NSFetchRequest(entityName: "TaskTimerEntity")
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        do {
            let fetchedTaskTimers = try viewContext.fetch(request)
            for fetchedTaskTimer in fetchedTaskTimers {
                let taskTimer = TaskTimer(fetchedObject: fetchedTaskTimer)
                taskTimers.append(taskTimer)
            }
            return taskTimers
        } catch let e as NSError {
            NSLog("DAO fetching failed. error: %s", e)
            return [TaskTimer]()
        }
    }
    
    func save() {
        print("TaskTimerDAO.save() 호출")
        let context = AppDelegate.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch let e as NSError{
                NSLog("save error: %s", e.localizedDescription)
            }
        }
    }
    
    func create(data: TimerData) {
        guard data.title != "" else {
            return
        }
        let taskTimerMO = TaskTimerEntity(context: AppDelegate.viewContext)
        
        let id = UserDefaults.standard.integer(forKey: "autoIncrement")
        taskTimerMO.id = Int64(id)
        UserDefaults.standard.set(id + 1, forKey: "autoIncrement")
        
        taskTimerMO.title = data.title
        taskTimerMO.interval = Int64(data.wholeTime)
        
        self.save()
    }
    
    func delete(objectId: NSManagedObjectID) -> Bool {
        let context = AppDelegate.viewContext
        let taskTimer = context.object(with: objectId)
        
        context.delete(taskTimer)
        
        do {
            try context.save()
            return true
        } catch let e as NSError {
            NSLog("delete error: %s", e)
            return false
        }
    }
}

