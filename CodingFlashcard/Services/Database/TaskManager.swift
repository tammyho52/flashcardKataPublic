//
//  TaskManager.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import Foundation

class TaskManager {
    private var activeTasks: [Task<Void, Error>] = []
    
    func startTask(_ task: @escaping () async throws -> Void) {
        let newTask = Task {
            try await task()
        }
        activeTasks.append(newTask)
    }
    
    func cancelActiveTask() {
        for task in activeTasks {
            task.cancel()
        }
        activeTasks.removeAll()
    }
    
    func hasActiveTasks() -> Bool {
        return !activeTasks.isEmpty
    }
}
