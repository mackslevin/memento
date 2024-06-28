//
//  ConfigureModelContainer.swift
//  Memento
//
//  Created by Roscoe Rubin-Rottenberg on 5/28/24.
//

import SwiftData

public func ConfigureModelContainer() -> ModelContainer {
    let schema = Schema([
        Item.self,
        Note.self
    ])
    
    // Set up your ModelConfiguration however you need it
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false, groupContainer: .identifier("group.xyz.knotbin.memento"), cloudKitDatabase: .none)
    
    do {
        return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
        fatalError(error.localizedDescription)
    }
}
