//
//  PlistArray.swift
//  SwiftyLibPlist
//
//  Created by Kazuki Yamamoto on 2019/11/30.
//  Copyright © 2019 Kazuki Yamamoto. All rights reserved.
//

import Foundation
import CPlist

public struct PlistArrayIterator: IteratorProtocol {
    private let node: PlistArray?
    public private(set) var rawValue:plist_array_iter? = nil
    
    public init(node: PlistArray) {
        var rawValue: plist_array_iter? = nil
        plist_array_new_iter(node.plist.rawValue, &rawValue)
        self.rawValue = rawValue
        self.node = node
    }
    
    public func next() -> Plist? {
        var pitem: plist_t? = nil
        plist_array_next_item(node?.plist.rawValue, rawValue, &pitem)
        guard let item = pitem else {
            return nil
        }
        return Plist(rawValue: item)
    }
    
    public mutating func free() {
        guard let rawValue = self.rawValue else {
            return
        }
        rawValue.deallocate()
        self.rawValue = nil
    }
}

public struct PlistArray {
    fileprivate let plist: Plist
    
    public init?(plist: Plist) {
        guard case .array = plist.nodeType else {
            return nil
        }
        
        self.plist = plist
    }
    
    func append(item: Plist) {
        plist_array_append_item(plist.rawValue, item.rawValue)
    }
    
    func insert(index: UInt32, item: Plist) {
        plist_array_insert_item(plist.rawValue, item.rawValue, index)
    }
    
    func remove(index: UInt32) {
        plist_array_remove_item(plist.rawValue, index)
    }
    
    func itemRemove() {
        plist_array_item_remove(plist.rawValue)
    }
    
    func getItemIndex() -> UInt32 {
        plist_array_get_item_index(plist.rawValue)
    }
}

extension PlistArray: Sequence {
    public func makeIterator() -> PlistArrayIterator {
        PlistArrayIterator(node: self)
    }
}

public extension Plist {
    convenience init(array: [Plist]) {
        self.init(rawValue: plist_new_array())
        for value in array {
            plist_array_append_item(rawValue, plist_copy(value.rawValue))
        }
    }
    
    subscript(index: UInt32) -> Plist? {
        get { Plist(unownedRawValue: plist_array_get_item(rawValue, index), parent: self) }
        set { plist_array_set_item(rawValue, newValue?.rawValue, index) }
    }
}

public extension Plist {
    var array: PlistArray? {
        guard case .array = nodeType else {
            return nil
        }
        return PlistArray(plist: self)
    }
}
