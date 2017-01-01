//
//  MagmaProtocolTests.swift
//  AlgebraicCheck
//
//  Created by TJ Usiyan on 2016/12/28.
//  Copyright © 2016 Buttons and Lights LLC. All rights reserved.
//

import XCTest
import SwiftCheck
import AlgebraicCheck

typealias CBinOp<Element : Arbitrary> = ClosedBinaryOperation<Element>

class MagmaProtocolTests : XCTestCase {
    func testMagma() {
        properties(Int.self, forms: Magma(operation: CBinOp<Int>(+)))
        properties(Int.self, forms: Magma(operation: CBinOp<Int>(*)))
    }

    func testQuasigroup() {
        properties(Int.self, forms: Quasigroup(operation: CBinOp<Int>(-), latinSquare: { (-($1 - $0), ($1 + $0)) }))
    }

    func testLoop() {
        properties(Int.self, forms: Loop(operation: CBinOp<Int>(+), identity: 0, latinSquare: { (($1 - $0), ($1 - $0)) }))
    }

    func testSemigroup() {
        properties(Int.self, forms: Semigroup(operation: CBinOp<Int>(+)))
    }

    func testMonoid() {
        properties(Int.self, forms: Monoid(operation: CBinOp<Int>(+), identity: 0))
    }

    func testGroup() {
        properties(Int.self, forms: Group(operation: CBinOp<Int>(+), identity: 0, inverseOp: (-)))
    }

    func testAbelianGroup() {
        properties(Int.self, forms: AbelianGroup(operation: CBinOp<Int>(+), identity: 0, inverseOp: (-)))
    }

    func testSemilattice() {
        properties(Int.self, forms: Semilattice(operation: CBinOp(+), idempotentElement: 0))
        properties(Int.self, forms: Semilattice(operation: CBinOp(*), idempotentElement: 1))
    }
}
