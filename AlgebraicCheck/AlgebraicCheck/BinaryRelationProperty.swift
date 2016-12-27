//
//  BinaryRelationProperty.swift
//  AlgebraicCheck
//
//  Created by TJ Usiyan on 2016/12/26.
//  Copyright © 2016 Buttons and Lights LLC. All rights reserved.
//

import SwiftCheck

public protocol OrderedStructure {
    associatedtype OpType : RelationProtocol
    var relation: OpType { get }
    var algebraicProperties: [RelationProperty<OpType>] { get }
    var concretizedProperties: [(description: String, Property)] { get }
}

public protocol BinaryOrderedStructure : OrderedStructure {
    associatedtype OpType : BinaryRelationProtocol
}

extension BinaryOrderedStructure {
    public var concretizedProperties: SwiftCheckProperties {
        return algebraicProperties.flatMap {
            $0.concretize(with: relation)
        }
    }
}

public enum RelationProperty<Relation> : CustomStringConvertible
where Relation : RelationProtocol, Relation.Operand : Arbitrary {
    case total
    case antisymmetric(equivalence: (Relation.Operand, Relation.Operand) -> Bool)
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

extension RelationProperty where Relation : BinaryRelationProtocol {
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
        let property = forAll { (a: Relation.Operand, b: Relation.Operand) in
            return op.function(a, b) || op.function(b, a)
        }
        return [("total", property)]
    }

    func createAntisymmetricProperty(_ op: Relation, equivalence: @escaping (Relation.Operand, Relation.Operand) -> Bool) -> SwiftCheckProperties {
        let property = forAll { (i: Relation.Operand, j: Relation.Operand) in
            if op.function(i, j) && op.function(j, i) {
                return equivalence(i, j)
            } else {
                return equivalence(i, j) == false
            }
        }
        return [("antisymmetric", property)]
    }

    func createTransitiveProperty(_ op: Relation) -> SwiftCheckProperties {
        let property = forAll { (a: Relation.Operand, b: Relation.Operand, c: Relation.Operand) in
            if op.function(a, b) && op.function(b, c) {
                return op.function(a, c) == true
            } else {
                return true
            }
        }
        return [("transitive", property)]
    }
    func createReflexiveProperty(_ op: Relation) -> SwiftCheckProperties {
        let property = forAll { (a: Relation.Operand) in
            op.function(a, a)
        }
        return [("reflexive", property)]
    }
}
