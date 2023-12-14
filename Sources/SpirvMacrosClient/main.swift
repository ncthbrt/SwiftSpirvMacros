import SpirvMacros
import SpirvMacrosShared
import SPIRV_Headers_Swift
import simd

let result: [UInt32] = #document({
    #capability(opCode: SpvOpCapability, [SpvCapabilityShader.rawValue])
    #memoryModel(opCode: SpvOpMemoryModel, [SpvAddressingModelLogical.rawValue, SpvMemoryModelGLSL450.rawValue])
    let entryPoint = #id
    #entryPoint(opCode: SpvOpEntryPoint, [SpvExecutionModelVertex.rawValue], [entryPoint], #stringLiteral("main"))
    let typeVoid = #typeDeclaration(opCode: SpvOpTypeVoid)
    let typeFunction = #typeDeclaration(opCode: SpvOpTypeFunction, [typeVoid])
    #functionDefinition(opCode: SpvOpFunction, [entryPoint], [0], [typeFunction])
    let _ = #functionDefinitionWithResult(opCode: SpvOpLabel)
    #functionDefinition(opCode: SpvOpReturn)
    #functionDefinition(opCode: SpvOpFunctionEnd)
    
    let structTypeId = #strct({
        struct Frog {
            var a: Int
            var b: vector_float4
            var c: vector_float2
        }
    })
})

print("Result is \(result)")
