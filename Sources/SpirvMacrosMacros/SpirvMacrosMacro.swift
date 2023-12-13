import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import Foundation

public struct SpirvDocumentMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        guard let argument = node.argumentList.first?.expression else {
            fatalError("compiler bug: the macro does not have any arguments")
        }
        
        return """
        ({
            let prevDocument = HeaderlessSpirvDocument.instance
            let document = HeaderlessSpirvDocument()
            HeaderlessSpirvDocument.instance = document
            
            let prevAllocator = SpirvIdAllocator.instance
            let allocator = SpirvIdAllocator()
            SpirvIdAllocator.instance = allocator

            let prevTypeCache = SpirvTypeCache.instance
            let typeCache = SpirvTypeCache()
            SpirvTypeCache.instance = typeCache

            (\(argument)());

            HeaderlessSpirvDocument.instance = prevDocument
            SpirvIdAllocator.instance = prevAllocator
            SpirvTypeCache.instance = prevTypeCache
            
            let bounds = allocator.lastAllocation + 1
            return buildSpirv(document: document, bounds: bounds)
        }())
"""
    }
}


public struct SpirvIdMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        return "SpirvIdAllocator.instance.allocate()"
    }
}


public struct SpirvStringLiteralMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        guard let argument = node.argumentList.first?.expression,
              let segments = argument.as(StringLiteralExprSyntax.self)?.segments,
              segments.count == 1,
              case .stringSegment(let literalSegment)? = segments.first
        else {
            fatalError("#string requires a static string literal")
        }
        
        var operands: [UInt32] = []
        let data = Data("\(literalSegment)".utf8)
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
        
        return "[\(raw: operands.map({ "\($0)"}).joined(separator: ", "))]"
    }
}


public struct SpirvCapabilityMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        let arguments = node.argumentList.map({return "\($0.expression)"})
        
        return """
({
    let instruction = Instruction(opCode: \(raw: arguments.first!), operands: [\(raw: arguments.dropFirst().joined(separator: ", "))])
    HeaderlessSpirvDocument.instance.addCapabilityInstruction(instruction: instruction)
}())
"""
    }
}

public struct SpirvCapabilityResultMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        let arguments = node.argumentList.map({return "\($0.expression)"})
        return """
({
    let resultId = SpirvIdAllocator.instance.allocate()
    let instruction = Instruction(opCode: \(raw: arguments.first!), operands: [[resultId], \(raw: arguments.dropFirst().joined(separator: ", "))])
    HeaderlessSpirvDocument.instance.addCapabilityInstruction(instruction: instruction)
    return resultId
}())
"""
    }
}

public struct SpirvExtensionMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        let arguments = node.argumentList.map({return "\($0.expression)"})
        
        return """
({
    let instruction = Instruction(opCode: \(raw: arguments.first!), operands: [\(raw: arguments.dropFirst().joined(separator: ", "))])
    HeaderlessSpirvDocument.instance.addExtensionInstruction(instruction: instruction)
}())
"""
    }
}

public struct SpirvExtensionResultMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        let arguments = node.argumentList.map({return "\($0.expression)"})
        return """
({
    let resultId = SpirvIdAllocator.instance.allocate()
    let instruction = Instruction(opCode: \(raw: arguments.first!), operands: [[resultId], \(raw: arguments.dropFirst().joined(separator: ", "))])
    HeaderlessSpirvDocument.instance.addExtensionInstruction(instruction: instruction)
    return resultId
}())
"""
    }
}

public struct SpirvExtInstImportMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        let arguments = node.argumentList.map({return "\($0.expression)"})
        
        return """
({
    let instruction = Instruction(opCode: \(raw: arguments.first!), operands: [\(raw: arguments.dropFirst().joined(separator: ", "))])
    HeaderlessSpirvDocument.instance.addExtInstImportInstruction(instruction: instruction)
}())
"""
    }
}

public struct SpirvExtInstImportResultMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        let arguments = node.argumentList.map({return "\($0.expression)"})
        return """
({
    let resultId = SpirvIdAllocator.instance.allocate()
    let instruction = Instruction(opCode: \(raw: arguments.first!), operands: [[resultId], \(raw: arguments.dropFirst().joined(separator: ", "))])
    HeaderlessSpirvDocument.instance.addExtInstImportInstruction(instruction: instruction)
    return resultId
}())
"""
    }
}


public struct SpirvMemoryModelMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        let arguments = node.argumentList.map({return "\($0.expression)"})
        
        return """
({
    let instruction = Instruction(opCode: \(raw: arguments.first!), operands: [\(raw: arguments.dropFirst().joined(separator: ", "))])
    HeaderlessSpirvDocument.instance.addMemoryModelInstruction(instruction: instruction)
}())
"""
    }
}

public struct SpirvMemoryModelMacroResultMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        let arguments = node.argumentList.map({return "\($0.expression)"})
        return """
({
    let resultId = SpirvIdAllocator.instance.allocate()
    let instruction = Instruction(opCode: \(raw: arguments.first!), operands: [[resultId], \(raw: arguments.dropFirst().joined(separator: ", "))])
    HeaderlessSpirvDocument.instance.addMemoryModelInstruction(instruction: instruction)
    return resultId
}())
"""
    }
}

public struct SpirvEntryPointMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        let arguments = node.argumentList.map({return "\($0.expression)"})
        
        return """
({
    let instruction = Instruction(opCode: \(raw: arguments.first!), operands: [\(raw: arguments.dropFirst().joined(separator: ", "))])
    HeaderlessSpirvDocument.instance.addMemoryModelInstruction(instruction: instruction)
}())
"""
    }
}

public struct SpirvEntryPointResultMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        let arguments = node.argumentList.map({return "\($0.expression)"})
        return """
({
    let resultId = SpirvIdAllocator.instance.allocate()
    let instruction = Instruction(opCode: \(raw: arguments.first!), operands: [[resultId], \(raw: arguments.dropFirst().joined(separator: ", "))])
    HeaderlessSpirvDocument.instance.addMemoryModelInstruction(instruction: instruction)
    return resultId
}())
"""
    }
}


public struct SpirvExecutionModeMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        let arguments = node.argumentList.map({return "\($0.expression)"})
        
        return """
({
    let instruction = Instruction(opCode: \(raw: arguments.first!), operands: [\(raw: arguments.dropFirst().joined(separator: ", "))])
    HeaderlessSpirvDocument.instance.addExecutionModeInstruction(instruction: instruction)
}())
"""
    }
}

public struct SpirvExecutionModeResultMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        let arguments = node.argumentList.map({return "\($0.expression)"})
        return """
({
    let resultId = SpirvIdAllocator.instance.allocate()
    let instruction = Instruction(opCode: \(raw: arguments.first!), operands: [[resultId], \(raw: arguments.dropFirst().joined(separator: ", "))])
    HeaderlessSpirvDocument.instance.addExecutionModeInstruction(instruction: instruction)
    return resultId
}())
"""
    }
}


public struct SpirvDebugSourceMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        let arguments = node.argumentList.map({return "\($0.expression)"})
        
        return """
({
    let instruction = Instruction(opCode: \(raw: arguments.first!), operands: [\(raw: arguments.dropFirst().joined(separator: ", "))])
    HeaderlessSpirvDocument.instance.addDebugSourceInstruction(instruction: instruction)
}())
"""
    }
}

public struct SpirvDebugSourceResultMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        let arguments = node.argumentList.map({return "\($0.expression)"})
        return """
({
    let resultId = SpirvIdAllocator.instance.allocate()
    let instruction = Instruction(opCode: \(raw: arguments.first!), operands: [[resultId], \(raw: arguments.dropFirst().joined(separator: ", "))])
    HeaderlessSpirvDocument.instance.addDebugSourceInstruction(instruction: instruction)
    return resultId
}())
"""
    }
}



public struct SpirvDebugNamesMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        let arguments = node.argumentList.map({return "\($0.expression)"})
        
        return """
({
    let instruction = Instruction(opCode: \(raw: arguments.first!), operands: [\(raw: arguments.dropFirst().joined(separator: ", "))])
    HeaderlessSpirvDocument.instance.addDebugNamesInstruction(instruction: instruction)
}())
"""
    }
}

public struct SpirvDebugNamesResultMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        let arguments = node.argumentList.map({return "\($0.expression)"})
        return """
({
    let resultId = SpirvIdAllocator.instance.allocate()
    let instruction = Instruction(opCode: \(raw: arguments.first!), operands: [[resultId], \(raw: arguments.dropFirst().joined(separator: ", "))])
    HeaderlessSpirvDocument.instance.addDebugNamesInstruction(instruction: instruction)
    return resultId
}())
"""
    }
}


public struct SpirvDebugModuleProcessedMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        let arguments = node.argumentList.map({return "\($0.expression)"})
        
        return """
({
    let instruction = Instruction(opCode: \(raw: arguments.first!), operands: [\(raw: arguments.dropFirst().joined(separator: ", "))])
    HeaderlessSpirvDocument.instance.addDebugModuleProcessedInstructions(instruction: instruction)
}())
"""
    }
}

public struct SpirvDebugModuleProcessedResultMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        let arguments = node.argumentList.map({return "\($0.expression)"})
        return """
({
    let resultId = SpirvIdAllocator.instance.allocate()
    let instruction = Instruction(opCode: \(raw: arguments.first!), operands: [[resultId], \(raw: arguments.dropFirst().joined(separator: ", "))])
    HeaderlessSpirvDocument.instance.addDebugModuleProcessedInstructions(instruction: instruction)
    return resultId
}())
"""
    }
}


public struct SpirvAnnotationMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        let arguments = node.argumentList.map({return "\($0.expression)"})
        
        return """
({
    let instruction = Instruction(opCode: \(raw: arguments.first!), operands: [\(raw: arguments.dropFirst().joined(separator: ", "))])
    HeaderlessSpirvDocument.instance.addAnnotationInstruction(instruction: instruction)
}())
"""
    }
}

