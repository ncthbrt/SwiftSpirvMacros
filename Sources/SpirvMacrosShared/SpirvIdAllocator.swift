//
//  File.swift
//  
//
//  Created by Natalie Cuthbert on 2023/12/12.
//

import Foundation


public class SpirvIdAllocator {
    public var lastAllocation: UInt32 = 0
    
    public func allocate() -> UInt32 {
        lastAllocation += 1
        return lastAllocation
    }
    
    public func reset() {
        lastAllocation = 0
    }
    
    public static var instance: SpirvIdAllocator = SpirvIdAllocator()
    
    public init(){
        lastAllocation = 0
    }
}
