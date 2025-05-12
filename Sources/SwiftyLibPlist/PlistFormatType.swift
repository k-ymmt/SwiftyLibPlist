//
//  PlistFormatType.swift
//  SwiftyLibPlist
//
//  Created by kazuki.yamamoto on 2025/05/12.
//

import CPlist

public enum PlistFormatType {
    /// No format
    case none
    /// XML format
    case xml
    /// bplist00 format
    case binary
    /// JSON format
    case json
    /// OpenStep "old-style" plist format
    case ostep
    /// human-readable output-only format
    case print
    /// `libimobiledevice` output-only format (ideviceinfo)
    case limd
    /// plutil-style output-only format
    case plutil

    init?(rawValue: plist_format_t) {
        switch rawValue {
        case PLIST_FORMAT_NONE:
            self = .none
        case PLIST_FORMAT_XML:
            self = .xml
        case PLIST_FORMAT_BINARY:
            self = .binary
        case PLIST_FORMAT_JSON:
            self = .json
        case PLIST_FORMAT_OSTEP:
            self = .ostep
        case PLIST_FORMAT_PRINT:
            self = .print
        case PLIST_FORMAT_LIMD:
            self = .limd
        case PLIST_FORMAT_PLUTIL:
            self = .plutil
        default:
            return nil
        }
    }

    var rawValue: plist_format_t {
        switch self {
        case .none:
            return PLIST_FORMAT_NONE
        case .xml:
            return PLIST_FORMAT_XML
        case .binary:
            return PLIST_FORMAT_BINARY
        case .json:
            return PLIST_FORMAT_JSON
        case .ostep:
            return PLIST_FORMAT_OSTEP
        case .print:
            return PLIST_FORMAT_PRINT
        case .limd:
            return PLIST_FORMAT_LIMD
        case .plutil:
            return PLIST_FORMAT_PLUTIL
        }
    }
}
