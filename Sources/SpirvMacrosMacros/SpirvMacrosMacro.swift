import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import Foundation
import SpirvMacrosShared
import simd
import MacroToolkit

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


public struct SpirvTypeDeclarationMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        let arguments = node.argumentList.map({return "\($0.expression)"})
        return """
({
    let maybeResultId = SpirvTypeCache.instance.tryGetTypeId(op: \(raw: arguments.first!), operands: [\(raw: arguments.dropFirst().joined(separator: ", "))])
    if let id = maybeResultId {
        return id
    }
    let resultId = SpirvTypeCache.instance.allocateNewTypeId(op: \(raw: arguments.first!), operands: [\(raw: arguments.dropFirst().joined(separator: ", "))])
    let instruction = Instruction(opCode: \(raw: arguments.first!), operands: [[resultId], \(raw: arguments.dropFirst().joined(separator: ", "))])
    HeaderlessSpirvDocument.instance.addGlobalDeclarationInstruction(instruction: instruction)
    return resultId
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

func typeDeclaration(op: String, operands: [[UInt32]]) -> String {
    let operandsStr = operands.map({$0.map({op in "[\(op)]"}).joined(separator: ", ")}).joined(separator: ", ")
    return """
    ({
            let maybeResultId = SpirvTypeCache.instance.tryGetTypeId(op: \(op), operands: [\(operandsStr)])
            if let id = maybeResultId {
                return id
            }
            let resultId = SpirvTypeCache.instance.allocateNewTypeId(op: \(op), operands: [\(operandsStr)])
            let instruction = Instruction(opCode: \(op), operands: [[resultId], \(operandsStr)])
            HeaderlessSpirvDocument.instance.addGlobalDeclarationInstruction(instruction: instruction)
            return resultId
    }())
    """
}

let int32Declaration = typeDeclaration(op: "SpvOpTypeInt", operands: [[32], [1]])
let uInt32Declaration = typeDeclaration(op: "SpvOpTypeInt", operands: [[32], [0]])
let floatDeclaration = typeDeclaration(op: "SpvOpTypeFloat", operands: [[32]])

func vectorFloatDeclaration(componentCount: UInt32) -> String {
    """
({
    let floatTypeId = \(floatDeclaration);
    let maybeResultId = SpirvTypeCache.instance.tryGetTypeId(op: SpvOpTypeVector, operands: [[floatTypeId], [\(componentCount)]])
    if let id = maybeResultId {
        return id
    }
    let resultId = SpirvTypeCache.instance.allocateNewTypeId(op: SpvOpTypeVector, operands: [[floatTypeId], [\(componentCount)]])
    let instruction = Instruction(opCode: SpvOpTypeVector, operands: [[resultId], [floatTypeId], [\(componentCount)]])
    HeaderlessSpirvDocument.instance.addGlobalDeclarationInstruction(instruction: instruction)
    return resultId
}())
"""
}


func floatMatrixDeclaration(rows: UInt32, columns: UInt32) -> String {
    """
({
    let vectorTypeId = \(vectorFloatDeclaration(componentCount: rows));
    let maybeResultId = SpirvTypeCache.instance.tryGetTypeId(op: SpvOpTypeMatrix, operands: [[vectorTypeId, \(columns)]])
    if let id = maybeResultId {
        return id
    }
    let resultId = SpirvTypeCache.instance.allocateNewTypeId(op: SpvOpTypeMatrix, operands: [[vectorTypeId, \(columns)]])
    let instruction = Instruction(opCode: SpvOpTypeMatrix, operands: [[resultId, vectorTypeId, \(columns)]])
    HeaderlessSpirvDocument.instance.addGlobalDeclarationInstruction(instruction: instruction)
    return resultId
}())
"""
}




public struct SpirvStructMacro: ExtensionMacro {
    public static func expansion(of node: AttributeSyntax, attachedTo declaration: some DeclGroupSyntax, providingExtensionsOf type: some TypeSyntaxProtocol, conformingTo protocols: [TypeSyntax], in context: some MacroExpansionContext) throws -> [ExtensionDeclSyntax] {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            fatalError("Requires a struct declaration")
        }
        let structName = structDecl.name.text
        let structNameBytes = string(structName)
        
        let members = structDecl.memberBlock.members
            .map({$0.decl.as(VariableDeclSyntax.self)})
            .filter({$0 != nil})
            .map({$0!})
        let patternBindings = members
            .map({$0.bindings.first?.as(PatternBindingSyntax.self)})
            .filter({$0 != nil})
        
        let memberBindingNames =
        patternBindings
            .map({$0!.pattern.as(IdentifierPatternSyntax.self)})
            .map({$0?.identifier.text})
        let memberBindingTypes =
        patternBindings
            .map({$0!.typeAnnotation?.type.as(IdentifierTypeSyntax.self)?.name})
            .filter({$0 != nil})
        let memberBindingSpecifierTypes = members.map({$0.bindingSpecifier.tokenKind == .keyword(.var) ? Keyword.var : Keyword.let})
        
        if memberBindingNames.count != memberBindingTypes.count || memberBindingSpecifierTypes.count != memberBindingNames.count {
            fatalError("Unexpected struct layout")
        }
        
        var typeLines: [String] = []
        var layoutLines: [String] = []
        var structOperands: [String] = []
        
        for i in 0..<memberBindingNames.count {
            layoutLines.append("""
