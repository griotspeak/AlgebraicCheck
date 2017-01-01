//
//  Magma.swift
//  AlgebraicCheck
//
//  Created by TJ Usiyan on 2016/12/28.
//  Copyright © 2016 Buttons and Lights LLC. All rights reserved.
//

import SwiftCheck

public protocol ClosedBinary {
    associatedtype Codomain : Arbitrary
    var function: (Codomain, Codomain) -> Codomain { get }
}

public struct ClosedBinaryOperation<UnderlyingSet : Arbitrary> : ClosedBinary {
    public typealias Codomain = UnderlyingSet

    public let function: (UnderlyingSet, UnderlyingSet) -> UnderlyingSet

    public init(_ function: @escaping (UnderlyingSet, UnderlyingSet) -> UnderlyingSet) {
        self.function = function
    }
}

public protocol MagmaProtocol : CheckableStructure {
    associatedtype OpType : ClosedBinary
    typealias UnderlyingSet = OpType.Codomain

    var operation: OpType { get }
    var algebraicProperties: [StructureProperty<OpType>] { get }
    var equivalence: RelationFunction<UnderlyingSet> { get }
}

extension MagmaProtocol {
    public var concretizedProperties: [(description: String, Property)] {
        return algebraicProperties.flatMap {
            $0.concretize(with: operation, equivalence: equivalence)
        }
    }
}

public typealias LatinSquareFunction<UnderlyingSet> = ((_ a: UnderlyingSet, _ b: UnderlyingSet) -> (left: UnderlyingSet, right: UnderlyingSet))
public typealias InvertFunction<UnderlyingSet> = ((UnderlyingSet) -> UnderlyingSet)

// MARK: Magma
public struct Magma<Operation : ClosedBinary> : MagmaProtocol {
    public typealias OpType = Operation
    public let operation: Operation
    public let algebraicProperties: [StructureProperty<Operation>]
    public let equivalence: RelationFunction<Operation.Codomain>

    public init(operation: Operation, equivalence: @escaping RelationFunction<Operation.Codomain>) {
        self.operation = operation
        self.algebraicProperties = [.totality]
        self.equivalence = equivalence
    }
}

extension Magma where Operation.Codomain : Equatable {
    public init(operation: Operation) {
        self.init(operation: operation, equivalence: (==))
    }
}


// MARK: Semigroup
public struct Semigroup<Operation : ClosedBinary> : MagmaProtocol {
    public typealias OpType = Operation
    public let operation: Operation
    public let algebraicProperties: [StructureProperty<Operation>]
    public let equivalence: RelationFunction<Operation.Codomain>

    public init(operation: Operation, equivalence: @escaping RelationFunction<Operation.Codomain>) {
        self.operation = operation
        self.algebraicProperties = [.totality, .associativity]
        self.equivalence = equivalence
    }
}

extension Semigroup where Operation.Codomain : Equatable {
    public init(operation: Operation) {
        self.init(operation: operation, equivalence: (==))
    }
}

// MARK: Monoid
public struct Monoid<Operation : ClosedBinary> : MagmaProtocol {
    public typealias OpType = Operation
    public let operation: Operation
    public let algebraicProperties: [StructureProperty<Operation>]
    public let equivalence: RelationFunction<Operation.Codomain>

    public init(operation: Operation, identity: Operation.Codomain, equivalence: @escaping RelationFunction<Operation.Codomain>) {
        self.operation = operation
        self.algebraicProperties = [
            .totality,
            .associativity,
            .identity(identity)
        ]
        self.equivalence = equivalence
    }
}

extension Monoid where Operation.Codomain : Equatable {
    public init(operation: Operation, identity: Operation.Codomain) {
        self.init(operation: operation, identity: identity, equivalence: (==))
    }
}

// MARK: Quasigroup

public struct Quasigroup<Operation : ClosedBinary> : MagmaProtocol {
    public typealias OpType = Operation
    public let operation: Operation
    public let algebraicProperties: [StructureProperty<Operation>]
    public let equivalence: RelationFunction<Operation.Codomain>

    public init(operation: Operation, latinSquare: @escaping LatinSquareFunction<Operation.Codomain>, equivalence: @escaping RelationFunction<Operation.Codomain>) {
        self.operation = operation
        self.algebraicProperties = [.totality, .latinSquare(latinSquare)]
        self.equivalence = equivalence
    }
}

extension Quasigroup where Operation.Codomain : Equatable {
    public init(operation: Operation, latinSquare: @escaping LatinSquareFunction<Operation.Codomain>) {
        self.init(operation: operation, latinSquare: latinSquare, equivalence: (==))
    }
}

