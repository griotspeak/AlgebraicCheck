import AlgebraicCheck

reportThat(Int.self, forms: AbelianGroup(operation: ClosedBinaryOperation<Int>(+), identity: 0, inverseOp: (-)))
reportThat(Int.self, forms: Quasigroup(operation: ClosedBinaryOperation<Int>(-), latinSquare: { (-($1 - $0), ($1 + $0)) }))
reportThat(Int.self, forms: Semigroup(operation: ClosedBinaryOperation<Int>(-)))

reportThat(Int.self, has: PartialOrder(relation: HomogenousRelation<Int>(<=), equivalence: ==))
reportThat(Int.self, has: TotalOrder(relation: HomogenousRelation<Int>(<=), equivalence: ==))

reportThat(Int.self, has: Int.form(relation: ==, algebraicProperties: [RelationProperty.symmetric]))
reportThat(Int.self, has: Int.form(relation: <, algebraicProperties: [RelationProperty.asymmetric]))

extension ClosedBinary {
    var description: String {
        return String(describing: type(of: self))
    }
}

print(ClosedBinaryOperation<Int>(+).description)