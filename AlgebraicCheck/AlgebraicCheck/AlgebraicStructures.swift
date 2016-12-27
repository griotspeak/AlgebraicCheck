import SwiftCheck

public typealias SwiftCheckProperties = [(description: String, Property)]

// MARK: -

public protocol BinaryRelationProtocol {
    associatedtype Domain
    associatedtype Codomain
    var isRRelated: (Domain, Codomain) -> Bool { get }
}

public protocol ClosedBinaryRelationProtocol : BinaryRelationProtocol {
    associatedtype Codomain
    var isRRelated: (Codomain, Codomain) -> Bool { get }
}

public struct BinaryRelation<UnderlyingSet : Arbitrary> : BinaryRelationProtocol {
    public typealias Domain = UnderlyingSet
    public typealias Codomain = UnderlyingSet
    public let isRRelated: (UnderlyingSet, UnderlyingSet) -> Bool
    public init(_ isRRelated: @escaping (UnderlyingSet, UnderlyingSet) -> Bool) {
        self.isRRelated = isRRelated
    }
}

// MARK: -

public protocol Transform {
    associatedtype Operand : Arbitrary, Equatable
}

public protocol ClosedBinary : Transform {
    var function: (Operand, Operand) -> Operand { get }
}

public struct ClosedBinaryOperation<UnderlyingSet : Equatable & Arbitrary> : ClosedBinary {
    public typealias Operand = UnderlyingSet
    public let function: (UnderlyingSet, UnderlyingSet) -> UnderlyingSet
    public init(_ function: @escaping (UnderlyingSet, UnderlyingSet) -> UnderlyingSet) {
        self.function = function
    }
}
