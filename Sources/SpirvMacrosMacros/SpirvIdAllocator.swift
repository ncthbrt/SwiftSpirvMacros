//
//  File.swift
//  
//
//  Created by Natalie Cuthbert on 2023/12/12.
//

import Foundation


struct SpirvId {
    let value: UInt32
}

class SpirvIdAllocator {
    public var lastAllocation: UInt32 = 0
    
    public func allocate() -> SpirvId {
        lastAllocation += 1
        return SpirvId(value: lastAllocation)
    }
    
    public func reset() {
        lastAllocation = 0
    }
    
    public static var shared: SpirvIdAllocator = SpirvIdAllocator()
}
