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

public protocol MagmaType {
    associatedtype OpType : ClosedBinary
    var operation: OpType { get }
    var algebraicProperties: [StructureProperty<OpType>] { get }
    var concretizedProperties: [(description: String, Property)] { get }
}

extension MagmaType {
    public var concretizedProperties: [(description: String, Property)] {
        return algebraicProperties.flatMap {
            $0.concretize(with: operation)
        }
    }
}


public typealias LatinSquareFunction<UnderlyingSet> = ((_ a: UnderlyingSet, _ b: UnderlyingSet) -> (left: UnderlyingSet, right: UnderlyingSet))
public typealias InvertFunction<UnderlyingSet> = ((UnderlyingSet) -> UnderlyingSet)

public struct PropertyInputComponents<UnderlyingSet, Operation>
where UnderlyingSet : Arbitrary & Equatable, Operation : ClosedBinary, Operation.Codomain == UnderlyingSet {

    // for each
    //    a ∗ x = b
    //    y ∗ a = b

    public var operation: Operation
    public var identity: UnderlyingSet?
    public var inverseOp: InvertFunction<UnderlyingSet>?
    public var latinSquare: LatinSquareFunction<UnderlyingSet>?

    public init(operation: Operation, identity: UnderlyingSet? = nil, inverseOp: InvertFunction<UnderlyingSet>? = nil, latinSquare: LatinSquareFunction<UnderlyingSet>? = nil) {
        self.operation = operation
        self.identity = identity
        self.inverseOp = inverseOp
        self.latinSquare = latinSquare
    }
}

public struct Magma<Operation : ClosedBinary> : MagmaType {
    public typealias OpType = Operation
    public let operation: Operation

    public init(operation: Operation) {
        self.operation = operation
    }

    public var algebraicProperties: [StructureProperty<Operation>] {
        return []
    }
}

public struct Semigroup<Operation : ClosedBinary> : MagmaType {
    public typealias OpType = Operation
    public let operation: Operation

    public init(operation: Operation) {
        self.operation = operation
    }
    public var algebraicProperties: [StructureProperty<Operation>] {
        return [StructureProperty.associativity]
    }
}


public struct Quasigroup<Operation : ClosedBinary> : MagmaType {
    public typealias OpType = Operation
    public let operation: Operation
    public let algebraicProperties: [StructureProperty<Operation>]

    public init(operation: Operation, latinSquare: @escaping LatinSquareFunction<Operation.Codomain>) {
        self.operation = operation
        self.algebraicProperties = [StructureProperty<Operation>.latinSquare(latinSquare)]
    }
}

public struct Loop<Operation : ClosedBinary> : MagmaType {
    public typealias OpType = Operation
    public let operation: Operation
    public let algebraicProperties: [StructureProperty<Operation>]

    public init(operation: Operation, identity: Operation.Codomain, latinSquare: @escaping LatinSquareFunction<Operation.Codomain>) {
        self.operation = operation
        self.algebraicProperties = [
            StructureProperty.identity(identity),
            StructureProperty<Operation>.latinSquare(latinSquare)
        ]
    }
}

struct Monoid<Operation : ClosedBinary> : MagmaType {
    public typealias OpType = Operation
    public let operation: Operation
    public let algebraicProperties: [StructureProperty<Operation>]

    public init(operation: Operation, identity: Operation.Codomain) {
        self.operation = operation
        self.algebraicProperties = [
            StructureProperty.associativity,
            StructureProperty.identity(identity)
        ]
    }
}

public struct AbelianGroup<Operation : ClosedBinary> : MagmaType {
    public typealias OpType = Operation
    public let operation: Operation
    public let algebraicProperties: [StructureProperty<Operation>]

    public init(operation: Operation, identity: Operation.Codomain, inverseOp: @escaping InvertFunction<Operation.Codomain>) {
        self.operation = operation
        self.algebraicProperties = [
            StructureProperty.commutativity,
            StructureProperty.associativity,
            StructureProperty.identity(identity),
            StructureProperty.invertibility(identity: identity, inverseOp)
        ]
    }
}
