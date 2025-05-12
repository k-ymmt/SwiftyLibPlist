//
//  PlistType.swift
//  SwiftyLibPlist
//
//  Created by kazuki.yamamoto on 2025/05/12.
//


import Foundation
import CPlist

public enum PlistType {
    case boolean
    case uint
    case real
    case string
    case array
    case dict
    case date
    case data
    case key
    case uid
    case none
    
    public init(rawValue: plist_type) {
        switch rawValue {
        case PLIST_BOOLEAN:
            self = .boolean
        case PLIST_INT:
            self = .uint
        case PLIST_REAL:
            self = .real
        case PLIST_STRING:
            self = .string
        case PLIST_ARRAY:
            self = .array
        case PLIST_DICT:
            self = .dict
        case PLIST_DATE:
            self = .date
        case PLIST_DATA:
            self = .data
        case PLIST_KEY:
            self = .key
        case PLIST_UID:
            self = .uid
        default:
            self = .none
        }
    }
}