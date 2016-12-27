import SwiftCheck
import AlgebraicCheck

func reportThat<Structure, UnderlyingSet>(_ underlyingSet: UnderlyingSet.Type, forms structure: Structure)
    where Structure : AlgebraicStructure, UnderlyingSet : Arbitrary & Equatable {
        for (message, property) in structure.concretizedProperties {
            reportProperty(message) <- property
        }
}

reportThat(Int.self, forms: AbelianGroup(operation: ClosedBinaryOperation<Int>(+), identity: 0, inverseOp: (-)))
reportThat(Int.self, forms: Quasigroup(operation: ClosedBinaryOperation<Int>(-), latinSquare: { (-($1 - $0), ($1 + $0)) }))

// MARK: - 
func reportThat<Structure, UnderlyingSet>(_ underlyingSet: UnderlyingSet.Type, has relation: Structure)
    where Structure : OrderedStructure, UnderlyingSet : Arbitrary {
        for (message, property) in relation.concretizedProperties {
            reportProperty(message) <- property
        }
}

reportThat(Int.self, has: PartialOrder(relation: BinaryRelation<Int>(<=), equivalence: (==)))
reportThat(Int.self, has: TotalOrder(relation: BinaryRelation<Int>(<=), equivalence: (==)))