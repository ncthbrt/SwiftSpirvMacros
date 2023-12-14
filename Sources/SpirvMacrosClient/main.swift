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
    #functionDefinition(opCode: SpvOpFunction, [typeVoid, entryPoint, 0, typeFunction])
    let _ = #functionDefinitionWithResult(opCode: SpvOpLabel)
    #functionDefinition(opCode: SpvOpReturn)
    #functionDefinition(opCode: SpvOpFunctionEnd)
    
    let structTypeId = #strct({
        struct Frog {
            var a: Int32
            var b: vector_float4
            var c: vector_float2
            var d: matrix_float2x2
            var e: matrix_float2x3
            var f: matrix_float2x4
            var g: matrix_float3x2
            var h: matrix_float3x3
            var i: matrix_float3x4
            var j: matrix_float4x2
            var k: matrix_float4x3
            var l: matrix_float4x4
        }
    })
})

print("Result is \(result)")

