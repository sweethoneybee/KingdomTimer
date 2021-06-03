//
//  TaskTimerDAO.swift
//  KingdomTimer
//
//  Created by 정성훈 on 2021/02/26.
//

import Foundation
import CoreData

final class TaskTimerDAO {
    
    func fetch() -> [TaskTimer] {
        // Fetching Data from Core data
        let request: NSFetchRequest<TaskTimerEntity> = NSFetchRequest(entityName: "TaskTimerEntity")
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        do {
            let fetchedTaskTimers = try AppDelegate.viewContext.fetch(request)
            var taskTimers = [TaskTimer]()
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
        let context = AppDelegate.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch let e as NSError{
                NSLog("save error: %s", e.localizedDescription)
            }
        }
    }
    
    func create(data: TimerDataInputContainer) -> Bool {
        guard data.title != "" else {
            return false
        }
        let taskTimerMO = TaskTimerEntity(context: AppDelegate.viewContext)
        
        let id = UserDefaults.standard.integer(forKey: "autoIncrement")
        taskTimerMO.id = Int64(id)
        UserDefaults.standard.set(id + 1, forKey: "autoIncrement")
        
        taskTimerMO.title = data.title
        taskTimerMO.interval = Int64(data.wholeTime)
        taskTimerMO.count = Int64(data.count)
        
        self.save()
        return true
    }
    
    func update(target: TaskTimerEntity, data: TimerDataInputContainer) {
        target.title = data.title
        target.count = Int64(data.count)
        target.interval = Int64(data.wholeTime)
    }
    
    func delete(objectId: NSManagedObjectID) -> Bool {
        let context = AppDelegate.viewContext
        let taskTimerMO = context.object(with: objectId)
        context.delete(taskTimerMO)
        
        do {
            try context.save()
            return true
        } catch let e as NSError {
            NSLog("delete error: %s", e)
            return false
        }
    }
    
    func deleteAll() -> Bool {
        let context = AppDelegate.viewContext
        let request: NSFetchRequest<TaskTimerEntity> = NSFetchRequest(entityName: "TaskTimerEntity")
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        do {
            let fetchedTaskTimers = try context.fetch(request)
            for fetchedTaskTimer in fetchedTaskTimers {
                context.delete(fetchedTaskTimer)
            }
            
            try context.save()
            return true
        } catch let e as NSError {
            NSLog("DAO fetching failed. error: %s", e)
            return false
        }
    }
}
