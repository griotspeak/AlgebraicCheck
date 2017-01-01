//
//  Orderings.swift
//  AlgebraicCheck
//
//  Created by TJ Usiyan on 2016/12/27.
//  Copyright © 2016 Buttons and Lights LLC. All rights reserved.
//

import SwiftCheck

public typealias SwiftCheckProperties = [(description: String, Property)]

// MARK: -

public protocol BinaryRelationProtocol {
    associatedtype Domain
    associatedtype Codomain
    var relates: (Domain, Codomain) -> Bool { get }
}

public protocol HomogenousRelationProtocol : BinaryRelationProtocol {
    associatedtype Codomain
    var relates: (Codomain, Codomain) -> Bool { get }
}

public struct HomogenousRelation<UnderlyingSet : Arbitrary> : HomogenousRelationProtocol {
    public typealias Domain = UnderlyingSet
    public typealias Codomain = UnderlyingSet
    public let relates: (UnderlyingSet, UnderlyingSet) -> Bool
    public init(_ relates: @escaping (UnderlyingSet, UnderlyingSet) -> Bool) {
        self.relates = relates
    }
}

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

extension Arbitrary where Self : Equatable {

    public static func form(operation: @escaping (Self, Self) -> Self, algebraicProperties: [StructureProperty<ClosedBinaryOperation<Self>>]) -> GenericStructure<ClosedBinaryOperation<Self>> {

        return GenericStructure(operation: ClosedBinaryOperation<Self>(operation), algebraicProperties: algebraicProperties)
    }
}

public struct Equivalence<Relation : HomogenousRelationProtocol> : OrderedStructure where Relation.Codomain : Arbitrary {
    public typealias OpType = Relation
    public let relation: Relation
    public let algebraicProperties: [RelationProperty<Relation>]

    public init(relation: Relation, equivalence: @escaping (Relation.Codomain, Relation.Codomain) -> Bool) {
        self.relation = relation
        self.algebraicProperties = [
            RelationProperty.symmetric,
            RelationProperty.transitive,
            RelationProperty.reflexive
        ]
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
