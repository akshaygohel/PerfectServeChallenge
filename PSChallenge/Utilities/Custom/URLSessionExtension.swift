//
//  URLSessionExtension.swift
//  PSChallenge
//
//  Created by Akshay Gohel on 05/12/21.
//  Copyright © 2021 Akshay Gohel. All rights reserved.
//

import Foundation

extension URLSession {
    func cancelRunningTaskWithUrl(_ url: URL) {
        URLSession.shared.getAllTasks { tasks in
            tasks
                .filter { $0.state == .running }
                .filter { $0.originalRequest?.url == url }
                .first?
                .cancel()
        }
    }
    
    func cancelAllRunningtasks() {
        URLSession.shared.getAllTasks { tasks in
            tasks
                .filter { $0.state == .running }
                .first?
                .cancel()
        }
    }
}
