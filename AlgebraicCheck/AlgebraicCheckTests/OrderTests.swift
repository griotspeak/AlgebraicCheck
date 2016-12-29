//
//  OrderTests.swift
//  AlgebraicCheck
//
//  Created by TJ Usiyan on 2016/12/28.
//  Copyright © 2016 Buttons and Lights LLC. All rights reserved.
//

import XCTest
import SwiftCheck
import AlgebraicCheck

typealias HRel<Element : Equatable & Arbitrary> = HomogenousRelation<Element>

class OrderTests : XCTestCase {
    func testPartialOrder() {
        properties(Int.self, has: PartialOrder(relation: HRel<Int>(<=), equivalence: ==))
    }

    func testTotalOrder() {
        properties(Int.self, has: TotalOrder(relation: HRel<Int>(<=), equivalence: ==))
    }

    func testAsymmetric() {
        properties(Int.self, has: Int.form(relation: <, algebraicProperties: [.asymmetric]))
    }

    func testIrreflexive() {
        properties(Int.self, has: Int.form(relation: <, algebraicProperties: [.irreflexive]))
    }

    func testSymmetric() {
        properties(Int.self, has: Int.form(relation: ==, algebraicProperties: [.symmetric]))
        properties(Int.self, has: Int.form(relation: haveEqualParity, algebraicProperties: [.symmetric]))
    }

    func testReflexive() {
        properties(Int.self, has: Int.form(relation: ==, algebraicProperties: [.reflexive]))
        properties(Int.self, has: Int.form(relation: haveEqualParity, algebraicProperties: [.reflexive]))
    }

    func testLeftEuclidian() {
        properties(Int.self, has: Int.form(relation: ==, algebraicProperties: [.leftEuclidian]))
        properties(Int.self, has: Int.form(relation: haveEqualParity, algebraicProperties: [.leftEuclidian]))
    }

    func testRightEuclidian() {
        properties(Int.self, has: Int.form(relation: ==, algebraicProperties: [.rightEuclidian]))
        properties(Int.self, has: Int.form(relation: haveEqualParity, algebraicProperties: [.rightEuclidian]))
    }
}

fileprivate func haveEqualParity(_ lhs: Int, _ rhs: Int) -> Bool {
    return (lhs % 2 == 0) == (rhs % 2 == 0)
}
