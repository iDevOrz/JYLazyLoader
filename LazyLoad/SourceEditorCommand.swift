//
//  SourceEditorCommand.swift
//  LazyLoad
//
//  Created by 张建宇 on 2019/8/2.
//  Copyright © 2019 DevOrz. All rights reserved.
//

import Foundation
import XcodeKit

enum Command: String {
    case withMark = "withMark"
    case withoutMark = "withoutMark"
}

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
//    func error(_ message: String) -> NSError {
//        return NSError(domain: "JYLoayLoad", code: 1, userInfo: [
//            NSLocalizedDescriptionKey: NSLocalizedString(message, comment: ""),
//            ])
//    }
//
//    func handleError(message: String,_ completionHandler: @escaping (Error?) -> Void) {
//        completionHandler(error(message))
//    }
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        Runtime.shared.lazyLoad(invocation)
        completionHandler(nil)
        
        
    }
    
}
