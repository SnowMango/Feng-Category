/*
 This source file is part of the Swift.org open source project

 Copyright (c) 2014 - 2017 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See http://swift.org/LICENSE.txt for license information
 See http://swift.org/CONTRIBUTORS.txt for Swift project authors
*/

/// A enum representing data types for legacy Plist type.
/// see: https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/PropertyLists/OldStylePlists/OldStylePLists.html
public enum Plist {
    case string(String)
    case array([Plist])
    case dictionary([String: Plist])
}

extension Plist: ExpressibleByStringLiteral {
    public typealias UnicodeScalarLiteralType = StringLiteralType
    public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType

    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self = .string(value)
    }
    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self = .string(value)
    }
    public init(stringLiteral value: StringLiteralType) {
        self = .string(value)
    }
}

// MARK: - Plist Extension (ExpressibleByArrayLiteral)
extension Plist: ExpressibleByArrayLiteral {
    
    public init(arrayLiteral elements: Plist...) {
        self = .array(elements)
    }
}
// MARK: - Plist Extension (ExpressibleByDictionaryLiteral)
extension Plist: ExpressibleByDictionaryLiteral {
    
    public init(dictionaryLiteral elements: (String, Plist)...) {
        var dictionary: [String: Plist] = [:]
        elements.forEach { dictionary[$0.0] = $0.1 }
        self = .dictionary(dictionary)
    }
}

public extension Plist {
    /// Serializes the Plist enum to string.
    func serialize() -> String {
        switch self {
        case .string(let str):
            return "\"" + Plist.escape(string: str) + "\""
        case .array(let items):
            return "(" + items.map({ $0.serialize() }).joined(separator: ", ") + ")"
        case .dictionary(let items):
            return "{" + items
                .sorted(by: { (lhs, rhs) in lhs.0 < rhs.0 })
                .map({ " \($0.0) = \($0.1.serialize()); " })
                .joined(separator: "") + "}"
        }
    }
    
    func description() -> String {
        switch self {
        case .string(let str):
            return "\"" + Plist.escape(string: str) + "\""
        case .array(let items):
            return """
            (\(items.map({ "\n\t\($0.description()), " }).joined(separator: ""))
            )
            """
        case .dictionary(let items):
            return """
            {\(items
            .sorted(by: { (lhs, rhs) in lhs.0 < rhs.0 })
            .map({ "\n \"\($0.0)\" = \($0.1.description()); " })
            .joined(separator: ""))
            }
            """
        }
    }
    /// Escapes the string for plist.
    /// Finds the instances of quote (") and backward slash (\) and prepends
    /// the escape character backward slash (\).
    static func escape(string: String) -> String {
        func needsEscape(_ char: UInt8) -> Bool {
            return char == UInt8(ascii: "\\") || char == UInt8(ascii: "\"")
        }

        guard let pos = string.utf8.index(where: needsEscape) else {
            return string
        }
        var newString = String(string[..<pos])
        for char in string.utf8[pos...] {
            if needsEscape(char) {
                newString += "\\"
            }
            newString += String(UnicodeScalar(char))
        }
        return newString
    }
}

extension Plist {
    static func plistWithObj(_ obj:Any)->Plist?
    {
        var ret:Plist?
        if obj is String{
            ret = Plist.string(obj as! String)
        }else if obj is Array<Any>{
            ret = Plist.array((obj as! Array<Any>).flatMap({ plistWithObj($0) }))
        }else if obj is Dictionary<String, Any>{
            let dic:[String:Plist] = Dictionary(uniqueKeysWithValues:
                (obj as! Dictionary<String, Any>).map { ($0.0 ,plistWithObj($0.1))}) as! [String : Plist]
            ret = Plist.dictionary(dic)
        }else if obj is Plist{
            ret = obj as? Plist
        }
        return ret
    }
}


