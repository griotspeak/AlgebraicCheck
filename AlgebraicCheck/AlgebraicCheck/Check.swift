//
//  Check.swift
//  AlgebraicCheck
//
//  Created by TJ Usiyan on 2016/12/28.
//  Copyright © 2016 Buttons and Lights LLC. All rights reserved.
//

import SwiftCheck


public func report<Structure : CheckableStructure>(structure: Structure) {
    for (message, property) in structure.concretizedProperties {
        reportProperty(message) <- property
    }
}

public func properties<Structure : CheckableStructure>(structure: Structure) {
    for (message, prop) in structure.concretizedProperties {
        property(message) <- prop
    }
}

// MARK: -

public func reportThat<Structure, UnderlyingSet>(_ underlyingSet: UnderlyingSet.Type, forms structure: Structure)
    where Structure : MagmaProtocol, UnderlyingSet : Arbitrary {
        report(structure: structure)
}

public func properties<Structure, UnderlyingSet>(_ underlyingSet: UnderlyingSet.Type, forms structure: Structure)
    where Structure : MagmaProtocol, UnderlyingSet : Arbitrary {
        properties(structure: structure)
}

// MARK: -

public func reportThat<Structure, UnderlyingSet>(_ underlyingSet: UnderlyingSet.Type, has relation: Structure)
    where Structure : OrderedStructure, UnderlyingSet : Arbitrary {
        report(structure: relation)
}

public func properties<Structure, UnderlyingSet>(_ underlyingSet: UnderlyingSet.Type, has relation: Structure)
    where Structure : OrderedStructure, UnderlyingSet : Arbitrary {
        properties(structure: relation)
}
