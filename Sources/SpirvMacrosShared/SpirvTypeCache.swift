//
//  File.swift
//  
//
//  Created by Natalie Cuthbert on 2023/12/13.
//

import Foundation
import SPIRV_Headers_Swift



public class SpirvTypeCache {
    private var typeCache: [[UInt32]: UInt32] = [:]
    private var structCache: [String: UInt32] = [:]
    public init() {}
    
    public func tryGetTypeId(op: SpirvOp, operands: [[UInt32]]) -> UInt32? {
        var cacheKey = [op.rawValue]
        cacheKey.append(contentsOf: operands.flatMap({$0}))
        return typeCache[cacheKey]
    }
    
    public func tryGetTypeId(structName: String) -> UInt32? {
        return structCache[structName]
    }
    
    public func allocateNewTypeId(op: SpirvOp, operands: [[UInt32]]) -> UInt32 {
        var cacheKey = [op.rawValue]
        cacheKey.append(contentsOf: operands.flatMap({$0}))
        let id = SpirvIdAllocator.instance.allocate()
        typeCache[cacheKey] = id
        return id
    }
    
    
    public func allocateNewTypeId(structName: String) -> UInt32 {
        let id = SpirvIdAllocator.instance.allocate()
        structCache[structName] = id
        return id
    }
    
    public static var instance: SpirvTypeCache = SpirvTypeCache()
}
