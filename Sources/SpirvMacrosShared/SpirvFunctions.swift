//
//  File.swift
//  
//
//  Created by Natalie Cuthbert on 2023/12/12.
//

import Foundation
import SPIRV_Headers_Swift

public func string(_ str: String) -> [UInt32] {
    var operands: [UInt32] = []
    let data = Data(str.utf8)
    let div4 = data.count/4
    for i in 0..<div4 {
        var value: UInt32 = 0
        for j in (0..<4) {
            let byte = UInt32(data[i*4+j])
            value |= byte<<(8*j)
        }
        operands.append(value)
    }
    let remainder = data.count - (div4*4)
    var value: UInt32 = 0
    for j in (0..<remainder) {
        let byte = UInt32(data[div4*4+j])
        value |= byte<<(8*j)
    }
    operands.append(value)
    
    return operands
}

public func double(_ dbl: Double) -> [UInt32] {
    let bitPattern = dbl.bitPattern
    let upper = UInt32(bitPattern >> 32)
    let lower = UInt32(bitPattern & 0xffffffff)
    return [upper, lower]
}

public func long(_ lng: Int64) -> [UInt32] {
    let bitPattern = lng
    let upper = UInt32(bitPattern >> 32)
    let lower = UInt32(bitPattern & 0xffffffff)
    return [upper, lower]
}

public func float(_ flt: Float) -> [UInt32] {
    return [flt.bitPattern]
}

public func int(_ int: Int32) -> [UInt32] {
    return [UInt32(bitPattern: int)]
}

public func short(_ shrt: Int16) -> [UInt32] {
    return [UInt32(bitPattern: Int32(shrt))]
}