HeaderlessSpirvDocument.instance.addDebugNamesInstruction(instruction: Instruction(opCode: SpvOpMemberName, operands: [[newStructId, \(i)], [\(string(memberBindingNames[i]!).map({"\($0)"}).joined(separator: ", "))]]))
""")
            structOperands.append("structTypeId_\(i)")
            
            switch (memberBindingTypes[i]?.text){
            case "Int", "Int32":
                typeLines.append("""
let structTypeId_\(i) = \(int32Declaration);
""")
                break
            case "UInt32":
                typeLines.append("""
let structTypeId_\(i) = \(uInt32Declaration);
""")
                break
            case "Float":
                typeLines.append("""
let structTypeId_\(i) = \(floatDeclaration);
""")
                break
            case "vector_float2":
                typeLines.append("""
let structTypeId_\(i) = \(vectorFloatDeclaration(componentCount: 2));
""")
                break
            case "vector_float3":
                typeLines.append("""
let structTypeId_\(i) = \(vectorFloatDeclaration(componentCount: 3));
""")
                break
            case "vector_float4":
                typeLines.append("""
let structTypeId_\(i) = \(vectorFloatDeclaration(componentCount: 4));
""")
                
            case "vector_float8":
                typeLines.append("""
let structTypeId_\(i) = \(vectorFloatDeclaration(componentCount: 8));
""")
                break
                
            case "matrix_float2x2":
                typeLines.append("""
let structTypeId_\(i) = \(floatMatrixDeclaration(rows: 2, columns: 2));
""")
                break
                
            case "matrix_float2x4":
                typeLines.append("""
let structTypeId_\(i) = \(floatMatrixDeclaration(rows: 2, columns: 4));
""")
                break
                
            case "matrix_float2x3":
                typeLines.append("""
let structTypeId_\(i) = \(floatMatrixDeclaration(rows: 2, columns: 3));
""")
                break
            case "matrix_float3x2":
                typeLines.append("""
let structTypeId_\(i) = \(floatMatrixDeclaration(rows: 3, columns: 2));
""")
                break
            case "matrix_float3x3":
                typeLines.append("""
let structTypeId_\(i) = \(floatMatrixDeclaration(rows: 3, columns: 3));
""")
                break
                
            case "matrix_float3x4":
                typeLines.append("""
let structTypeId_\(i) = \(floatMatrixDeclaration(rows: 3, columns: 4));
""")
                break
            case "matrix_float4x2":
                typeLines.append("""
let structTypeId_\(i) = \(floatMatrixDeclaration(rows: 4, columns: 2));
""")
                break
                
            case "matrix_float4x3":
                typeLines.append("""
let structTypeId_\(i) = \(floatMatrixDeclaration(rows: 4, columns: 3));
""")
                break
            case "matrix_float4x4":
                typeLines.append("""
let structTypeId_\(i) = \(floatMatrixDeclaration(rows: 4, columns: 4));
""")
                break
            default:
                fatalError("\(memberBindingTypes[i]?.text ?? "Unknown") is not a supportedType")
            }
        }
        return [try! ExtensionDeclSyntax("""
