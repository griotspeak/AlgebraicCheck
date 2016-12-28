//
//  Check.swift
//  AlgebraicCheck
//
//  Created by TJ Usiyan on 2016/12/28.
//  Copyright © 2016 Buttons and Lights LLC. All rights reserved.
//

import SwiftCheck

public func reportThat<Structure, UnderlyingSet>(_ underlyingSet: UnderlyingSet.Type, forms structure: Structure)
    where Structure : MagmaProtocol, UnderlyingSet : Arbitrary & Equatable {
        for (message, property) in structure.concretizedProperties {
            reportProperty(message) <- property
        }
}

public func properties<Structure, UnderlyingSet>(_ underlyingSet: UnderlyingSet.Type, forms structure: Structure)
    where Structure : MagmaProtocol, UnderlyingSet : Arbitrary & Equatable {
        for (message, prop) in structure.concretizedProperties {
            property(message) <- prop
        }
}

// MARK: -

public func reportThat<Structure, UnderlyingSet>(_ underlyingSet: UnderlyingSet.Type, has relation: Structure)
    where Structure : OrderedStructure, UnderlyingSet : Arbitrary {
        for (message, property) in relation.concretizedProperties {
            reportProperty(message) <- property
        }
}

public func properties<Structure, UnderlyingSet>(_ underlyingSet: UnderlyingSet.Type, has relation: Structure)
    where Structure : OrderedStructure, UnderlyingSet : Arbitrary {
        for (message, prop) in relation.concretizedProperties {
            property(message) <- prop
        }
}
