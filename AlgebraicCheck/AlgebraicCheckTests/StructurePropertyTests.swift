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

    func testLeftAbsorbingElement() {
        properties(Int.self, forms: Int.form(operation: *, algebraicProperties: [StructureProperty.leftAbsorbingElement(0)]))
    }

    func testRightAbsorbingElement() {
        properties(Int.self, forms: Int.form(operation: *, algebraicProperties: [StructureProperty.rightAbsorbingElement(0)]))
    }

    func testAbsorbingElement() {
        properties(Int.self, forms: Int.form(operation: *, algebraicProperties: [StructureProperty.absorbingElement(0)]))
    }

    func testLeftIdentityElement() {
        properties(Int.self, forms: Int.form(operation: *, algebraicProperties: [StructureProperty.leftIdentity(1)]))
    }

    func testRightIdentityElement() {
        properties(Int.self, forms: Int.form(operation: *, algebraicProperties: [StructureProperty.rightIdentity(1)]))
    }

    func testIdentityElement() {
        properties(Int.self, forms: Int.form(operation: *, algebraicProperties: [StructureProperty.identity(1)]))
    }
    
    func testTotalDescription() {
//        let property: StructureProperty<ClosedBinaryOperation<Int>> = StructureProperty.associativity
//        let result = property.concretize(with: ClosedBinaryOperation<Int>(+)
    }
}
