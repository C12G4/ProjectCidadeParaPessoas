//
//  URL+Ext.swift
//  Starlen
//
//  Created by Pedro Augusto on 08/04/26.
//

import Foundation

extension URL {
    var isDirectory: Bool! {
        return (try? resourceValues(forKeys:
            [.isDirectoryKey]))?.isDirectory
    }
}
