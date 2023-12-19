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
        SpirvMagicNumber,
        UInt32(SPV_VERSION),
        generatorMagicNumber,
        bounds,
        UInt32(0) // Schema
    ]
}

public struct Instruction {
    public let opCode: SpirvOp
    public var operands: [UInt32]
    
    public init(opCode: SpirvOp, operands: [[UInt32]] = []) {
        self.opCode = opCode
        self.operands = operands.flatMap({$0})
    }
    
     
    func length() -> UInt32 {
        let sum: UInt32 = 1
        return sum + UInt32(operands.count)
    }
    
    public func build() -> [UInt32] {
        let opCode: UInt32 =  (self.length() << 16) | self.opCode.rawValue
        var arr = [opCode]
        arr.append(contentsOf: self.operands)
        return arr
    }
}

public class SpirvFunction {
    private var head: [Instruction] = []
    private var instructions: [Instruction] = []
    
    public func addInstructionAtHead(_ instruction:Instruction) {
        head.append(instruction)
    }
    
    public func addInstructionAtBody(_ instruction:Instruction) {
        instructions.append(instruction)
    }
    
    
    public func writeFunction() {
        for h in head {
            HeaderlessSpirvDocument.instance.addFunctionDefinitionInstruction(instruction: h)
        }
        
        for i in instructions {
            HeaderlessSpirvDocument.instance.addFunctionDefinitionInstruction(instruction: i)
        }
        head.removeAll()
        instructions.removeAll()
    }
    
    public static var instance: SpirvFunction = SpirvFunction()

}

public class HeaderlessSpirvDocument {
    private var capabilities : [UInt32] = []
    private var extensions : [UInt32] = []
    private var extInstImports: [UInt32] = []
    private var memoryModels: [UInt32] = []
    private var entryPoints: [UInt32] = []
    private var executionModes: [UInt32] = []
    // Debug Instructions
    private var debugSources: [UInt32] = []
    private var debugNames: [UInt32] = []
    private var debugModuleProcessed: [UInt32] = []
    private var annotations: [UInt32] = []
    private var globalDeclarations: [UInt32] = []
    private var functionDeclarations: [UInt32] = []
    private var functionDefinitions: [UInt32] = []
    
    
    public func addCapabilityInstruction(instruction: Instruction) {
        capabilities.append(contentsOf: instruction.build())
    }
    
    public func addExtensionInstruction(instruction: Instruction) {
        extensions.append(contentsOf: instruction.build())
    }
    
    
    public func addExtInstImportInstruction(instruction: Instruction) {
        extInstImports.append(contentsOf: instruction.build())
    }
    
    public func addMemoryModelInstruction(instruction: Instruction) {
        memoryModels.append(contentsOf: instruction.build())
    }
    
    
    public func addEntryPointInstruction(instruction: Instruction) {
        entryPoints.append(contentsOf: instruction.build())
    }
    
    public func addExecutionModeInstruction(instruction: Instruction) {
        executionModes.append(contentsOf: instruction.build())
    }

    public func addDebugSourceInstruction(instruction: Instruction) {
        debugSources.append(contentsOf: instruction.build())
    }
    
    
    public func addDebugNamesInstruction(instruction: Instruction) {
        debugNames.append(contentsOf: instruction.build())
    }
    
    
    public func addDebugModuleProcessedInstructions(instruction: Instruction) {
        debugModuleProcessed.append(contentsOf: instruction.build())
    }
    
    
    public func addAnnotationInstruction(instruction: Instruction) {
        annotations.append(contentsOf: instruction.build())
    }
    
    
    public func addGlobalDeclarationInstruction(instruction: Instruction) {
        globalDeclarations.append(contentsOf: instruction.build())
    }
    
    
    
    public func addFunctionDeclarationInstruction(instruction: Instruction) {
        functionDeclarations.append(contentsOf: instruction.build())
    }

    
    public func addFunctionDefinitionInstruction(instruction: Instruction) {
        functionDefinitions.append(contentsOf: instruction.build())
    }

    
    fileprivate func build() -> [UInt32] {
        var results: [UInt32] = []
        results.append(contentsOf: capabilities)
        results.append(contentsOf: extensions)
        results.append(contentsOf: extInstImports)
        results.append(contentsOf: memoryModels)
        results.append(contentsOf: entryPoints)
        results.append(contentsOf: executionModes)
        results.append(contentsOf: debugSources)
        results.append(contentsOf: debugNames)
        results.append(contentsOf: debugModuleProcessed)
        results.append(contentsOf: annotations)
        results.append(contentsOf: globalDeclarations)
        results.append(contentsOf: functionDeclarations)
        results.append(contentsOf: functionDefinitions)
        return results
    }
    
    public init() {
        self.capabilities = []
        self.extensions = []
        self.extInstImports = []
        self.memoryModels = []
        self.entryPoints = []
        self.executionModes = []
        self.debugSources = []
        self.debugNames = []
        self.debugModuleProcessed = []
        self.annotations = []
        self.globalDeclarations = []
        self.functionDeclarations = []
        self.functionDefinitions = []
    }
    
    public static var instance: HeaderlessSpirvDocument = HeaderlessSpirvDocument()
}

public func buildSpirv(document: HeaderlessSpirvDocument, bounds: UInt32) -> [UInt32] {
    var output = buildHeader(bounds: bounds)
    output.append(contentsOf: document.build())
    return output
}

