//
//  InfoView.swift
//  Memento
//
//  Created by Roscoe Rubin-Rottenberg on 7/15/24.
//

import SwiftUI

struct InfoView: View {
    @Binding var isShown: Bool
    var body: some View {
        NavigationStack {
            Form {
                Link("App Settings", destination: URL(string: UIApplication.openSettingsURLString)!)
            }
            .navigationTitle("Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem {
                    Button("Done") {
                        isShown = false
                    }
                }
            }
        }
    }
    enum viewedTypes: String, CaseIterable {
        case notes
        case links
        case all
        case none
    }
}

#Preview {
    InfoView(isShown: .constant(true))
}
