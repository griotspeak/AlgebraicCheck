//
//  BinaryRelationProperty.swift
//  AlgebraicCheck
//
//  Created by TJ Usiyan on 2016/12/26.
//  Copyright © 2016 Buttons and Lights LLC. All rights reserved.
//

import SwiftCheck

public protocol OrderedStructure {
    associatedtype OpType : ClosedBinaryRelationProtocol
    var relation: OpType { get }
    var algebraicProperties: [RelationProperty<OpType>] { get }
    var concretizedProperties: [(description: String, Property)] { get }
}

public protocol BinaryOrderedStructure : OrderedStructure {
    associatedtype OpType : ClosedBinaryRelationProtocol
}

extension BinaryOrderedStructure where OpType.Codomain : Arbitrary {
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
    case transitive
    case reflexive

    public var description: String {
        switch self {
        case .total:
            return "total"
        case .antisymmetric:
            return "antisemmetric"
        case .transitive:
            return "transitive"
        case .reflexive:
            return "reflexive"
        }
    }
}

extension RelationProperty where Relation : ClosedBinaryRelationProtocol, Relation.Codomain : Arbitrary {
    internal func concretize(with operation: Relation) -> SwiftCheckProperties {
        switch self {
        case .total:
            return createTotalProperty(operation)
        case let .antisymmetric(eq):
            return createAntisymmetricProperty(operation, equivalence: eq)
        case .transitive:
            return createTransitiveProperty(operation)
        case .reflexive:
            return createReflexiveProperty(operation)
        }
    }

    func createTotalProperty(_ op: Relation) -> SwiftCheckProperties {
        let property = forAll { (a: Relation.Codomain, b: Relation.Codomain) in
            return op.isRRelated(a, b) || op.isRRelated(b, a)
        }
        return [("total", property)]
    }

    func createAntisymmetricProperty(_ op: Relation, equivalence: @escaping (Relation.Codomain, Relation.Codomain) -> Bool) -> SwiftCheckProperties {
        let property = forAll { (i: Relation.Codomain, j: Relation.Codomain) in
            if op.isRRelated(i, j) && op.isRRelated(j, i) {
                return equivalence(i, j)
            } else {
                return equivalence(i, j) == false
            }
        }
        return [("antisymmetric", property)]
    }

    func createTransitiveProperty(_ op: Relation) -> SwiftCheckProperties {
        let property = forAll { (a: Relation.Codomain, b: Relation.Codomain, c: Relation.Codomain) -> Bool in
            if op.isRRelated(a, b) && op.isRRelated(b, c) {
                return op.isRRelated(a, c) == true
            } else {
                return true
            }
        }
        return [("transitive", property)]
    }
    func createReflexiveProperty(_ op: Relation) -> SwiftCheckProperties {
        let property = forAll { (a: Relation.Codomain) in
            op.isRRelated(a, a)
        }
        return [("reflexive", property)]
    }
}
