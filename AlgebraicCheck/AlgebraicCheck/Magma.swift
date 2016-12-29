//
//  Magma.swift
//  AlgebraicCheck
//
//  Created by TJ Usiyan on 2016/12/28.
//  Copyright © 2016 Buttons and Lights LLC. All rights reserved.
//

import SwiftCheck

public protocol ClosedBinary {
    associatedtype Codomain : Arbitrary, Equatable
    var function: (Codomain, Codomain) -> Codomain { get }
}

public struct ClosedBinaryOperation<UnderlyingSet : Equatable & Arbitrary> : ClosedBinary {
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
}

extension MagmaProtocol {
    public var concretizedProperties: [(description: String, Property)] {
        return algebraicProperties.flatMap {
            $0.concretize(with: operation)
        }
    }
}

public typealias LatinSquareFunction<UnderlyingSet> = ((_ a: UnderlyingSet, _ b: UnderlyingSet) -> (left: UnderlyingSet, right: UnderlyingSet))
public typealias InvertFunction<UnderlyingSet> = ((UnderlyingSet) -> UnderlyingSet)

public struct Magma<Operation : ClosedBinary> : MagmaProtocol {
    public typealias OpType = Operation
    public let operation: Operation
    public let algebraicProperties: [StructureProperty<Operation>]

    public init(operation: Operation) {
        self.operation = operation
        self.algebraicProperties = [.totality]
    }
}

public struct Semigroup<Operation : ClosedBinary> : MagmaProtocol {
    public typealias OpType = Operation
    public let operation: Operation

    public init(operation: Operation) {
        self.operation = operation
    }
    public var algebraicProperties: [StructureProperty<Operation>] {
        return [.totality, .associativity]
    }
}

public struct Monoid<Operation : ClosedBinary> : MagmaProtocol {
    public typealias OpType = Operation
    public let operation: Operation
    public let algebraicProperties: [StructureProperty<Operation>]

    public init(operation: Operation, identity: Operation.Codomain) {
        self.operation = operation
        self.algebraicProperties = [
            .totality,
            .associativity,
            .identity(identity)
        ]
    }
}

public struct Quasigroup<Operation : ClosedBinary> : MagmaProtocol {
    public typealias OpType = Operation
    public let operation: Operation
    public let algebraicProperties: [StructureProperty<Operation>]

    public init(operation: Operation, latinSquare: @escaping LatinSquareFunction<Operation.Codomain>) {
        self.operation = operation
        self.algebraicProperties = [.totality, .latinSquare(latinSquare)]
    }
}

public struct Loop<Operation : ClosedBinary> : MagmaProtocol {
    public typealias OpType = Operation
    public let operation: Operation
    public let algebraicProperties: [StructureProperty<Operation>]

    public init(operation: Operation, identity: Operation.Codomain, latinSquare: @escaping LatinSquareFunction<Operation.Codomain>) {
        self.operation = operation
        self.algebraicProperties = [
            .totality,
            .identity(identity),
            .latinSquare(latinSquare)
        ]
    }
}

public struct Group<Operation : ClosedBinary> : MagmaProtocol {
    public typealias OpType = Operation
    public let operation: Operation
    public let algebraicProperties: [StructureProperty<Operation>]

    public init(operation: Operation, identity: Operation.Codomain, inverseOp: @escaping InvertFunction<Operation.Codomain>) {
        self.operation = operation
        self.algebraicProperties = [
            .totality,
            .associativity,
            .identity(identity),
            .invertibility(identity: identity, inverseOp)
        ]
    }
}

public struct AbelianGroup<Operation : ClosedBinary> : MagmaProtocol {
    public typealias OpType = Operation
    public let operation: Operation
    public let algebraicProperties: [StructureProperty<Operation>]

    public init(operation: Operation, identity: Operation.Codomain, inverseOp: @escaping InvertFunction<Operation.Codomain>) {
        self.operation = operation
        self.algebraicProperties = [
            .totality,
            .commutativity,
            .associativity,
            .identity(identity),
            .invertibility(identity: identity, inverseOp)
        ]
    }
}
public struct Semilattice<Operation : ClosedBinary> : MagmaProtocol {
    public typealias OpType = Operation
    public let operation: Operation
    public let algebraicProperties: [StructureProperty<Operation>]

    public init(operation: Operation, idempotentElement: Operation.Codomain) {
        self.operation = operation
        self.algebraicProperties = [
            .totality,
            .associativity,
            .commutativity,
            .idempotence(idempotentElement)
        ]
    }
}

// MARK: - 
public struct GenericStructure<Operation : ClosedBinary> : MagmaProtocol {
    public typealias OpType = Operation

    public let operation: Operation
    public let algebraicProperties: [StructureProperty<Operation>]

    public init(operation: Operation, algebraicProperties: [StructureProperty<Operation>]) {
        self.operation = operation
        self.algebraicProperties = algebraicProperties
    }
}
