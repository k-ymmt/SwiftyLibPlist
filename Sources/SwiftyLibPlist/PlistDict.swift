//
//  PlistDict.swift
//  SwiftyLibPlist
//
//  Created by Kazuki Yamamoto on 2019/11/30.
//  Copyright © 2019 Kazuki Yamamoto. All rights reserved.
//

import Foundation
import CPlist

public struct PlistDictIterator: IteratorProtocol {
    private let node: PlistDict
    public private(set) var rawValue: plist_dict_iter?
    
    public init(node: PlistDict) {
        var rawValue: plist_dict_iter? = nil
        plist_dict_new_iter(node.plist.rawValue, &rawValue)
        self.rawValue = rawValue
        self.node = node
    }
    
    public func next() -> (key: String, value:Plist)? {
        var pkey: UnsafeMutablePointer<Int8>? = nil
        var pitem: plist_t? = nil
        plist_dict_next_item(node.plist.rawValue, rawValue, &pkey, &pitem)
        guard let key = pkey, let plist = Plist(nillableValue: pitem) else {
            return nil
        }
        return (String(cString: key), plist)
    }
}

public struct PlistDict {
    fileprivate let plist: Plist

    public init?(plist: Plist) {
        guard case .dict = plist.nodeType else {
            return nil
        }
        
        self.plist = plist
    }
}

extension PlistDict: Sequence {
    public func makeIterator() -> PlistDictIterator {
        return PlistDictIterator(node: self)
    }
}

public extension Plist {
    convenience init(dictionary: [String: Plist]) {
        self.init(rawValue: plist_new_dict())
        for (key, value) in dictionary {
            plist_dict_set_item(rawValue, key, plist_copy(value.rawValue))
        }
    }

    func getItemKey() -> String? {
        var pkey: UnsafeMutablePointer<Int8>? = nil
        plist_dict_get_item_key(rawValue, &pkey)
        
        guard let key = pkey else {
            return nil
        }
        defer { key.deallocate() }
        return String(cString: key)
    }
    
    subscript(key: String) -> Plist? {
        get {
            guard let plist = plist_dict_get_item(rawValue, key) else {
                return nil
            }
            return Plist(unownedRawValue: plist, parent: self)
        }
        
        set {
            guard let newRawValue = newValue?.rawValue else {
                return
            }
            plist_dict_set_item(rawValue, key, newRawValue)
        }
    }
}

public extension Plist {
    var dictionary: PlistDict? {
        return PlistDict(plist: self)
    }
}

