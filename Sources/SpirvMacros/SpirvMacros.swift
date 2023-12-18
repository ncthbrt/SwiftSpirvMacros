import SpirvMacrosShared
import SPIRV_Headers_Swift

@freestanding(expression)
public macro document(_ value: () -> Void) -> [UInt32] = #externalMacro(module: "SpirvMacrosMacros", type: "SpirvDocumentMacro")

@freestanding(expression)
public macro id() -> UInt32 = #externalMacro(module: "SpirvMacrosMacros", type: "SpirvIdMacro")

@freestanding(expression)
public macro stringLiteral(_ value: String) -> [UInt32] = #externalMacro(module: "SpirvMacrosMacros", type: "SpirvStringLiteralMacro")


@freestanding(expression)
public macro capability(opCode: SpvOp, _ operands: [UInt32]...) = #externalMacro(module: "SpirvMacrosMacros", type: "SpirvCapabilityMacro")


@freestanding(expression)
public macro capabilityWithResult(opCode: SpvOp, _ operands: [UInt32]...) -> UInt32 = #externalMacro(module: "SpirvMacrosMacros", type: "SpirvCapabilityResultMacro")


@freestanding(expression)
public macro ext(opCode: SpvOp, _ operands: [UInt32]...) = #externalMacro(module: "SpirvMacrosMacros", type: "SpirvExtensionMacro")


@freestanding(expression)
public macro extWithResult(opCode: SpvOp, _ operands: [UInt32]...) -> UInt32 = #externalMacro(module: "SpirvMacrosMacros", type: "SpirvExtensionResultMacro")

@freestanding(expression)
public macro extInstImport(opCode: SpvOp, _ operands: [UInt32]...) = #externalMacro(module: "SpirvMacrosMacros", type: "SpirvExtInstImportMacro")


@freestanding(expression)
public macro extInstImportWithResult(opCode: SpvOp, _ operands: [UInt32]...) -> UInt32 = #externalMacro(module: "SpirvMacrosMacros", type: "SpirvExtInstImportResultMacro")


@freestanding(expression)
public macro memoryModel(opCode: SpvOp, _ operands: [UInt32]...) = #externalMacro(module: "SpirvMacrosMacros", type: "SpirvMemoryModelMacro")


@freestanding(expression)
public macro memoryModelWithResult(opCode: SpvOp, _ operands: [UInt32]...) -> UInt32 = #externalMacro(module: "SpirvMacrosMacros", type: "SpirvMemoryModelMacroResultMacro")

@freestanding(expression)
public macro entryPoint(opCode: SpvOp, _ operands: [UInt32]...) = #externalMacro(module: "SpirvMacrosMacros", type: "SpirvEntryPointMacro")


@freestanding(expression)
public macro entryPointWithResult(opCode: SpvOp, _ operands: [UInt32]...) -> UInt32 = #externalMacro(module: "SpirvMacrosMacros", type: "SpirvEntryPointResultMacro")


@freestanding(expression)
public macro executionMode(opCode: SpvOp, _ operands: [UInt32]...) = #externalMacro(module: "SpirvMacrosMacros", type: "SpirvExecutionModeMacro")


@freestanding(expression)
public macro executionModeWithResult(opCode: SpvOp, _ operands: [UInt32]...) -> UInt32 = #externalMacro(module: "SpirvMacrosMacros", type: "SpirvExecutionModeResultMacro")

@freestanding(expression)
public macro debugSource(opCode: SpvOp, _ operands: [UInt32]...) = #externalMacro(module: "SpirvMacrosMacros", type: "SpirvDebugSourceMacro")


@freestanding(expression)
public macro debugSourceWithResult(opCode: SpvOp, _ operands: [UInt32]...) -> UInt32 = #externalMacro(module: "SpirvMacrosMacros", type: "SpirvDebugSourceResultMacro")

@freestanding(expression)
public macro debugNames(opCode: SpvOp, _ operands: [UInt32]...) = #externalMacro(module: "SpirvMacrosMacros", type: "SpirvDebugNamesMacro")


@freestanding(expression)
public macro debugNamesWithResult(opCode: SpvOp, _ operands: [UInt32]...) -> UInt32 = #externalMacro(module: "SpirvMacrosMacros", type: "SpirvDebugNamesResultMacro")


@freestanding(expression)
public macro debugModulesProcessed(opCode: SpvOp, _ operands: [UInt32]...) = #externalMacro(module: "SpirvMacrosMacros", type: "SpirvDebugModuleProcessedMacro")


@freestanding(expression)
public macro debugModulesProcessedWithResult(opCode: SpvOp, _ operands: [UInt32]...) -> UInt32 = #externalMacro(module: "SpirvMacrosMacros", type: "SpirvDebugModuleProcessedResultMacro")



@freestanding(expression)
public macro annotation(opCode: SpvOp, _ operands: [UInt32]...) = #externalMacro(module: "SpirvMacrosMacros", type: "SpirvAnnotationMacro")


@freestanding(expression)
public macro annotationWithResult(opCode: SpvOp, _ operands: [UInt32]...) -> UInt32 = #externalMacro(module: "SpirvMacrosMacros", type: "SpirvAnnotationMacro")



