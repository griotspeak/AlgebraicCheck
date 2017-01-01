//
//  StructureProperty.swift
//  Lattice
//
//  Created by TJ Usiyan on 2016/12/25.
//  Copyright © 2016 Buttons and Lights LLC. All rights reserved.
//

import SwiftCheck

public typealias RelationFunction<Element> = (Element, Element) -> Bool

public enum StructureProperty<Operation> : CustomStringConvertible
where Operation : ClosedBinary, Operation.Codomain : Arbitrary {
    case totality
    case associativity
    case commutativity
    case noncommutative(commutativityCounterExample: (Operation.Codomain, Operation.Codomain))
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
        case .noncommutative:
            return "is not commutative"
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
    internal func concretize(with operation: Operation, equivalence: @escaping RelationFunction<Operation.Codomain>) -> SwiftCheckProperties {
        switch self {
        case .totality:
            return createTotalProperty(operation)
        case .associativity:
            return createAssociativityProperty(operation, equivalence: equivalence)
        case .commutativity:
            return createCommutativityProperty(operation, equivalence: equivalence)
        case let .noncommutative(example):
            return createNoncommutativeProperty(operation, example: example, equivalence: equivalence)
        case let .idempotence(element):
            return createIdempotenceProperty(operation, element: element, equivalence: equivalence)
        case let .leftIdentity(element):
            return createLeftIdentityProperty(operation, leftIdentity: element, equivalence: equivalence)
        case let .rightIdentity(element):
            return createRightIdentityProperty(operation, rightIdentity: element, equivalence: equivalence)
        case let .identity(id):
            return createIdentityProperty(operation, identity: id, equivalence: equivalence)
        case let .invertibility(identity: id, fn):
            return createInverseProperty(operation, identity: id, inverseOp: fn, equivalence: equivalence)
        case let .latinSquare(fn):
            return createLatinSquareProperty(operation, latinSquare: fn, equivalence: equivalence)
        case let .leftAbsorbingElement(value):
            return createLeftAbsorbingElementProperty(operation, leftAbsorbingElement: value, equivalence: equivalence)
        case let .rightAbsorbingElement(value):
            return createRightAbsorbingElementProperty(operation, rightAbsorbingElement: value, equivalence: equivalence)
        case let .absorbingElement(value):
            return createAbsorbingElementProperty(operation, absorbingElement: value, equivalence: equivalence)
        case let .distributive(additionName, addition):
            return createDistributiveProperty(operation, over: additionName, otherOperation: addition, equivalence: equivalence)
        }
    }

    func createTotalProperty(_ operation: Operation) -> SwiftCheckProperties {
        let property = forAll { (i: Operation.Codomain, j: Operation.Codomain) in
            _ = operation.function(i, j)
            return true
        }
        return [("operation over \(Operation.Codomain.self) \(self)", property)]
    }

    func createAssociativityProperty(_ operation: Operation, equivalence: @escaping RelationFunction<Operation.Codomain>) -> SwiftCheckProperties {
        let property = forAll { (i: Operation.Codomain, j: Operation.Codomain, k: Operation.Codomain) in
            let lhs = operation.function(operation.function(i, j), k)
            let rhs = operation.function(i, operation.function(j, k))
            return equivalence(lhs, rhs)

        }
        return [("operation over \(Operation.Codomain.self) \(self)", property)]
    }

    func createNoncommutativeProperty(_ operation: Operation, example: (Operation.Codomain, Operation.Codomain), equivalence: @escaping RelationFunction<Operation.Codomain>) -> SwiftCheckProperties {
        let property = forAll { (_: Int) in
            let lhs = operation.function(example.0, example.1)
            let rhs = operation.function(example.1, example.0)
            return false == equivalence(lhs, rhs)
        }
        return [("operation over \(Operation.Codomain.self) \(self)", property)]
    }

    func createCommutativityProperty(_ operation: Operation, equivalence: @escaping RelationFunction<Operation.Codomain>) -> SwiftCheckProperties {
        let property = forAll { (i: Operation.Codomain, j: Operation.Codomain) in
            let lhs = operation.function(i, j)
            let rhs = operation.function(j, i)
            return equivalence(lhs, rhs)
        }
        return [("operation over \(Operation.Codomain.self) \(self)", property)]
    }

    func createIdempotenceProperty(_ operation: Operation, element: Operation.Codomain, equivalence: @escaping RelationFunction<Operation.Codomain>) -> SwiftCheckProperties {
        let property = forAll { (count: Int) in
            return Array(repeating: element, count: abs(count) % 125).reduce(true) {
                $0 && equivalence(operation.function(element, $1), element)
            }
        }
        return [("operation over \(Operation.Codomain.self) \(self): \(element)", property)]
    }

    func createLeftIdentityProperty(_ operation: Operation, leftIdentity: Operation.Codomain, equivalence: @escaping RelationFunction<Operation.Codomain>) -> SwiftCheckProperties {
        let property = forAll { (x: Operation.Codomain) in
            return equivalence(operation.function(leftIdentity, x), x)
        }
        return [("operation over \(Operation.Codomain.self) \(self): \(leftIdentity)", property)]
    }

    func createRightIdentityProperty(_ operation: Operation, rightIdentity: Operation.Codomain, equivalence: @escaping RelationFunction<Operation.Codomain>) -> SwiftCheckProperties {
        let property = forAll { (x: Operation.Codomain) in
            return equivalence(operation.function(x, rightIdentity), x)
        }
        return [("operation over \(Operation.Codomain.self) \(self): \(rightIdentity)", property)]
    }

    func createIdentityProperty(_ operation: Operation, identity: Operation.Codomain, equivalence: @escaping RelationFunction<Operation.Codomain>) -> SwiftCheckProperties {
        let property = forAll { (x: Operation.Codomain) in

            return equivalence(operation.function(x, identity), x) && equivalence(operation.function(identity, x), x)
        }
        return [("operation over \(Operation.Codomain.self) \(self): \(identity)", property)]
    }

    func createInverseProperty(_ operation: Operation, identity: Operation.Codomain, inverseOp: @escaping (Operation.Codomain) -> Operation.Codomain, equivalence: @escaping RelationFunction<Operation.Codomain>) -> SwiftCheckProperties {
        let property = forAll { (a: Operation.Codomain) in
            let b = inverseOp(a)
            let leftProposition = equivalence(operation.function(a, b), identity)
            let rightProposition = equivalence(operation.function(b, a), identity)
            return leftProposition && rightProposition
        }
        return [("operation over \(Operation.Codomain.self) \(self): \(identity)", property)]
    }

    func createLatinSquareProperty(_ operation: Operation, latinSquare: LatinSquareFunction<Operation.Codomain>, equivalence: @escaping RelationFunction<Operation.Codomain>) -> SwiftCheckProperties {
        let (a, b) = (Operation.Codomain.arbitrary.generate, Operation.Codomain.arbitrary.generate)
        let (x, y) = latinSquare(a, b)
        let propertyX = forAll { (j: Operation.Codomain) in
            if equivalence(j, x) {
                return equivalence(operation.function(a, j), b)
            } else {
                return false == equivalence(operation.function(a, j), b)
            }
        }

        let propertyY = forAll { (j: Operation.Codomain) in
            if equivalence(j, y) {
                return equivalence(operation.function(j, a), b)
            } else {
                return false == equivalence(operation.function(j, a), b)
            }
        }

        return  [
            ("operation over \(Operation.Codomain.self) \(self) ('left') (a: \(a), b: \(b))", propertyX),
            ("operation over \(Operation.Codomain.self) \(self) ('right') 'y' (a: \(a), b: \(b))", propertyY)
        ]
    }


    func createLeftAbsorbingElementProperty(_ operation: Operation, leftAbsorbingElement: Operation.Codomain, equivalence: @escaping RelationFunction<Operation.Codomain>) -> SwiftCheckProperties {
        let property = forAll { (x: Operation.Codomain) in
            return equivalence(operation.function(leftAbsorbingElement, x), leftAbsorbingElement)
        }
        return [("operation over \(Operation.Codomain.self) \(self): \(leftAbsorbingElement)", property)]
    }

    func createRightAbsorbingElementProperty(_ operation: Operation, rightAbsorbingElement: Operation.Codomain, equivalence: @escaping RelationFunction<Operation.Codomain>) -> SwiftCheckProperties {
        let property = forAll { (x: Operation.Codomain) in
            return equivalence(operation.function(x, rightAbsorbingElement), rightAbsorbingElement)
        }
        return [("operation over \(Operation.Codomain.self) \(self): \(rightAbsorbingElement)", property)]
    }

    func createAbsorbingElementProperty(_ operation: Operation, absorbingElement: Operation.Codomain, equivalence: @escaping RelationFunction<Operation.Codomain>) -> SwiftCheckProperties {
        let property = forAll { (x: Operation.Codomain) in
            let leftProposition = equivalence(operation.function(x, absorbingElement), absorbingElement)
            let rightProposition = equivalence(operation.function(absorbingElement, x), absorbingElement)
            return leftProposition && rightProposition
        }
        return [("operation over \(Operation.Codomain.self) \(self): \(absorbingElement)", property)]
    }

    func createDistributiveProperty(_ operation: Operation, over additionDescription: String, otherOperation addition: @escaping (Operation.Codomain, Operation.Codomain) -> Operation.Codomain, equivalence: @escaping RelationFunction<Operation.Codomain>) -> SwiftCheckProperties {
        let property = forAll { (x: Operation.Codomain, y: Operation.Codomain, z: Operation.Codomain) in
            let lhs = operation.function(x, addition(y, z)) // x(y + z)
            let rhs = addition(operation.function(x, y), operation.function(x, z)) // xy + xz
            return equivalence(lhs, rhs)
        }
        return [("operation over \(Operation.Codomain.self) \(self) over \(additionDescription)", property)]
    }
}
