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
    case idempotence(Operation.Codomain)
    case leftIdentity(Operation.Codomain)
    case rightIdentity(Operation.Codomain)
    case identity(Operation.Codomain)
    case invertibility(identity: Operation.Codomain, InvertFunction<Operation.Codomain>)
    case latinSquare(((_ a: Operation.Codomain, _ b: Operation.Codomain) -> (x: Operation.Codomain, y: Operation.Codomain)))
    case leftAbsorbingElement(Operation.Codomain)
    case rightAbsorbingElement(Operation.Codomain)
    case absorbingElement(Operation.Codomain)
    case distributive(over: String, addition: (Operation.Codomain, Operation.Codomain) -> Operation.Codomain)

    public var description: String {
        switch self {
        case .totality:
            return "is total"
        case .associativity:
            return "is associative"
        case .commutativity:
            return "is commutative"
        case .idempotence:
            return "has idempotent element"
        case .leftIdentity:
            return "has left identity element"
        case .rightIdentity:
            return "has right identity element"
        case .identity:
            return "has identity element"
        case .invertibility:
            return "has an inverse"
        case .latinSquare:
            return "has latin square"
        case .leftAbsorbingElement:
            return "has left absorbing element"
        case .rightAbsorbingElement:
            return "has right absorbing element"
        case .absorbingElement:
            return "has absorbing element"
        case .distributive:
            return "is distributive"
        }
    }
}

extension StructureProperty where Operation : ClosedBinary {
    internal func concretize(with operation: Operation) -> SwiftCheckProperties {
        switch self {
        case .totality:
            return createTotalProperty(operation)
        case .associativity:
            return createAssociativityProperty(operation)
        case .commutativity:
            return createCommutativityProperty(operation)
        case let .idempotence(element):
            return createIdempotenceProperty(operation, element: element)
        case let .leftIdentity(element):
            return createLeftIdentityProperty(operation, leftIdentity: element)
        case let .rightIdentity(element):
            return createRightIdentityProperty(operation, rightIdentity: element)
        case let .identity(id):
            return createIdentityProperty(operation, identity: id)
        case let .invertibility(identity: id, fn):
            return createInverseProperty(operation, identity: id, inverseOp: fn)
        case let .latinSquare(fn):
            return createLatinSquareProperty(operation, latinSquare: fn)
        case let .leftAbsorbingElement(value):
            return createLeftAbsorbingElementProperty(operation, leftAbsorbingElement: value)
        case let .rightAbsorbingElement(value):
            return createRightAbsorbingElementProperty(operation, rightAbsorbingElement: value)
        case let .absorbingElement(value):
            return createAbsorbingElementProperty(operation, absorbingElement: value)
        case let .distributive(additionName, addition):
            return createDistributiveProperty(operation, over: additionName, otherOperation: addition)
        }
    }

    func createTotalProperty(_ operation: Operation) -> SwiftCheckProperties {
        let property = forAll { (i: Operation.Codomain, j: Operation.Codomain) in
            _ = operation.function(i, j)
            return true
        }
        return [("operation over \(Operation.Codomain.self) \(self)", property)]
    }

    func createAssociativityProperty(_ operation: Operation) -> SwiftCheckProperties {
        let property = forAll { (i: Operation.Codomain, j: Operation.Codomain, k: Operation.Codomain) in
            operation.function(operation.function(i, j), k) == operation.function(i, operation.function(j, k))
        }
        return [("operation over \(Operation.Codomain.self) \(self)", property)]
    }

    func createCommutativityProperty(_ operation: Operation) -> SwiftCheckProperties {
        let property = forAll { (i: Operation.Codomain, j: Operation.Codomain) in
            operation.function(i, j) == operation.function(j, i)
        }
        return [("operation over \(Operation.Codomain.self) \(self)", property)]
    }

