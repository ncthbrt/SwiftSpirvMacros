import SpirvMacros
import SpirvMacrosShared
import SPIRV_Headers_Swift
import simd

@SpirvStruct
struct Frog {
    var a: Int32
}


let result: [UInt32] = #document({
    #capability(opCode: SpvOpCapability, [SpvCapabilityShader.rawValue])
    #memoryModel(opCode: SpvOpMemoryModel, [SpvAddressingModelLogical.rawValue, SpvMemoryModelGLSL450.rawValue])
    let typeVoid = #typeDeclaration(opCode: SpvOpTypeVoid)
  
    let structTypeId = Frog.register()
    let _ = #fn(name: "Frog",  argType1: structTypeId) { frog in
        #functionDefinition(opCode: SpvOpReturn, [])
    }
    
    
    // Entry Point
    let entryPoint = #id
    #entryPoint(opCode: SpvOpEntryPoint, [SpvExecutionModelVertex.rawValue], [entryPoint], #stringLiteral("frogFunc"))
    let typeFunction = #typeDeclaration(opCode: SpvOpTypeFunction, [typeVoid])
    #functionDefinition(opCode: SpvOpFunction, [typeVoid, entryPoint, 0, typeFunction])
    let _ = #functionDefinitionWithResult(opCode: SpvOpLabel)
    
    #functionDefinition(opCode: SpvOpReturn)
    #functionDefinition(opCode: SpvOpFunctionEnd)
    
})

print("Result is \(result)")

