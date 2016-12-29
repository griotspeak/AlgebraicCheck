//
//  StructurePropertyTests.swift
//  AlgebraicCheck
//
//  Created by TJ Usiyan on 2016/12/28.
//  Copyright © 2016 Buttons and Lights LLC. All rights reserved.
//

import XCTest
@testable import AlgebraicCheck

class StructurePropertyTests: XCTestCase {

    func testAllAbsorbingElement() {
        properties(Int.self, forms: Int.form(operation: *, algebraicProperties: [StructureProperty.leftAbsorbingElement(0), StructureProperty.rightAbsorbingElement(0), StructureProperty.absorbingElement(0)]))
    }

    func testTotalDescription() {
//        let property: StructureProperty<ClosedBinaryOperation<Int>> = StructureProperty.associativity
//        let result = property.concretize(with: ClosedBinaryOperation<Int>(+)
    }
}
