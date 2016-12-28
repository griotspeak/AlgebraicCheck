//
//  Orderings.swift
//  AlgebraicCheck
//
//  Created by TJ Usiyan on 2016/12/27.
//  Copyright © 2016 Buttons and Lights LLC. All rights reserved.
//

import SwiftCheck

public struct GenericOrderedStructure<Relation : HomogenousRelationProtocol> : OrderedStructure
where Relation.Codomain : Arbitrary {

    public let relation: Relation
    public let algebraicProperties: [RelationProperty<Relation>]

    public init(relation: Relation, algebraicProperties: [RelationProperty<Relation>]) {
        self.relation = relation
        self.algebraicProperties = algebraicProperties
    }
}

extension Arbitrary {
    public static func form(relation: @escaping (Self, Self) -> Bool, algebraicProperties: [RelationProperty<HomogenousRelation<Self>>]) -> GenericOrderedStructure<HomogenousRelation<Self>> {

        return GenericOrderedStructure(relation: HomogenousRelation<Self>(relation), algebraicProperties: algebraicProperties)
    }
}

public struct PartialOrder<Relation : HomogenousRelationProtocol> : OrderedStructure where Relation.Codomain : Arbitrary {
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

public struct TotalOrder<Relation : HomogenousRelationProtocol> : OrderedStructure where Relation.Codomain : Arbitrary {
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
