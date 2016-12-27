//
//  Orderings.swift
//  AlgebraicCheck
//
//  Created by TJ Usiyan on 2016/12/27.
//  Copyright © 2016 Buttons and Lights LLC. All rights reserved.
//


public struct PartialOrder<Relation : BinaryRelationProtocol> : BinaryOrderedStructure {
    public typealias OpType = Relation
    public let relation: Relation
    public let algebraicProperties: [RelationProperty<Relation>]

    public init(relation: Relation, equivalence: @escaping (Relation.Operand, Relation.Operand) -> Bool) {
        self.relation = relation
        self.algebraicProperties = [
            RelationProperty.antisymmetric(equivalence: equivalence),
            RelationProperty.transitive,
            RelationProperty.reflexive
        ]
    }
}

public struct TotalOrder<Relation : BinaryRelationProtocol> : BinaryOrderedStructure {
    public typealias OpType = Relation
    public let relation: Relation
    public let algebraicProperties: [RelationProperty<Relation>]

    public init(relation: Relation, equivalence: @escaping (Relation.Operand, Relation.Operand) -> Bool) {
        self.relation = relation
        self.algebraicProperties = [
            RelationProperty.antisymmetric(equivalence: equivalence),
            RelationProperty.transitive,
            RelationProperty.reflexive,
            RelationProperty.total
        ]
    }
}

