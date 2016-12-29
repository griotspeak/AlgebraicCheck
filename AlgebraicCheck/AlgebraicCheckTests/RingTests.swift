//
//  RingTests.swift
//  AlgebraicCheck
//
//  Created by TJ Usiyan on 2016/12/29.
//  Copyright © 2016 Buttons and Lights LLC. All rights reserved.
//

import XCTest
import SwiftCheck
import AlgebraicCheck

class RingTests : XCTestCase {
    func testBasicRing() {
        let add = AbelianGroup(operation: CBinOp<Int>(+), identity: 0, inverseOp: (-))
        let multiply = Monoid(operation: CBinOp<Int>(*), identity: 1)

        properties(structure: Ring<Int>(additionDescription: "addition", addition: add, multiplication: multiply))
    }
}
