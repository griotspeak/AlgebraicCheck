//
//  AlgebraicProperty.swift
//  Lattice
//
//  Created by TJ Usiyan on 2016/12/25.
//  Copyright © 2016 Buttons and Lights LLC. All rights reserved.
//

import SwiftCheck

public enum AlgebraicProperty<Operation> : CustomStringConvertible
where Operation.Operand : Arbitrary & Equatable, Operation : Transform {
    case totality
    case associativity
    case commutativity
    case identity(Operation.Operand)
    case invertibility(identity: Operation.Operand, InvertFunction<Operation.Operand>)
    case latinSquare(((_ a: Operation.Operand, _ b: Operation.Operand) -> (x: Operation.Operand, y: Operation.Operand)))

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

extension AlgebraicProperty where Operation : ClosedBinary {
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

    func createAssociativityProperty(_ op: Operation) -> SwiftCheckProperties {
            let property = forAll { (i: Operation.Operand, j: Operation.Operand) in
                op.function(i, j) == op.function(j, i)
            }
            return [("associative", property)]
    }

    func createCommutativityProperty(_ op: Operation) -> SwiftCheckProperties {
            let property = forAll { (i: Operation.Operand, j: Operation.Operand) in
                op.function(i, j) == op.function(j, i)
            }
            return [("commutative", property)]
    }

    func createIdentityProperty(_ op: Operation, identity: Operation.Operand) -> SwiftCheckProperties {
            let property = forAll { (i: Operation.Operand) in
                return op.function(i, identity) == i && op.function(identity, i) == i
            }
            return [("identity", property)]
    }

    func createInverseProperty(_ op: Operation, identity: Operation.Operand, inverseOp: @escaping (Operation.Operand) -> Operation.Operand) -> SwiftCheckProperties {
            let property = forAll { (a: Operation.Operand) in
                let b = inverseOp(a)
                return (op.function(a, b) == identity) && (op.function(b, a) == identity)
            }
            return [("Invertible", property)]
    }

    func createLatinSquareProperty(_ op: Operation, latinSquare: LatinSquareFunction<Operation.Operand>) -> SwiftCheckProperties {
            let (a, b) = (Operation.Operand.arbitrary.generate, Operation.Operand.arbitrary.generate)
            let (x, y) = latinSquare(a, b)
            let propertyX = forAll { (j: Operation.Operand) in
                if j == x {
                    return op.function(a, j) == b
                } else {
                    return op.function(a, j) != b
                }
            }

            let propertyY = forAll { (j: Operation.Operand) in
                if j == y {
                    return op.function(j, a) == b
                } else {
                    return op.function(j, a) != b
                }
            }

            return  [
                ("Latin square property 'x' (a: \(a), b: \(b))", propertyX),
                ("Latin square property 'y' (a: \(a), b: \(b))", propertyY)
            ]
    }
}
