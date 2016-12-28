//
//  BinaryRelationProperty.swift
//  AlgebraicCheck
//
//  Created by TJ Usiyan on 2016/12/26.
//  Copyright © 2016 Buttons and Lights LLC. All rights reserved.
//

import SwiftCheck

public protocol OrderedStructure {
    associatedtype OpType : HomogenousRelationProtocol
    var relation: OpType { get }
    var algebraicProperties: [RelationProperty<OpType>] { get }
    var concretizedProperties: [(description: String, Property)] { get }
}

extension OrderedStructure where OpType.Codomain : Arbitrary {
    public var concretizedProperties: SwiftCheckProperties {
        return algebraicProperties.flatMap {
            return $0.concretize(with: relation)
        }
    }
}

public enum RelationProperty<Relation> : CustomStringConvertible
where Relation : BinaryRelationProtocol/*, Relation.Domain : Arbitrary*/ {
    case total
    case antisymmetric(equivalence: (Relation.Codomain, Relation.Codomain) -> Bool)
    case symmetric
    case asymmetric
    case transitive
    case reflexive
    case irreflexive

    public var description: String {
        switch self {
        case .total:
            return "total"
        case .antisymmetric:
            return "antisymmetric"
        case .symmetric:
            return "symmetric"
        case .asymmetric:
            return "asymmetric"
        case .transitive:
            return "transitive"
        case .reflexive:
            return "reflexive"
        case .irreflexive:
            return "irreflexive"
        }
    }
}

extension RelationProperty where Relation : HomogenousRelationProtocol, Relation.Codomain : Arbitrary {
    internal func concretize(with relation: Relation) -> SwiftCheckProperties {
        switch self {
        case .total:
            return createTotalProperty(relation)
        case let .antisymmetric(equivalance):
            return createAntisymmetricProperty(relation, equivalence: equivalance)
        case .symmetric:
            return createSymmetricProperty(relation)
        case .asymmetric:
            return createAsymmetricProperty(relation)
        case .transitive:
            return createTransitiveProperty(relation)
        case .reflexive:
            return createReflexiveProperty(relation)
        case .irreflexive:
            return createIrreflexiveProperty(relation)

        }
    }

    func createTotalProperty(_ relation: Relation) -> SwiftCheckProperties {
        let property = forAll { (a: Relation.Codomain, b: Relation.Codomain) in
            return relation.relates(a, b) || relation.relates(b, a)
        }
        return [("total", property)]
    }


    func createAsymmetricProperty(_ relation: Relation) -> SwiftCheckProperties {
        let property = forAll { (a: Relation.Codomain, b: Relation.Codomain) in
            return relation.relates(a, b) ==> {
                false == relation.relates(b, a)
            }
        }

        return [("asymmetric", property)]
    }

    func createSymmetricProperty(_ relation: Relation) -> SwiftCheckProperties {
        let property = forAll { (a: Relation.Codomain, b: Relation.Codomain) in
            relation.relates(a, b) == relation.relates(b, a)
        }
        return [("symmetric", property)]
    }


    func createAntisymmetricProperty(_ relation: Relation, equivalence: @escaping (Relation.Codomain, Relation.Codomain) -> Bool) -> SwiftCheckProperties {
        let property = forAll { (i: Relation.Codomain, j: Relation.Codomain) in
            if relation.relates(i, j) && relation.relates(j, i) {
                return equivalence(i, j)
            } else {
                return equivalence(i, j) == false
            }
        }
        return [("antisymmetric", property)]
    }

    func createTransitiveProperty(_ relation: Relation) -> SwiftCheckProperties {
        let property = forAll { (a: Relation.Codomain, b: Relation.Codomain, c: Relation.Codomain) -> Bool in
            if relation.relates(a, b) && relation.relates(b, c) {
                return relation.relates(a, c) == true
            } else {
                return true
            }
        }
        return [("transitive", property)]
    }
    func createReflexiveProperty(_ relation: Relation) -> SwiftCheckProperties {
        let property = forAll { (a: Relation.Codomain) in
            relation.relates(a, a)
        }
        return [("reflexive", property)]
    }

    func createIrreflexiveProperty(_ relation: Relation) -> SwiftCheckProperties {
        let property = forAll { (a: Relation.Codomain) in
            false == relation.relates(a, a)
        }
        return [("irreflexive", property)]
    }
}
