//
//  Ring.swift
//  AlgebraicCheck
//
//  Created by TJ Usiyan on 2016/12/28.
//  Copyright © 2016 Buttons and Lights LLC. All rights reserved.
//

import SwiftCheck

public struct RingOperations<Addition : ClosedBinary, Multiplication : ClosedBinary>
where Addition.Codomain == Multiplication.Codomain {

    let addition: Addition
    let multiplication: Multiplication
}
//
//public protocol RingProtocol {
//    associatedtype UnderlyingSet : Arbitrary, Equatable
//
//
//    var operations: RingOperations<UnderlyingSet> { get }
//    var algebraicProperties: [StructureProperty<OpType>] { get }
//    var concretizedProperties: [(description: String, Property)] { get }
//}

fileprivate enum Either<A, M> {
    case addition(A)
    case multiplication(M)
}

fileprivate typealias OpProp<Element : Arbitrary> = StructureProperty<ClosedBinaryOperation<Element>>


// MARK: Semiring

public struct Semiring<UnderlyingSet : Arbitrary> : CheckableStructure {
    public typealias Addition<Element : Arbitrary> = Monoid<ClosedBinaryOperation<Element>>
    public typealias Multiplication<Element : Arbitrary> = Monoid<ClosedBinaryOperation<Element>>

    let addition: Addition<UnderlyingSet>
    let multiplication: Multiplication<UnderlyingSet>
    fileprivate let algebraicProperties: [Either<OpProp<UnderlyingSet>, OpProp<UnderlyingSet>>]
    public let equivalence: RelationFunction<UnderlyingSet>

    public init(additionDescription: String, addition: Addition<UnderlyingSet>, multiplication: Multiplication<UnderlyingSet>, multiplicativeAbsorbingElement: UnderlyingSet, equivalence: @escaping RelationFunction<UnderlyingSet>) {
        self.addition = addition
        self.multiplication = multiplication
        self.equivalence = equivalence

        var aProperties = [Either<OpProp<UnderlyingSet>, OpProp<UnderlyingSet>>]()
        aProperties.append(contentsOf: addition.algebraicProperties.map { .addition($0) })
        aProperties.append(contentsOf: multiplication.algebraicProperties.map { .multiplication($0) })
        aProperties.append(.multiplication(.distributive(over: additionDescription, addition: addition.operation.function)))
        aProperties.append(.multiplication(.absorbingElement(multiplicativeAbsorbingElement)))
        self.algebraicProperties = aProperties
    }

    public var concretizedProperties: SwiftCheckProperties {
        return algebraicProperties.flatMap { either -> SwiftCheckProperties in
            switch either {
            case let .addition(structureProp):
                return structureProp.concretize(with: addition.operation, equivalence: equivalence)
            case let .multiplication(structureProp):
                return structureProp.concretize(with: multiplication.operation, equivalence: equivalence)

            }
        }
    }
}

extension Semiring where UnderlyingSet : Equatable {
    public init(additionDescription: String, addition: Addition<UnderlyingSet>, multiplication: Multiplication<UnderlyingSet>, multiplicativeAbsorbingElement: UnderlyingSet) {
        self.init(additionDescription: additionDescription, addition: addition, multiplication: multiplication, multiplicativeAbsorbingElement: multiplicativeAbsorbingElement, equivalence: (==))
    }
}

// MARK: Ring

/// Does not assume commutativity.
public struct Ring<UnderlyingSet : Arbitrary> : CheckableStructure {
    public typealias Addition<Element : Arbitrary> = AbelianGroup<ClosedBinaryOperation<Element>>
    public typealias Multiplication<Element : Arbitrary> = Monoid<ClosedBinaryOperation<Element>>

    let addition: Addition<UnderlyingSet>
    let multiplication: Multiplication<UnderlyingSet>
    fileprivate let algebraicProperties: [Either<OpProp<UnderlyingSet>, OpProp<UnderlyingSet>>]
    public let equivalence: RelationFunction<UnderlyingSet>

    public init(additionDescription: String, addition: Addition<UnderlyingSet>, multiplication: Multiplication<UnderlyingSet>, multiplicativeAbsorbingElement: UnderlyingSet, equivalence: @escaping RelationFunction<UnderlyingSet>) {
        self.addition = addition
        self.multiplication = multiplication

        var aProperties = [Either<OpProp<UnderlyingSet>, OpProp<UnderlyingSet>>]()
        aProperties.append(contentsOf: addition.algebraicProperties.map { .addition($0) })
        aProperties.append(contentsOf: multiplication.algebraicProperties.map { .multiplication($0) })
        aProperties.append(.multiplication(.distributive(over: additionDescription, addition: addition.operation.function)))
        aProperties.append(.multiplication(.absorbingElement(multiplicativeAbsorbingElement)))
        self.algebraicProperties = aProperties
        self.equivalence = equivalence
    }

    public var concretizedProperties: SwiftCheckProperties {
        return algebraicProperties.flatMap { either -> SwiftCheckProperties in
            switch either {
            case let .addition(structureProp):
                return structureProp.concretize(with: addition.operation, equivalence: equivalence)
            case let .multiplication(structureProp):
                return structureProp.concretize(with: multiplication.operation, equivalence: equivalence)

            }
        }
    }
}


