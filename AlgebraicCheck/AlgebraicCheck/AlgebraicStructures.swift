import SwiftCheck

public typealias SwiftCheckProperties = [(description: String, Property)]

// MARK: -

public protocol BinaryRelationProtocol {
    associatedtype Domain
    associatedtype Codomain
    var relates: (Domain, Codomain) -> Bool { get }
}

public protocol HomogenousRelationProtocol : BinaryRelationProtocol {
    associatedtype Codomain
    var relates: (Codomain, Codomain) -> Bool { get }
}

public struct HomogenousRelation<UnderlyingSet : Arbitrary> : HomogenousRelationProtocol {
    public typealias Domain = UnderlyingSet
    public typealias Codomain = UnderlyingSet
    public let relates: (UnderlyingSet, UnderlyingSet) -> Bool
    public init(_ relates: @escaping (UnderlyingSet, UnderlyingSet) -> Bool) {
        self.relates = relates
    }
}

// MARK: -

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
