import SpirvMacros
import SpirvMacrosShared
import SPIRV_Headers_Swift

let result: [UInt32] = #document({
    #capability(opCode: SpvOpCapability, [SpvCapabilityShader.rawValue])
    #memoryModel(opCode: SpvOpMemoryModel, [SpvAddressingModelLogical.rawValue, SpvMemoryModelGLSL450.rawValue])
    let entryPoint = #id
    #entryPoint(opCode: SpvOpEntryPoint, [SpvExecutionModelVertex.rawValue], [entryPoint], #string("main"))
    let typeVoid = #globalDeclarationWithResult(opCode: SpvOpTypeVoid)
    let typeFunction = #globalDeclarationWithResult(opCode: SpvOpTypeFunction, [typeVoid])
    #functionDefinition(opCode: SpvOpFunction, [entryPoint], [0], [typeFunction])
    let label = #functionDefinitionWithResult(opCode: SpvOpLabel)
    #functionDefinition(opCode: SpvOpReturn)
    #functionDefinition(opCode: SpvOpFunctionEnd)
})

print("Result is \(result)")