extension Ring where UnderlyingSet : Equatable {
    public init(additionDescription: String, addition: Addition<UnderlyingSet>, multiplication: Multiplication<UnderlyingSet>, multiplicativeAbsorbingElement: UnderlyingSet) {
        self.init(additionDescription: additionDescription, addition: addition, multiplication: multiplication, multiplicativeAbsorbingElement: multiplicativeAbsorbingElement, equivalence: (==))
    }
}

// MARK: Commutative Ring

/// - ∀a,b ∈ UnderlyingSet: a•b = b•a
/// - (For all `a` and `b` in Underlying Set, `a•b == b•a`)
public struct CommutativeRing<UnderlyingSet : Arbitrary> : CheckableStructure {
    public typealias Addition<Element : Arbitrary> = AbelianGroup<ClosedBinaryOperation<Element>>
    public typealias Multiplication<Element : Arbitrary> = Monoid<ClosedBinaryOperation<Element>>

    let addition: Addition<UnderlyingSet>
    let multiplication: Multiplication<UnderlyingSet>
    fileprivate let algebraicProperties: [Either<OpProp<UnderlyingSet>, OpProp<UnderlyingSet>>]
    public let equivalence: RelationFunction<UnderlyingSet>

    public init(additionDescription: String, addition: Addition<UnderlyingSet>, multiplication: Multiplication<UnderlyingSet>, equivalence: @escaping RelationFunction<UnderlyingSet>) {
        self.addition = addition
        self.multiplication = multiplication

        var aProperties = [Either<OpProp<UnderlyingSet>, OpProp<UnderlyingSet>>]()
        aProperties.append(contentsOf: addition.algebraicProperties.map { .addition($0) })
        aProperties.append(contentsOf: multiplication.algebraicProperties.map { .multiplication($0) })
        aProperties.append(.multiplication(.distributive(over: additionDescription, addition: addition.operation.function)))
        aProperties.append(.multiplication(.commutativity))
        self.algebraicProperties = aProperties
        self.equivalence = equivalence
    }

    public var concretizedProperties: SwiftCheckProperties {
        return algebraicProperties.flatMap { either -> SwiftCheckProperties in
            switch either {
            case let .addition(structureProp):
                return structureProp.concretize(with: addition.operation, equivalence: equivalence)
            case let .multiplication(structureProp):
                return structureProp.concretize(with: multiplication.operation, equivalence: equivalence)

            }
        }
    }
}

extension CommutativeRing where UnderlyingSet : Equatable {
    public init(additionDescription: String, addition: Addition<UnderlyingSet>, multiplication: Multiplication<UnderlyingSet>) {
        self.init(additionDescription: additionDescription, addition: addition, multiplication: multiplication, equivalence: (==))
    }
}

// MARK: Noncommutative Ring

/// - ∃ a, b ∈ UnderlyingSet | a•b ≠ b•a
/// - (There exists some elements of `UnderlyingSet` a and b such that `a•b ≠ b•a`)
public struct NoncommutativeRing<UnderlyingSet : Arbitrary> : CheckableStructure {
    public typealias Addition<Element : Arbitrary> = AbelianGroup<ClosedBinaryOperation<Element>>
    public typealias Multiplication<Element : Arbitrary> = Monoid<ClosedBinaryOperation<Element>>

    let addition: Addition<UnderlyingSet>
    let multiplication: Multiplication<UnderlyingSet>
    fileprivate let algebraicProperties: [Either<OpProp<UnderlyingSet>, OpProp<UnderlyingSet>>]
    public let equivalence: RelationFunction<UnderlyingSet>

    public init(additionDescription: String, addition: Addition<UnderlyingSet>, multiplication: Multiplication<UnderlyingSet>, commutativityCounterExample: (UnderlyingSet, UnderlyingSet), equivalence: @escaping RelationFunction<UnderlyingSet>) {
        self.addition = addition
        self.multiplication = multiplication

        var aProperties = [Either<OpProp<UnderlyingSet>, OpProp<UnderlyingSet>>]()
        aProperties.append(contentsOf: addition.algebraicProperties.map { .addition($0) })
        aProperties.append(contentsOf: multiplication.algebraicProperties.map { .multiplication($0) })
        aProperties.append(.multiplication(.distributive(over: additionDescription, addition: addition.operation.function)))
        aProperties.append(.multiplication(.noncommutative(commutativityCounterExample: commutativityCounterExample)))
        self.algebraicProperties = aProperties
        self.equivalence = equivalence
    }

    public var concretizedProperties: SwiftCheckProperties {
        return algebraicProperties.flatMap { either -> SwiftCheckProperties in
            switch either {
            case let .addition(structureProp):
                return structureProp.concretize(with: addition.operation, equivalence: equivalence)
            case let .multiplication(structureProp):
                return structureProp.concretize(with: multiplication.operation, equivalence: equivalence)

            }
        }
    }
}

extension NoncommutativeRing where UnderlyingSet : Equatable {
public init(additionDescription: String, addition: Addition<UnderlyingSet>, multiplication: Multiplication<UnderlyingSet>, commutativityCounterExample: (UnderlyingSet, UnderlyingSet)) {
    self.init(additionDescription: additionDescription, addition: addition, multiplication: multiplication, commutativityCounterExample: commutativityCounterExample, equivalence: (==))
    }
}