    func createIdempotenceProperty(_ operation: Operation, element: Operation.Codomain) -> SwiftCheckProperties {
        let property = forAll { (count: Int) in
            return Array(repeating: element, count: abs(count) % 125).reduce(true) {
                $0 && (operation.function(element, $1) == element)
            }
        }
        return [("operation over \(Operation.Codomain.self) \(self): \(element)", property)]
    }

    func createLeftIdentityProperty(_ operation: Operation, leftIdentity: Operation.Codomain) -> SwiftCheckProperties {
        let property = forAll { (x: Operation.Codomain) in
            return operation.function(leftIdentity, x) == x
        }
        return [("operation over \(Operation.Codomain.self) \(self): \(leftIdentity)", property)]
    }

    func createRightIdentityProperty(_ operation: Operation, rightIdentity: Operation.Codomain) -> SwiftCheckProperties {
        let property = forAll { (x: Operation.Codomain) in
            return operation.function(x, rightIdentity) == x
        }
        return [("operation over \(Operation.Codomain.self) \(self): \(rightIdentity)", property)]
    }

    func createIdentityProperty(_ operation: Operation, identity: Operation.Codomain) -> SwiftCheckProperties {
        let property = forAll { (x: Operation.Codomain) in
            return operation.function(x, identity) == x && operation.function(identity, x) == x
        }
        return [("operation over \(Operation.Codomain.self) \(self): \(identity)", property)]
    }

    func createInverseProperty(_ operation: Operation, identity: Operation.Codomain, inverseOp: @escaping (Operation.Codomain) -> Operation.Codomain) -> SwiftCheckProperties {
        let property = forAll { (a: Operation.Codomain) in
            let b = inverseOp(a)
            return (operation.function(a, b) == identity) && (operation.function(b, a) == identity)
        }
        return [("operation over \(Operation.Codomain.self) \(self): \(identity)", property)]
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
            ("operation over \(Operation.Codomain.self) \(self) ('left') (a: \(a), b: \(b))", propertyX),
            ("operation over \(Operation.Codomain.self) \(self) ('right') 'y' (a: \(a), b: \(b))", propertyY)
        ]
    }


    func createLeftAbsorbingElementProperty(_ operation: Operation, leftAbsorbingElement: Operation.Codomain) -> SwiftCheckProperties {
        let property = forAll { (x: Operation.Codomain) in
            return operation.function(leftAbsorbingElement, x) == leftAbsorbingElement
        }
        return [("operation over \(Operation.Codomain.self) \(self): \(leftAbsorbingElement)", property)]
    }

    func createRightAbsorbingElementProperty(_ operation: Operation, rightAbsorbingElement: Operation.Codomain) -> SwiftCheckProperties {
        let property = forAll { (x: Operation.Codomain) in
            return operation.function(x, rightAbsorbingElement) == rightAbsorbingElement
        }
        return [("operation over \(Operation.Codomain.self) \(self): \(rightAbsorbingElement)", property)]
    }

    func createAbsorbingElementProperty(_ operation: Operation, absorbingElement: Operation.Codomain) -> SwiftCheckProperties {
        let property = forAll { (x: Operation.Codomain) in
            return operation.function(x, absorbingElement) == absorbingElement && operation.function(absorbingElement, x) == absorbingElement
        }
        return [("operation over \(Operation.Codomain.self) \(self): \(absorbingElement)", property)]
    }

    func createDistributiveProperty(_ operation: Operation, over additionDescription: String, otherOperation addition: @escaping (Operation.Codomain, Operation.Codomain) -> Operation.Codomain) -> SwiftCheckProperties {
        let property = forAll { (x: Operation.Codomain, y: Operation.Codomain, z: Operation.Codomain) in
            let lhs = operation.function(x, addition(y, z)) // x(y + z)
            let rhs = addition(operation.function(x, y), operation.function(x, z)) // xy + xz
            return lhs == rhs
        }
        return [("operation over \(Operation.Codomain.self) \(self) over \(additionDescription)", property)]
    }
}
