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
        #functionBody(opCode: SpvOpReturnValue, [frogValue])
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
    #functionHead(opCode: SpvOpFunction, [typeVoid, entryPoint, 0, typeFunction])
    #functionHead(opCode: SpvOpLabel, [#id])
    let frogValue = Frog(a: 0, b: Cat(c: 1)).writeSpirvCompositeConstant()
    let returnValue = frogFunc(frogValue)
    let a1 = #id
    let a2 = #id
    let compareResult = #id
    #functionBody(opCode: SpvOpCompositeExtract, [typeFloat, a1, frogValue, 1, 0])
    #functionBody(opCode: SpvOpCompositeExtract, [typeFloat, a2, returnValue, 1, 0])
    #functionBody(opCode: SpvOpFOrdLessThanEqual, [typeBool, compareResult, a1, a2])
    #iff(compareResult) {
        #functionBody(opCode: SpvOpStore, [frogPointerId, frogValue])
    } els: {
        #functionBody(opCode: SpvOpStore, [frogPointerId, returnValue])
    }
    #forRange(5) { i in
    }
    
    #functionBody(opCode: SpvOpReturn, [])
    #functionBody(opCode: SpvOpFunctionEnd)
    SpirvFunction.instance.writeFunction()
})

print("Result is \(result)")