extension \(structDecl.name) : SpirvStructDecl {
    public static func register() -> UInt32 {
        if let structId = SpirvTypeCache.instance.tryGetTypeId(structName: "\(raw: structName)") {
            return structId
        }
        \(raw: typeLines.joined(separator: "\n"))
        let newStructId = SpirvTypeCache.instance.allocateNewTypeId(structName: "\(raw: structName)")
        let structInstruction = Instruction(opCode: SpvOpTypeStruct, operands: [[newStructId], [\(raw: structOperands.joined(separator: ", "))]])
        HeaderlessSpirvDocument.instance.addGlobalDeclarationInstruction(instruction: structInstruction)
        HeaderlessSpirvDocument.instance.addDebugNamesInstruction(instruction: Instruction(opCode: SpvOpName, operands: [[newStructId], [\(raw: structNameBytes.map({"\($0)"}).joined(separator: ", "))]]))
        \(raw: layoutLines.joined(separator: "\n"))
        return newStructId
    }
}
""")]
    }
}


public struct SpirvFuncMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        let args = node.argumentList
        
        var name: ExprSyntax? = nil
        if let fst = args.first, fst.label?.text == "name" {
            let literalBytes = string(MacroToolkit.StringLiteral(fst.expression)?.value ?? "")
            name = "HeaderlessSpirvDocument.instance.addDebugNamesInstruction(instruction: Instruction(opCode: SpvOpName, operands: [[funcId], [\(raw: literalBytes.map({"\($0)"}).joined(separator: ", "))]]))"
        }
        
        var maybeVoid: String? = nil
        var resultTypeVariable: ExprSyntax = "typeVoid"
        if let resultType = args.first(where: { $0.label?.text == "returnType"}) {
            resultTypeVariable = resultType.expression
        } else {
            maybeVoid = "let typeVoid = \(typeDeclaration(op: "SpvOpTypeVoid", operands: [[]]))"
        }
        
        let argTypes = args.filter({$0.label?.text.starts(with: "argType") ?? false})
        var funcParams = ""
        var funcArgs: [String] = []
        var i = 0
        for arg in argTypes {
            funcParams.append("""
let paramId\(i) = SpirvIdAllocator.instance.allocate()
HeaderlessSpirvDocument.instance.addFunctionDefinitionInstruction(instruction: Instruction(opCode: SpvOpFunctionParameter, operands: [[\(arg.expression), paramId\(i)]]))
""")
            funcArgs.append("paramId\(i)")
            i += 1
            
        }
        
        guard let trailingClosure = node.trailingClosure else {
            throw MacroError("Requires a trailing closure containing the function body")
        }
        let trailingClosureAttributes = (trailingClosure.signature?.parameterClause?.as(ClosureShorthandParameterListSyntax.self)?
            .filter({$0.is(ClosureShorthandParameterSyntax.self)})
            .map({$0.as(ClosureShorthandParameterSyntax.self)!.name.text}))
        ?? []
        
        i = 0
        var funcArgNames = ""
        for attribute in trailingClosureAttributes {
            let literalBytes = string(attribute)
            funcArgNames.append("HeaderlessSpirvDocument.instance.addDebugNamesInstruction(instruction: Instruction(opCode: SpvOpName, operands: [[paramId\(i)], [\(literalBytes.map({"\($0)"}).joined(separator: ", "))]]))")
            i+=1
        }
        
        
        let functionDefinition = """
HeaderlessSpirvDocument.instance.addFunctionDefinitionInstruction(instruction: Instruction(opCode: SpvOpFunction, operands: [[\(resultTypeVariable), funcId, 0x0, funcTypeId]]))
\(funcParams)
\(funcArgNames)
let functionLabelId = SpirvIdAllocator.instance.allocate()
HeaderlessSpirvDocument.instance.addFunctionDefinitionInstruction(instruction: Instruction(opCode: SpvOpLabel, operands: [[functionLabelId]]))
(\(trailingClosure)(\(funcArgs.joined(separator: ", "))))
HeaderlessSpirvDocument.instance.addFunctionDefinitionInstruction(instruction: Instruction(opCode: SpvOpFunctionEnd, operands: []))
"""
        
        
        
return """
({
    let funcId = SpirvIdAllocator.instance.allocate()
    \(raw: maybeVoid ?? "")
    let funcTypeId =  ({
            let maybeResultId = SpirvTypeCache.instance.tryGetTypeId(op: SpvOpTypeFunction, operands: [[\(resultTypeVariable)], [\(raw: argTypes.map({"\($0.expression)"}).joined(separator: ", "))]])
            if let id = maybeResultId {
                return id
            }
            let resultId = SpirvTypeCache.instance.allocateNewTypeId(op: SpvOpTypeFunction, operands: [[\(resultTypeVariable)], [ \(raw: argTypes.map({"\($0.expression)"}).joined(separator: ", "))]])
            let instruction = Instruction(opCode: SpvOpTypeFunction, operands: [[resultId, \(resultTypeVariable)], [\(raw: argTypes.map({"\($0.expression)"}).joined(separator: ", "))]])
            HeaderlessSpirvDocument.instance.addGlobalDeclarationInstruction(instruction: instruction)
            return resultId
    }())
    \(name ?? "")
    \(raw: functionDefinition)
    return funcId
}())
"""
    }
}




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
        SpirvTypeDeclarationMacro.self,
        SpirvFunctionDeclarationMacro.self,
        SpirvFunctionDeclarationResultMacro.self,
        SpirvFunctionDefinitionMacro.self,
        SpirvFunctionDefinitionResultMacro.self,
        SpirvStructMacro.self,
        SpirvFuncMacro.self
    ]
}
