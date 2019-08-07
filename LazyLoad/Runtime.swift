//
//  Runtime.swift
//  LazyLoad
//
//  Created by 张建宇 on 2019/8/3.
//  Copyright © 2019 DevOrz. All rights reserved.
//

import XcodeKit

enum Language: String {
    case swift, java, cpp, objc, objcHeader
}

fileprivate let languageUTIs: [CFString: Language] = [
    kUTTypeSwiftSource: .swift,
    kUTTypeObjectiveCSource: .objc,
    kUTTypeCHeader: .objc,
    kUTTypeJavaSource: .java,
    kUTTypeCPlusPlusSource: .cpp,
    kUTTypeObjectiveCPlusPlusSource: .objc,
    "com.apple.dt.playground" as CFString: .swift
]

class Runtime {
    private init() {
        if let path = Bundle.main.path(forResource: "LazyLoadTemp", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) as? [String: String] {
            lazyLoadStringTemp = dict
        }else{
            lazyLoadStringTemp = [String:String]()
        }
    }
    static let shared = Runtime()
    
    let lazyLoadStringTemp:[String:String]
    
    
    static let classNamePattern = #"(?<=\))\b\w*\b(?=\<)|(?<=\)).*\b\w*\b(?=\*)"#
    static let propertyNamePattern = #"(?<=\*)\b\w*\b(?=\;)"#
    
    let classNameRegex = try! NSRegularExpression(pattern: classNamePattern, options: NSRegularExpression.Options.allowCommentsAndWhitespace)
    let propertyNameRegex = try! NSRegularExpression(pattern: propertyNamePattern, options: NSRegularExpression.Options.allowCommentsAndWhitespace)
    
    
    func languageFor(contentUTI: CFString) -> Language? {
//        print(contentUTI)
        for (uti, language) in languageUTIs {
            if UTTypeConformsTo(contentUTI as CFString, uti) {
                return language
            }
        }
        return nil
    }
    
    func getFirstSelection(_ buffer: XCSourceTextBuffer) -> XCSourceTextRange? {
        for range in buffer.selections {
            guard let range = range as? XCSourceTextRange else {
                continue
            }
            return range
        }
        return nil
    }
    
    func getSelectLinesWith(_ selection:XCSourceTextRange,lines: [String]) -> [String] {
        var result = [String]()
        for i in selection.start.line ... selection.end.line {
            result.append(lines[i])
        }
        return result;
    }
    
    func generateLazyLoadString(className: String, propertyName: String) -> String {
        
        
        if let tempString = lazyLoadStringTemp[className]{
            return tempString.replacingOccurrences(of: "propertyName", with: propertyName)
        }
        
        
        let otherTempString = #"""
                        -(ClassName *)propertyName{
                            if (_propertyName == nil) {
                                _propertyName = [ClassName new];
                            }
                            return _propertyName;
                        }
                        """#
        var result = otherTempString.replacingOccurrences(of: "ClassName", with: className)
        result = result.replacingOccurrences(of: "propertyName", with: propertyName)
        return result;
        
    }
    
    func parseLineString(_ lineString: String) -> (className: String, propertyName: String)?{

        let lineContent = lineString.replacingOccurrences(of:" ", with:"", options: .literal, range: nil)//去除空格
        
        guard lineContent.hasPrefix("@property") else {
            return nil
        }
        
        var className:String?
        var propertyName:String?
        
        let classNameRes = classNameRegex.matches(in: lineContent, options: .reportCompletion, range: NSRange(location: 0,length: lineContent.count))
        if classNameRes.count != 0 {
            className = (lineContent as NSString).substring(with: classNameRes.first!.range)
        }
        let propertyNameRes = propertyNameRegex.matches(in: lineContent, options: .reportCompletion, range: NSRange(location: 0,length: lineContent.count))
        if propertyNameRes.count != 0 {
            propertyName = (lineContent as NSString).substring(with: propertyNameRes.first!.range)
        }
        guard let classNameResult = className,let propertyNameResult = propertyName else {
            return nil
        }
//        print("className = " + classNameResult!)
//        print("propertyName = " + propertyNameResult!)
        return(classNameResult,propertyNameResult)
    }
    
    func findInsertIndex(currentEndLine:Int,lines: [String]) -> (lineIndex: Int,mark: Bool) {
        var flag = false
        for index in currentEndLine ..< lines.count {
            let lineString = lines[index]
            
            if lineString.contains("//MARK: Lazy Load"){
                print("index = \(index)")
                let resultIndex = index < lines.count - 1 ? index + 1 : index //插入在mark 下面
                return (resultIndex,true)
            }
            
            if lineString.contains("@end"){
                if flag{
                    return (index,false)
                }else{
                    flag = true
                }
            }
        }
        return (lines.count - 1,false)
    }

    func lazyLoad (_ invocation: XCSourceEditorCommandInvocation) {
        guard let language = languageFor(contentUTI: invocation.buffer.contentUTI as CFString) else { return }
        if language == Language.objc {
            let selection = getFirstSelection(invocation.buffer) ?? XCSourceTextRange()
            let lines = getSelectLinesWith(selection, lines: invocation.buffer.lines as! [String])
            var lazyLoadStrings = ""
            for line in lines{
                guard let (className, propertyName) = parseLineString(line) else {
                    continue
                }
                let lazyLoadString = generateLazyLoadString(className: className, propertyName: propertyName)
                lazyLoadStrings.append(lazyLoadString + "\n\n");
            }
            let (lineIndex,hasMark) = findInsertIndex(currentEndLine: selection.end.line, lines: invocation.buffer.lines as! [String])
            
            if invocation.commandIdentifier == Command.withMark.rawValue,hasMark == false{
                lazyLoadStrings = "//MARK: Lazy Load \n\n" + lazyLoadStrings
                invocation.buffer.lines.insert(lazyLoadStrings, at: lineIndex)
            }else{
                invocation.buffer.lines.insert(lazyLoadStrings, at: lineIndex)
            }
        }
    }
}
