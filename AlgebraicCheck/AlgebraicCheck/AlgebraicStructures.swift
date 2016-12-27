import SwiftCheck

public typealias SwiftCheckProperties = [(description: String, Property)]

// MARK: -

public protocol RelationProtocol {
    associatedtype Operand : Arbitrary
}

public protocol BinaryRelationProtocol : RelationProtocol {
    var function: (Operand, Operand) -> Bool { get }
}

public struct BinaryRelation<UnderlyingSet : Arbitrary> : BinaryRelationProtocol {
    public typealias Operand = UnderlyingSet
    public let function: (UnderlyingSet, UnderlyingSet) -> Bool
    public init(_ function: @escaping (UnderlyingSet, UnderlyingSet) -> Bool) {
        self.function = function
    }
}

// MARK: -

public protocol Transform : RelationProtocol {
    associatedtype Operand : Equatable, Arbitrary
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
