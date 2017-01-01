//
//  RelationTests.swift
//  AlgebraicCheck
//
//  Created by TJ Usiyan on 2017/01/01.
//  Copyright © 2017 Buttons and Lights LLC. All rights reserved.
//

import XCTest
import SwiftCheck
import AlgebraicCheck

class RelationTests : XCTestCase {
    func testEquivalence() {
        properties(Int.self, has: Equivalence(relation: Int.defaultEquivalenceRelation))
        properties(Character.self, has: Equivalence(relation: Character.defaultEquivalenceRelation))
        properties(String.self, has: Equivalence(relation: String.defaultEquivalenceRelation))
    }
}
