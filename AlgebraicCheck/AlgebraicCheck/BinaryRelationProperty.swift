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
    case leftEuclidian
    case rightEuclidian

    public var description: String {
        switch self {
        case .total:
            return "is total"
        case .antisymmetric:
            return "is antisymmetric"
        case .symmetric:
            return "is symmetric"
        case .asymmetric:
            return "is asymmetric"
        case .transitive:
            return "is transitive"
        case .reflexive:
            return "is reflexive"
        case .irreflexive:
            return "is irreflexive"
        case .leftEuclidian:
            return "is left euclidian"
        case .rightEuclidian:
            return "is right euclidian"
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
        case .leftEuclidian:
            return creatLeftEuclidianProperty(relation)
        case .rightEuclidian:
            return creatRightEuclidianProperty(relation)
        }
    }

    func createTotalProperty(_ relation: Relation) -> SwiftCheckProperties {
        let property = forAll { (a: Relation.Codomain, b: Relation.Codomain) in
            return relation.relates(a, b) || relation.relates(b, a)
        }

        return [("relation over \(Relation.Codomain.self) \(self)", property)]
    }


    func createAsymmetricProperty(_ relation: Relation) -> SwiftCheckProperties {
        let property = forAll { (a: Relation.Codomain, b: Relation.Codomain) in
            return relation.relates(a, b) ==> {
                false == relation.relates(b, a)
            }
        }

        return [("relation over \(Relation.Codomain.self) \(self)", property)]
    }

    func createSymmetricProperty(_ relation: Relation) -> SwiftCheckProperties {
        let property = forAll { (a: Relation.Codomain, b: Relation.Codomain) in
            relation.relates(a, b) == relation.relates(b, a)
        }
        return [("relation over \(Relation.Codomain.self) \(self)", property)]
    }


    func createAntisymmetricProperty(_ relation: Relation, equivalence: @escaping (Relation.Codomain, Relation.Codomain) -> Bool) -> SwiftCheckProperties {
        let property = forAll { (i: Relation.Codomain, j: Relation.Codomain) in
            if relation.relates(i, j) && relation.relates(j, i) {
                return equivalence(i, j)
            } else {
                return equivalence(i, j) == false
            }
        }
        return [("relation over \(Relation.Codomain.self) \(self)", property)]
    }

    func createTransitiveProperty(_ relation: Relation) -> SwiftCheckProperties {
        let property = forAll { (a: Relation.Codomain, b: Relation.Codomain, c: Relation.Codomain) -> Bool in
            if relation.relates(a, b) && relation.relates(b, c) {
                return relation.relates(a, c) == true
            } else {
                return true
            }
        }
        return [("relation over \(Relation.Codomain.self) \(self)", property)]
    }
    func createReflexiveProperty(_ relation: Relation) -> SwiftCheckProperties {
        let property = forAll { (a: Relation.Codomain) in
            relation.relates(a, a)
        }
        return [("relation over \(Relation.Codomain.self) \(self)", property)]
    }

    func createIrreflexiveProperty(_ relation: Relation) -> SwiftCheckProperties {
        let property = forAll { (a: Relation.Codomain) in
            false == relation.relates(a, a)
        }
        return [("relation over \(Relation.Codomain.self) \(self)", property)]
    }

    func creatLeftEuclidianProperty(_ relation: Relation) -> SwiftCheckProperties {
        let property = forAll { (x: Relation.Codomain, y: Relation.Codomain, z: Relation.Codomain) in
            if relation.relates(x, z) && relation.relates(y, z) {
                return relation.relates(x, y)
            } else {
                return true
            }
        }
        return [("relation over \(Relation.Codomain.self) \(self)", property)]
    }

    func creatRightEuclidianProperty(_ relation: Relation) -> SwiftCheckProperties {
        let property = forAll { (x: Relation.Codomain, y: Relation.Codomain, z: Relation.Codomain) in
            if relation.relates(x, z) && relation.relates(y, z) {
                return relation.relates(y, z)
            } else {
                return true
            }
        }
        return [("relation over \(Relation.Codomain.self) \(self)", property)]
    }
}