public struct SpirvAnnotationResultMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        let arguments = node.argumentList.map({return "\($0.expression)"})
        return """
({
    let resultId = SpirvIdAllocator.instance.allocate()
    let instruction = Instruction(opCode: \(raw: arguments.first!), operands: [[resultId], \(raw: arguments.dropFirst().joined(separator: ", "))])
    HeaderlessSpirvDocument.instance.addAnnotationInstruction(instruction: instruction)
    return resultId
}())
"""
    }
}


public struct SpirvGlobalDeclarationMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        let arguments = node.argumentList.map({return "\($0.expression)"})
        
        return """
({
    let instruction = Instruction(opCode: \(raw: arguments.first!), operands: [\(raw: arguments.dropFirst().joined(separator: ", "))])
    HeaderlessSpirvDocument.instance.addGlobalDeclarationInstruction(instruction: instruction)
}())
"""
    }
}

public struct SpirvGlobalDeclarationResultMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        let arguments = node.argumentList.map({return "\($0.expression)"})
        return """
({
    let resultId = SpirvIdAllocator.instance.allocate()
    let instruction = Instruction(opCode: \(raw: arguments.first!), operands: [[resultId], \(raw: arguments.dropFirst().joined(separator: ", "))])
    HeaderlessSpirvDocument.instance.addGlobalDeclarationInstruction(instruction: instruction)
    return resultId
}())
"""
    }
}

public struct SpirvFunctionDeclarationMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        let arguments = node.argumentList.map({return "\($0.expression)"})
        
        return """
({
    let instruction = Instruction(opCode: \(raw: arguments.first!), operands: [\(raw: arguments.dropFirst().joined(separator: ", "))])
    HeaderlessSpirvDocument.instance.addFunctionDeclarationInstruction(instruction: instruction)
}())
"""
    }
}

public struct SpirvFunctionDeclarationResultMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        let arguments = node.argumentList.map({return "\($0.expression)"})
        return """
({
    let resultId = SpirvIdAllocator.instance.allocate()
    let instruction = Instruction(opCode: \(raw: arguments.first!), operands: [[resultId], \(raw: arguments.dropFirst().joined(separator: ", "))])
    HeaderlessSpirvDocument.instance.addFunctionDeclarationInstruction(instruction: instruction)
    return resultId
}())
"""
    }
}


public struct SpirvFunctionDefinitionMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        let arguments = node.argumentList.map({return "\($0.expression)"})
        
        return """
({
    let instruction = Instruction(opCode: \(raw: arguments.first!), operands: [\(raw: arguments.dropFirst().joined(separator: ", "))])
    HeaderlessSpirvDocument.instance.addFunctionDefinitionInstruction(instruction: instruction)
}())
"""
    }
}

public struct SpirvFunctionDefinitionResultMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        let arguments = node.argumentList.map({return "\($0.expression)"})
        return """
({
    let resultId = SpirvIdAllocator.instance.allocate()
    let instruction = Instruction(opCode: \(raw: arguments.first!), operands: [[resultId], \(raw: arguments.dropFirst().joined(separator: ", "))])
    HeaderlessSpirvDocument.instance.addFunctionDefinitionInstruction(instruction: instruction)
    return resultId
}())
"""
    }
}

//
//public mutating func addFunctionDefinitionInstruction(instruction: Instruction) {
//    functionDefinitions.append(contentsOf: instruction.build())
//}


@main
struct SpirvMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        SpirvDocumentMacro.self,
        SpirvIdMacro.self,
        SpirvStringLiteralMacro.self,
        SpirvCapabilityMacro.self,
        SpirvCapabilityResultMacro.self,
        SpirvExtensionMacro.self,
        SpirvExtensionResultMacro.self,
        SpirvExtInstImportMacro.self,
        SpirvExtInstImportResultMacro.self,
        SpirvMemoryModelMacro.self,
        SpirvMemoryModelMacroResultMacro.self,
        SpirvEntryPointMacro.self,
        SpirvEntryPointResultMacro.self,
        SpirvExecutionModeMacro.self,
        SpirvExecutionModeResultMacro.self,
        SpirvDebugSourceMacro.self,
        SpirvDebugSourceResultMacro.self,
        SpirvDebugNamesMacro.self,
        SpirvDebugNamesResultMacro.self,
        SpirvDebugModuleProcessedMacro.self,
        SpirvDebugModuleProcessedResultMacro.self,
        SpirvAnnotationMacro.self,
        SpirvAnnotationResultMacro.self,
        SpirvGlobalDeclarationMacro.self,
        SpirvGlobalDeclarationResultMacro.self,
        SpirvFunctionDeclarationMacro.self,
        SpirvFunctionDeclarationResultMacro.self,
        SpirvFunctionDefinitionMacro.self,
        SpirvFunctionDefinitionResultMacro.self
    ]
}
