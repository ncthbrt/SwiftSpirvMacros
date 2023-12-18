import SpirvMacros
import SpirvMacrosShared
import SPIRV_Headers_Swift
import simd

@SpirvStruct
struct Cat {
    var c: Float
}

@SpirvStruct
struct Frog {
    var a: Int32
    var b: Cat
}


let result: [UInt32] = #document({
    #capability(opCode: SpvOpCapability, [SpvCapabilityShader.rawValue])
    #memoryModel(opCode: SpvOpMemoryModel, [SpvAddressingModelLogical.rawValue, SpvMemoryModelGLSL450.rawValue])

    let _ = Cat.register()
    let frogStructTypeId = Frog.register()
    let (_, createFrogPointer) = Frog.registerPointerType(storageClass: SpvStorageClassOutput)
    
    let frogFunc = #fn(name: "Frog",  argType1: frogStructTypeId, returnType: frogStructTypeId) { frog in
        let frogValue = Frog(a: 1, b: Cat(c: 2.5)).writeSpirvCompositeConstant()
        #functionDefinition(opCode: SpvOpReturnValue, [frogValue])
    }
    

    
    // Entry Point
    let typeBool = #typeDeclaration(opCode: SpvOpTypeBool)
    let typeVoid = #typeDeclaration(opCode: SpvOpTypeVoid)
    let typeFloat = #typeDeclaration(opCode: SpvOpTypeFloat, [32])
    let entryPoint = #id
    let frogPointerId = createFrogPointer()
    
    #debugModulesProcessed(opCode: SpvOpDecorate, [frogPointerId, SpvDecorationLocation.rawValue, 0])
    #entryPoint(opCode: SpvOpEntryPoint, [SpvExecutionModelVertex.rawValue], [entryPoint], #stringLiteral("frogFunc"), [frogPointerId])
    let typeFunction = #typeDeclaration(opCode: SpvOpTypeFunction, [typeVoid])
    #functionDefinition(opCode: SpvOpFunction, [typeVoid, entryPoint, 0, typeFunction])
    let _ = #functionDefinitionWithResult(opCode: SpvOpLabel)
    let frogValue = Frog(a: 0, b: Cat(c: 1)).writeSpirvCompositeConstant()
    let returnValue = frogFunc(frogValue)
    let a1 = #id
    let a2 = #id
    let compareResult = #id
    #functionDefinition(opCode: SpvOpCompositeExtract, [typeFloat, a1, frogValue, 1, 0])
    #functionDefinition(opCode: SpvOpCompositeExtract, [typeFloat, a2, returnValue, 1, 0])
    #functionDefinition(opCode: SpvOpFOrdLessThanEqual, [typeBool, compareResult, a1, a2])
    #iff(compareResult, {
        #functionDefinition(opCode: SpvOpStore, [frogPointerId, frogValue])
    }, els: {
        #functionDefinition(opCode: SpvOpStore, [frogPointerId, returnValue])
    })
    #functionDefinition(opCode: SpvOpReturn, [])
    #functionDefinition(opCode: SpvOpFunctionEnd)
})

print("Result is \(result)")

