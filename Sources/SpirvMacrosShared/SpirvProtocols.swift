//
//  SpirvProtocols.swift
//
//
//  Created by Natalie Cuthbert on 2023/12/18.
//

import Foundation
import SPIRV_Headers_Swift

public protocol SpirvStructDecl {
    static func register() -> UInt32
    static func registerPointerType(storageClass: SpirvStorageClass) -> (UInt32, () -> UInt32)
//    func writeSpirvCompositeConstant() -> UInt32
}
