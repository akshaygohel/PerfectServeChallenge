//
//  PSLogger.swift
//  PSChallenge
//
//  Created by Akshay Gohel on 06/12/21.
//  Copyright © 2021 Akshay Gohel. All rights reserved.
//

import Foundation

class PSLogger {
    
    // Use this class to print custom logs for DEBUG or user activity if needed.
    
}

public func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
#if DEBUG
    let output = items.map { "\($0)" }.joined(separator: separator)
    Swift.print(output, terminator: terminator)
#endif
}
