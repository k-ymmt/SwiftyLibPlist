//
//  Plist.swift
//  SwiftyLibPlist
//
//  Created by Kazuki Yamamoto on 2019/11/28.
//  Copyright © 2019 Kazuki Yamamoto. All rights reserved.
//

import Foundation
import CPlist

public struct PlistError: Error {
    public enum PlistErrorType {
        case invalidArgument
    }
    
    public let type: PlistErrorType
    public let message: String
    
    public init(type: PlistErrorType, message: String) {
        self.type = type
        self.message = message
    }
}

public final class Plist {
    private var _rawValue: plist_t?
    private let parent: Plist?
    private var unownedRawValue: plist_t?

    public var rawValue: plist_t? {
        return _rawValue ?? unownedRawValue
    }
    
    public init(rawValue: plist_t, parent: Plist? = nil) {
        self._rawValue = rawValue
        self.parent = parent
    }

    public init?(nillableValue: plist_t?, parent: Plist? = nil) {
        guard let rawValue = nillableValue else {
            return nil
        }
        self._rawValue = rawValue
        self.parent = parent
    }

    init(unownedRawValue: plist_t, parent: Plist? = nil) {
        self.unownedRawValue = unownedRawValue
        self.parent = parent
    }

    deinit {
        if let rawValue = _rawValue {
            plist_free(rawValue)
        }
    }
}

public extension Plist {
    var size: UInt32? {
        switch nodeType {
        case .array:
            return plist_array_get_size(rawValue)
        case .dict:
            return plist_dict_get_size(rawValue)
        default:
            return nil
        }
    }
}

public extension Plist {
    static func copy(from node: Plist) -> Plist {
        return Plist(rawValue: plist_copy(node.rawValue))
    }
    
    func getParent() -> Plist? {
        let parent = plist_get_parent(rawValue)
        return Plist(nillableValue: parent)
    }
    
    func xml() -> String? {
        var pxml: UnsafeMutablePointer<Int8>? = nil
        var length: UInt32 = 0
        plist_to_xml(rawValue, &pxml, &length)
        guard let xml = pxml else {
            return nil
        }
        
        defer { plist_mem_free(xml) }
        return String(cString: xml)
    }
    
    func bin() -> Data? {
        var pbin: UnsafeMutablePointer<Int8>? = nil
        var length: UInt32 = 0
        plist_to_bin(rawValue, &pbin, &length)
        guard let bin = pbin else {
            return nil
        }
        
        defer { plist_mem_free(bin) }
        return Data(bytes: UnsafeRawPointer(bin), count: Int(length))
    }
    
    var nodeType: PlistType {
        let type = plist_get_node_type(rawValue)
        return PlistType(rawValue: type)
    }
}

extension Plist: Equatable {
    public static func == (lhs: Plist, rhs: Plist) -> Bool {
        plist_compare_node_value(lhs.rawValue, rhs.rawValue) > 0
    }
}

public extension Plist {
    convenience init?(xml: String) {
        let length = xml.utf8CString.count
        var prawValue: plist_t? = nil
        plist_from_xml(xml, UInt32(length), &prawValue)
        guard let rawValue = prawValue else {
            return nil
        }
        self.init(rawValue: rawValue)
    }
    
    convenience init?(bin: Data) {
        let prawValue = bin.withUnsafeBytes { (bin) -> plist_t? in
            var plist: plist_t? = nil
            guard let pointer = bin.baseAddress else {
                return nil
            }

            plist_from_bin(pointer.bindMemory(to: Int8.self, capacity: bin.count), UInt32(bin.count), &plist)
            return plist
        }
        
        guard let rawValue = prawValue else {
            return nil
        }
        self.init(rawValue: rawValue)
    }
    
    convenience init?(memory: String, format: PlistFormatType = .none) {
        let length = memory.utf8CString.count
        var prawValue: plist_t? = nil
        var format = format.rawValue
        plist_from_memory(memory, UInt32(length), &prawValue, &format)
        guard let rawValue = prawValue else {
            return nil
        }
        self.init(rawValue: rawValue)
    }
    
    static func isBinary(data: String) -> Bool {
        plist_is_binary(data, UInt32(data.utf8CString.count)) > 0
    }
}

extension Plist: CustomStringConvertible {
    public var description: String {
        return xml() ?? ""
    }
}
