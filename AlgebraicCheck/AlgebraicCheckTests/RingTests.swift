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

    func testSemiring() {
        let add = Monoid(operation: CBinOp<Int>(+), identity: 0)
        let multiply = Monoid(operation: CBinOp<Int>(*), identity: 1)

        properties(structure: Semiring(additionDescription: "addition", addition: add, multiplication: multiply, multiplicativeAbsorbingElement: 0))
    }

    func testRing() {
        let add = AbelianGroup(operation: CBinOp<Int>(+), identity: 0, inverseOp: (-))
        let multiply = Monoid(operation: CBinOp<Int>(*), identity: 1)

        properties(structure: Ring<Int>(additionDescription: "addition", addition: add, multiplication: multiply, multiplicativeAbsorbingElement: 0))
    }

//    func testNoncommutativRing() {
//        let addOp = CBinOp<Int?> {
//            guard let lhs = optionalLhs,
//                let rhs = optionalRhs else {
//                    return nil
//            }
//            return lhs + rhs
//        }
//        let add = AbelianGroup(operation: addOp, identity: 0, inverseOp: (-))
//
//
//        let divOp = CBinOp<Int?> { (optionalLhs, optionalRhs) in
//            guard let lhs = optionalLhs,
//                let rhs = optionalRhs,
//                rhs != 0 else {
//                    return nil
//            }
//
//            return lhs / rhs
//        }
//        let multiply = Monoid(operation: divOp, identity: 1)
//
//        properties(structure: NoncommutativeRing<Int?>(additionDescription: "addition", addition: add, multiplication: multiply, commutativityCounterExample: <#T##(Int, Int)#>))
//    }

    func testCommutativeRing() {
        let add = AbelianGroup(operation: CBinOp<Int>(+), identity: 0, inverseOp: (-))
        let multiply = Monoid(operation: CBinOp<Int>(*), identity: 1)

        properties(structure: CommutativeRing<Int>(additionDescription: "addition", addition: add, multiplication: multiply))
    }
}