// MARK: Loop
public struct Loop<Operation : ClosedBinary> : MagmaProtocol {
    public typealias OpType = Operation
    public let operation: Operation
    public let algebraicProperties: [StructureProperty<Operation>]
    public let equivalence: RelationFunction<Operation.Codomain>

    public init(operation: Operation, identity: Operation.Codomain, latinSquare: @escaping LatinSquareFunction<Operation.Codomain>, equivalence: @escaping RelationFunction<Operation.Codomain>) {
        self.operation = operation
        self.algebraicProperties = [
            .totality,
            .identity(identity),
            .latinSquare(latinSquare)
        ]
        self.equivalence = equivalence
    }
}

extension Loop where Operation.Codomain : Equatable {
    public init(operation: Operation, identity: Operation.Codomain, latinSquare: @escaping LatinSquareFunction<Operation.Codomain>) {
        self.init(operation: operation, identity: identity, latinSquare: latinSquare, equivalence: (==))
    }
}

public struct Group<Operation : ClosedBinary> : MagmaProtocol {
    public typealias OpType = Operation
    public let operation: Operation
    public let algebraicProperties: [StructureProperty<Operation>]
    public let equivalence: RelationFunction<Operation.Codomain>

    public init(operation: Operation, identity: Operation.Codomain, inverseOp: @escaping InvertFunction<Operation.Codomain>, equivalence: @escaping RelationFunction<Operation.Codomain>) {
        self.operation = operation
        self.algebraicProperties = [
            .totality,
            .associativity,
            .identity(identity),
            .invertibility(identity: identity, inverseOp)
        ]
        self.equivalence = equivalence
    }
}

extension Group where Operation.Codomain : Equatable {
    public init(operation: Operation, identity: Operation.Codomain, inverseOp: @escaping InvertFunction<Operation.Codomain>) {
        self.init(operation: operation, identity: identity, inverseOp: inverseOp, equivalence: (==))
    }
}

public struct AbelianGroup<Operation : ClosedBinary> : MagmaProtocol {
    public typealias OpType = Operation
    public let operation: Operation
    public let algebraicProperties: [StructureProperty<Operation>]
    public let equivalence: RelationFunction<Operation.Codomain>

    public init(operation: Operation, identity: Operation.Codomain, inverseOp: @escaping InvertFunction<Operation.Codomain>, equivalence: @escaping RelationFunction<Operation.Codomain>) {
        self.operation = operation
        self.algebraicProperties = [
            .totality,
            .commutativity,
            .associativity,
            .identity(identity),
            .invertibility(identity: identity, inverseOp)
        ]
        self.equivalence = equivalence
    }
}

extension AbelianGroup where Operation.Codomain : Equatable {
    public init(operation: Operation, identity: Operation.Codomain, inverseOp: @escaping InvertFunction<Operation.Codomain>) {
        self.init(operation: operation, identity: identity, inverseOp: inverseOp, equivalence: (==))
    }
}

public struct Semilattice<Operation : ClosedBinary> : MagmaProtocol {
    public typealias OpType = Operation
    public let operation: Operation
    public let algebraicProperties: [StructureProperty<Operation>]
    public let equivalence: RelationFunction<Operation.Codomain>

    public init(operation: Operation, idempotentElement: Operation.Codomain, equivalence: @escaping RelationFunction<Operation.Codomain>) {
        self.operation = operation
        self.algebraicProperties = [
            .totality,
            .associativity,
            .commutativity,
            .idempotence(idempotentElement)
        ]
        self.equivalence = equivalence
    }
}

extension Semilattice where Operation.Codomain : Equatable {
    public init(operation: Operation, idempotentElement: Operation.Codomain) {
        self.init(operation: operation, idempotentElement: idempotentElement, equivalence: (==))
    }
}

// MARK: -
public struct GenericStructure<Operation : ClosedBinary> : MagmaProtocol {
    public typealias OpType = Operation

    public let operation: Operation
    public let algebraicProperties: [StructureProperty<Operation>]
    public let equivalence: RelationFunction<Operation.Codomain>

    public init(operation: Operation, algebraicProperties: [StructureProperty<Operation>], equivalence: @escaping RelationFunction<Operation.Codomain>) {
        self.operation = operation
        self.algebraicProperties = algebraicProperties
        self.equivalence = equivalence
    }
}

extension GenericStructure where Operation.Codomain : Equatable {
    public init(operation: Operation, algebraicProperties: [StructureProperty<Operation>]) {
        self.init(operation: operation, algebraicProperties: algebraicProperties, equivalence: (==))
    }
}
