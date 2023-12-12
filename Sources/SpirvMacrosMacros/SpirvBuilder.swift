//
//  SpirvGenerator.swift
//  JelloCompiler
//
//  Created by Natalie Cuthbert on 2023/12/07.
//

import Foundation
import simd
import SPIRV_Headers_Swift

fileprivate let generatorMagicNumber: UInt32 = 0x0

fileprivate func buildHeader(bounds: UInt32) -> [UInt32] {
    return [
        SpvMagicNumber,
        UInt32(SPV_VERSION),
        generatorMagicNumber,
        bounds,
        UInt32(0) // Schema
    ]
}

public struct Instruction {
    public let opCode: SpvOp
    public var id: UInt32? = nil
    public var resultId: UInt32? = nil
    public var operands: [UInt32]
    
    public init(opCode: SpvOp, id: UInt32? = nil, resultId: UInt32? = nil, operands: [UInt32] = []) {
        self.opCode = opCode
        self.id = id
        self.resultId = resultId
        self.operands = operands
    }
    
     
    func length() -> UInt32 {
        var sum: UInt32 = 1
        sum += id != nil ? 1: 0
        sum += resultId != nil ? 1 : 0
        return sum + UInt32(operands.count)
    }
    
    
    public mutating func appendOperand(bool: Bool){
        operands.append(bool ? 0x1: 0x0)
    }
    
    public mutating func appendOperand(string: String){
        let data = Data(string.utf8)
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
    }
    
    public mutating func appendOperand(float: Float){
        operands.append(float.bitPattern)
    }
    
    public mutating func appendOperand(int: Int32){
        operands.append(UInt32(bitPattern: int))
    }
    
    public func build() -> [UInt32] {
        let opCode: UInt32 =  (self.length() << 16) | self.opCode.rawValue
        var arr = [opCode]
        if let id = self.id {
            arr.append(id)
        }
        if let resultId = self.resultId {
            arr.append(resultId)
        }
        arr.append(contentsOf: self.operands)
        return arr
    }
}



public func buildOutput(instructions: [Instruction], bounds: UInt32) -> [UInt32] {
    var output = buildHeader(bounds: bounds)
    output.append(contentsOf: instructions.flatMap({instruction in instruction.build()}))
    return output
}


