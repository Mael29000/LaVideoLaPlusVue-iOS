//
//  NamespaceContainer.swift
//  Summit
//
//  Created by Maël Suard on 28/04/2025.
//

import SwiftUI

class NamespaceContainer: ObservableObject {
    var namespace : Namespace.ID
    
    init(_ namespace: Namespace.ID){
        self.namespace = namespace
    }
}

