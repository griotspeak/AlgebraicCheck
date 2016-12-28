//
//  StructureProperty.swift
//  Lattice
//
//  Created by TJ Usiyan on 2016/12/25.
//  Copyright © 2016 Buttons and Lights LLC. All rights reserved.
//

import SwiftCheck

public enum StructureProperty<Operation> : CustomStringConvertible
where Operation : ClosedBinary, Operation.Codomain : Arbitrary & Equatable {
    case totality
    case associativity
    case commutativity
    case identity(Operation.Codomain)
    case invertibility(identity: Operation.Codomain, InvertFunction<Operation.Codomain>)
    case latinSquare(((_ a: Operation.Codomain, _ b: Operation.Codomain) -> (x: Operation.Codomain, y: Operation.Codomain)))

    public var description: String {
        switch self {
        case .totality:
            return "totality"
        case .associativity:
            return "associativity"
        case .commutativity:
            return "commutativity"
        case .identity:
            return "identity"
        case .invertibility:
            return "invertibility"
        case .latinSquare:
            return "latin square"
        }
    }
}

extension StructureProperty where Operation : ClosedBinary {
    internal func concretize(with operation: Operation) -> SwiftCheckProperties {
        switch self {
        case .totality:
            return []
        case .associativity:
            return createAssociativityProperty(operation)
        case .commutativity:
            return createCommutativityProperty(operation)
        case let .identity(id):
            return createIdentityProperty(operation, identity: id)
        case let .invertibility(identity: id, fn):
            return createInverseProperty(operation, identity: id, inverseOp: fn)
        case let .latinSquare(fn):
            return createLatinSquareProperty(operation, latinSquare: fn)
        }
    }

    func createAssociativityProperty(_ operation: Operation) -> SwiftCheckProperties {
        let property = forAll { (i: Operation.Codomain, j: Operation.Codomain, k: Operation.Codomain) in
            operation.function(operation.function(i, j), k) == operation.function(i, operation.function(j, k))
        }
        return [("associative", property)]
    }

    func createCommutativityProperty(_ operation: Operation) -> SwiftCheckProperties {
        let property = forAll { (i: Operation.Codomain, j: Operation.Codomain) in
            operation.function(i, j) == operation.function(j, i)
        }
        return [("commutative", property)]
    }

    func createIdentityProperty(_ operation: Operation, identity: Operation.Codomain) -> SwiftCheckProperties {
        let property = forAll { (i: Operation.Codomain) in
            return operation.function(i, identity) == i && operation.function(identity, i) == i
        }
        return [("identity", property)]
    }

    func createInverseProperty(_ operation: Operation, identity: Operation.Codomain, inverseOp: @escaping (Operation.Codomain) -> Operation.Codomain) -> SwiftCheckProperties {
        let property = forAll { (a: Operation.Codomain) in
            let b = inverseOp(a)
            return (operation.function(a, b) == identity) && (operation.function(b, a) == identity)
        }
        return [("Invertible", property)]
    }

    func createLatinSquareProperty(_ operation: Operation, latinSquare: LatinSquareFunction<Operation.Codomain>) -> SwiftCheckProperties {
        let (a, b) = (Operation.Codomain.arbitrary.generate, Operation.Codomain.arbitrary.generate)
        let (x, y) = latinSquare(a, b)
        let propertyX = forAll { (j: Operation.Codomain) in
            if j == x {
                return operation.function(a, j) == b
            } else {
                return operation.function(a, j) != b
            }
        }

        let propertyY = forAll { (j: Operation.Codomain) in
            if j == y {
                return operation.function(j, a) == b
            } else {
                return operation.function(j, a) != b
            }
        }

        return  [
            ("Latin square property 'x' (a: \(a), b: \(b))", propertyX),
            ("Latin square property 'y' (a: \(a), b: \(b))", propertyY)
        ]
    }
}
