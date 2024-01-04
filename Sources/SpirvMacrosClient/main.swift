//import SpirvMacros
//import SpirvMacrosShared
//import SPIRV_Headers_Swift
//import simd
//
//@SpirvStruct
//struct Cat {
//    var c: Float
//}
//
//@SpirvStruct
//struct Frog {
//    var a: Int32
//    var b: Cat
//}
//
//
//let result: [UInt32] = #document({
//    #capability(opCode: SpirvOpCapability, [SpirvCapabilityShader.rawValue])
//    #memoryModel(opCode: SpirvOpMemoryModel, [SpirvAddressingModelLogical.rawValue, SpirvMemoryModelGLSL450.rawValue])
//
//    let _ = Cat.register()
//    let frogStructTypeId = Frog.register()
//    let (_, createFrogPointer) = Frog.registerPointerType(storageClass: SpirvStorageClassOutput)
//    
//    let frogFunc = #fn(name: "Frog",  argType1: frogStructTypeId, returnType: frogStructTypeId) { frog in
//        let frogValue = Frog(a: 1, b: Cat(c: 2.5)).writeSpirvCompositeConstant()
//        #functionBody(opCode: SpirvOpReturnValue, [frogValue])
//    }
//    
//
//    
//    // Entry Point
//    let typeBool = #typeDeclaration(opCode: SpirvOpTypeBool)
//    let typeVoid = #typeDeclaration(opCode: SpirvOpTypeVoid)
//    let typeFloat = #typeDeclaration(opCode: SpirvOpTypeFloat, [32])
//    let entryPoint = #id
//    let frogPointerId = createFrogPointer()
//    
//    #debugModulesProcessed(opCode: SpirvOpDecorate, [frogPointerId, SpirvDecorationLocation.rawValue, 0])
//    #entryPoint(opCode: SpirvOpEntryPoint, [SpirvExecutionModelVertex.rawValue], [entryPoint], #stringLiteral("frogFunc"), [frogPointerId])
//    let typeFunction = #typeDeclaration(opCode: SpirvOpTypeFunction, [typeVoid])
//    #functionHead(opCode: SpirvOpFunction, [typeVoid, entryPoint, 0, typeFunction])
//    #functionHead(opCode: SpirvOpLabel, [#id])
//    let frogValue = Frog(a: 0, b: Cat(c: 1)).writeSpirvCompositeConstant()
//    let returnValue = frogFunc(frogValue)
//    let a1 = #id
//    let a2 = #id
//    let compareResult = #id
//    #functionBody(opCode: SpirvOpCompositeExtract, [typeFloat, a1, frogValue, 1, 0])
//    #functionBody(opCode: SpirvOpCompositeExtract, [typeFloat, a2, returnValue, 1, 0])
//    #functionBody(opCode: SpirvOpFOrdLessThanEqual, [typeBool, compareResult, a1, a2])
//    #iff(compareResult) {
//        #functionBody(opCode: SpirvOpStore, [frogPointerId, frogValue])
//    } els: {
//        #functionBody(opCode: SpirvOpStore, [frogPointerId, returnValue])
//    }
//    #forRange(5) { i in
//    }
//    
//    #functionBody(opCode: SpirvOpReturn, [])
//    #functionBody(opCode: SpirvOpFunctionEnd)
//    SpirvFunction.instance.writeFunction()
//})
//
//print("Result is \(result)")
//
