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

fileprivate typealias OpProp<Element : Equatable & Arbitrary> = StructureProperty<ClosedBinaryOperation<Element>>
public typealias Addition<Element : Equatable & Arbitrary> = AbelianGroup<ClosedBinaryOperation<Element>>
public typealias Multiplication<Element : Equatable & Arbitrary> = Monoid<ClosedBinaryOperation<Element>>

public struct Ring<UnderlyingSet : Arbitrary & Equatable> : CheckableStructure {

    let addition: Addition<UnderlyingSet>
    let multiplication: Multiplication<UnderlyingSet>
    fileprivate let algebraicProperties: [Either<OpProp<UnderlyingSet>, OpProp<UnderlyingSet>>]

    public init(additionDescription: String, addition: Addition<UnderlyingSet>, multiplication: Multiplication<UnderlyingSet>) {
        self.addition = addition
        self.multiplication = multiplication

        var aProperties = [Either<OpProp<UnderlyingSet>, OpProp<UnderlyingSet>>]()
        aProperties.append(contentsOf: addition.algebraicProperties.map { .addition($0) })
        aProperties.append(contentsOf: multiplication.algebraicProperties.map { .multiplication($0) })
        aProperties.append(.multiplication(.distributive(over: additionDescription, addition: addition.operation.function)))
        self.algebraicProperties = aProperties
    }

    public var concretizedProperties: SwiftCheckProperties {
        return algebraicProperties.flatMap { either -> SwiftCheckProperties in
            switch either {
            case let .addition(structureProp):
                return structureProp.concretize(with: addition.operation)
            case let .multiplication(structureProp):
                return structureProp.concretize(with: multiplication.operation)

            }
        }
    }
}


