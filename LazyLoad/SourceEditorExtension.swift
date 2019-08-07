//
//  SourceEditorExtension.swift
//  LazyLoad
//
//  Created by 张建宇 on 2019/8/2.
//  Copyright © 2019 DevOrz. All rights reserved.
//

import Foundation
import XcodeKit


class SourceEditorExtension: NSObject, XCSourceEditorExtension {
    
    static let withMarkCommand = [XCSourceEditorCommandDefinitionKey.nameKey:Command.withMark.rawValue,XCSourceEditorCommandDefinitionKey.identifierKey:Command.withMark.rawValue,XCSourceEditorCommandDefinitionKey.classNameKey:SourceEditorCommand.className()]
    
    static let withoutMarkCommand = [XCSourceEditorCommandDefinitionKey.nameKey:Command.withoutMark.rawValue,XCSourceEditorCommandDefinitionKey.identifierKey:Command.withoutMark.rawValue,XCSourceEditorCommandDefinitionKey.classNameKey:SourceEditorCommand.className()]
    
    
    /*
    func extensionDidFinishLaunching() {
        // If your extension needs to do any work at launch, implement this optional method.
    }
    */
    
    
    var commandDefinitions: [[XCSourceEditorCommandDefinitionKey: Any]] {
//         If your extension needs to return a collection of command definitions that differs from those in its Info.plist, implement this optional property getter.

        
        
        return[SourceEditorExtension.withMarkCommand,SourceEditorExtension.withoutMarkCommand]
    }
    
    
}
