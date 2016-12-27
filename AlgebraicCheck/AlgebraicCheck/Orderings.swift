//
//  Orderings.swift
//  AlgebraicCheck
//
//  Created by TJ Usiyan on 2016/12/27.
//  Copyright © 2016 Buttons and Lights LLC. All rights reserved.
//

import SwiftCheck

public struct PartialOrder<Relation : ClosedBinaryRelationProtocol> : BinaryOrderedStructure where Relation.Codomain : Arbitrary {
    public typealias OpType = Relation
    public let relation: Relation
    public let algebraicProperties: [RelationProperty<Relation>]

    public init(relation: Relation, equivalence: @escaping (Relation.Codomain, Relation.Codomain) -> Bool) {
        self.relation = relation
        self.algebraicProperties = [
            RelationProperty.antisymmetric(equivalence: equivalence),
            RelationProperty.transitive,
            RelationProperty.reflexive
        ]
    }
}

public struct TotalOrder<Relation : ClosedBinaryRelationProtocol> : BinaryOrderedStructure where Relation.Codomain : Arbitrary {
    public typealias OpType = Relation
    public let relation: Relation
    public let algebraicProperties: [RelationProperty<Relation>]

    public init(relation: Relation, equivalence: @escaping (Relation.Codomain, Relation.Codomain) -> Bool) {
        self.relation = relation
        self.algebraicProperties = [
            RelationProperty.antisymmetric(equivalence: equivalence),
            RelationProperty.transitive,
            RelationProperty.reflexive,
            RelationProperty.total
        ]
    }
}