@freestanding(expression)
public macro globalDeclaration(opCode: SpvOp, _ operands: [UInt32]...) = #externalMacro(module: "SpirvMacrosMacros", type: "SpirvGlobalDeclarationMacro")



@freestanding(expression)
public macro typeDeclaration(opCode: SpvOp, _ operands: [UInt32]...) -> UInt32 = #externalMacro(module: "SpirvMacrosMacros", type: "SpirvTypeDeclarationMacro")



@freestanding(expression)
public macro globalDeclarationWithResult(opCode: SpvOp, _ operands: [UInt32]...) -> UInt32 = #externalMacro(module: "SpirvMacrosMacros", type: "SpirvGlobalDeclarationResultMacro")


@freestanding(expression)
public macro functionDeclaration(opCode: SpvOp, _ operands: [UInt32]...) = #externalMacro(module: "SpirvMacrosMacros", type: "SpirvFunctionDeclarationMacro")


@freestanding(expression)
public macro functionDeclarationWithResult(opCode: SpvOp, _ operands: [UInt32]...) -> UInt32 = #externalMacro(module: "SpirvMacrosMacros", type: "SpirvFunctionDeclarationResultMacro")



@freestanding(expression)
public macro functionDefinition(opCode: SpvOp, _ operands: [UInt32]...) = #externalMacro(module: "SpirvMacrosMacros", type: "SpirvFunctionDefinitionMacro")


@freestanding(expression)
public macro functionDefinitionWithResult(opCode: SpvOp, _ operands: [UInt32]...) -> UInt32 = #externalMacro(module: "SpirvMacrosMacros", type: "SpirvFunctionDefinitionResultMacro")


@attached(extension, names: arbitrary, conformances: SpirvStructDecl)
public macro SpirvStruct() = #externalMacro(module: "SpirvMacrosMacros", type: "SpirvStructMacro")


@freestanding(expression)
public macro fn(name: String? = nil, returnType: UInt32? = nil, _ funcDefinition: () -> Void) -> (() -> UInt32) = #externalMacro(module: "SpirvMacrosMacros", type: "SpirvFuncMacro")

@freestanding(expression)
public macro fn(name: String? = nil, argType1: UInt32, returnType: UInt32? = nil, _ funcDefinition: (UInt32) -> Void) -> ((UInt32) -> UInt32) = #externalMacro(module: "SpirvMacrosMacros", type: "SpirvFuncMacro")


@freestanding(expression)
public macro fn(name: String? = nil, _ argType1: UInt32, _ argType2: UInt32, returnType: UInt32? = nil, _ funcDefinition: (UInt32, UInt32) -> Void) -> ((UInt32, UInt32) -> UInt32)  = #externalMacro(module: "SpirvMacrosMacros", type: "SpirvFuncMacro")


@freestanding(expression)
public macro fn(name: String? = nil, _ argType1: UInt32, _ argType2: UInt32, argType3: UInt32, returnType: UInt32? = nil, _ funcDefinition: (UInt32, UInt32, UInt32) -> Void) -> ((UInt32, UInt32, UInt32) -> UInt32) = #externalMacro(module: "SpirvMacrosMacros", type: "SpirvFuncMacro")


@freestanding(expression)
public macro fn(name: String? = nil, _ argType1: UInt32, _ argType2: UInt32, argType3: UInt32, argType4: UInt32, returnType: UInt32? = nil, _ funcDefinition: (UInt32, UInt32, UInt32, UInt32) -> Void) -> ((UInt32, UInt32, UInt32, UInt32) -> UInt32) = #externalMacro(module: "SpirvMacrosMacros", type: "SpirvFuncMacro")


@freestanding(expression)
public macro fn(name: String? = nil, _ argType1: UInt32, _ argType2: UInt32, argType3: UInt32, argType4: UInt32, argType5: UInt32, returnType: UInt32? = nil, _ funcDefinition: (UInt32, UInt32, UInt32, UInt32, UInt32) -> Void) -> ((UInt32, UInt32, UInt32, UInt32, UInt32) -> UInt32) = #externalMacro(module: "SpirvMacrosMacros", type: "SpirvFuncMacro")


@freestanding(expression)
public macro fn(name: String? = nil, _ argType1: UInt32, _ argType2: UInt32, argType3: UInt32, argType4: UInt32, argType5: UInt32, argType6: UInt32, returnType: UInt32? = nil, _ funcDefinition: (UInt32, UInt32, UInt32, UInt32, UInt32, UInt32) -> Void) -> ((UInt32, UInt32, UInt32, UInt32, UInt32, UInt32) -> UInt32) = #externalMacro(module: "SpirvMacrosMacros", type: "SpirvFuncMacro")


@freestanding(expression)
public macro iff(_ cond: UInt32, _ ifTrue: () -> Void , els: () -> Void) -> Void = #externalMacro(module: "SpirvMacrosMacros", type: "SpirvIfElseMacro")

@freestanding(expression)
public macro iff(_ cond: UInt32, _ ifTrue: () -> Void) -> Void = #externalMacro(module: "SpirvMacrosMacros", type: "SpirvIfElseMacro")
