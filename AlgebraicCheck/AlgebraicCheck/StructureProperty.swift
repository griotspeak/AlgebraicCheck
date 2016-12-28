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

    public var description: String {
        switch self {
        case .totality:
            return "totality"
        case .associativity:
            return "associativity"
        case .commutativity:
            return "commutativity"
        case .idempotence:
            return "idempotence"
        case .leftIdentity:
            return "left identity"
        case .rightIdentity:
            return "right identity"
        case .identity:
            return "identity"
        case .invertibility:
            return "invertibility"
        case .latinSquare:
            return "latin square"
        case .leftAbsorbingElement:
            return "left zero"
        case .rightAbsorbingElement:
            return "right absorbing element"
        case .absorbingElement:
            return "absorbing element"
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
        }
    }

    func createAssociativityProperty(_ operation: Operation) -> SwiftCheckProperties {
        let property = forAll { (i: Operation.Codomain, j: Operation.Codomain, k: Operation.Codomain) in
            operation.function(operation.function(i, j), k) == operation.function(i, operation.function(j, k))
        }
        return [("operation over \(Operation.Codomain.self) is associative", property)]
    }

    func createCommutativityProperty(_ operation: Operation) -> SwiftCheckProperties {
        let property = forAll { (i: Operation.Codomain, j: Operation.Codomain) in
            operation.function(i, j) == operation.function(j, i)
        }
        return [("operation over \(Operation.Codomain.self) is commutative", property)]
    }

    func createIdempotenceProperty(_ operation: Operation, element: Operation.Codomain) -> SwiftCheckProperties {
        let property = forAll { (count: Int) in
            return Array(repeating: element, count: abs(count) % 125).reduce(true) {
                $0 && (operation.function(element, $1) == element)
            }
        }
        return [("operation over \(Operation.Codomain.self) is idempotent", property)]
    }

    func createLeftIdentityProperty(_ operation: Operation, leftIdentity: Operation.Codomain) -> SwiftCheckProperties {
        let property = forAll { (x: Operation.Codomain) in
            return operation.function(leftIdentity, x) == x
        }
        return [("operation over \(Operation.Codomain.self) has left identity element \(leftIdentity)", property)]
    }

    func createRightIdentityProperty(_ operation: Operation, rightIdentity: Operation.Codomain) -> SwiftCheckProperties {
        let property = forAll { (x: Operation.Codomain) in
            return operation.function(x, rightIdentity) == x
        }
        return [("operation over \(Operation.Codomain.self) has right identity element \(rightIdentity)", property)]
    }

    func createIdentityProperty(_ operation: Operation, identity: Operation.Codomain) -> SwiftCheckProperties {
        let property = forAll { (x: Operation.Codomain) in
            return operation.function(x, identity) == x && operation.function(identity, x) == x
        }
        return [("operation over \(Operation.Codomain.self) has identity element \(identity)", property)]
    }

    func createInverseProperty(_ operation: Operation, identity: Operation.Codomain, inverseOp: @escaping (Operation.Codomain) -> Operation.Codomain) -> SwiftCheckProperties {
        let property = forAll { (a: Operation.Codomain) in
            let b = inverseOp(a)
            return (operation.function(a, b) == identity) && (operation.function(b, a) == identity)
        }
        return [("operation over \(Operation.Codomain.self) has an inverse \(identity)", property)]
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
            ("operation over \(Operation.Codomain.self) latin square property ('left') (a: \(a), b: \(b))", propertyX),
            ("operation over \(Operation.Codomain.self) latin square property ('right') 'y' (a: \(a), b: \(b))", propertyY)
        ]
    }


    func createLeftAbsorbingElementProperty(_ operation: Operation, leftAbsorbingElement: Operation.Codomain) -> SwiftCheckProperties {
        let property = forAll { (x: Operation.Codomain) in
            return operation.function(leftAbsorbingElement, x) == leftAbsorbingElement
        }
        return [("operation over \(Operation.Codomain.self) has left absorbing element \(leftAbsorbingElement)", property)]
    }

    func createRightAbsorbingElementProperty(_ operation: Operation, rightAbsorbingElement: Operation.Codomain) -> SwiftCheckProperties {
        let property = forAll { (x: Operation.Codomain) in
            return operation.function(x, rightAbsorbingElement) == rightAbsorbingElement
        }
        return [("operation over \(Operation.Codomain.self) has right absorbing element \(rightAbsorbingElement)", property)]
    }

    func createAbsorbingElementProperty(_ operation: Operation, absorbingElement: Operation.Codomain) -> SwiftCheckProperties {
        let property = forAll { (x: Operation.Codomain) in
            return operation.function(x, absorbingElement) == x && operation.function(absorbingElement, x) == absorbingElement
        }
        return [("operation over \(Operation.Codomain.self) has an absorbing element \(absorbingElement)", property)]
    }
}
