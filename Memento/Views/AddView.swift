//
//  AddView.swift
//  Memento
//
//  Created by Roscoe Rubin-Rottenberg on 5/24/24.
//

import SwiftUI
import SwiftData
import LinkPresentation

struct AddView: View {
    enum FocusableField: Hashable, CaseIterable {
        case link, note
    }
    @Environment(\.modelContext) private var modelContext
    
    @State var viewModel = AddViewModel()
    @Binding var shown: Bool
    
    @FocusState var focus: FocusableField?
    
    let provider = LPMetadataProvider()
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                TextField("Enter URL", text: $viewModel.linkText)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .keyboardType(.URL)
                    .focused($focus, equals: .link)
                    .padding(.bottom)
                Text("Notes")
                    .font(.headline)
                TextEditor(text: $viewModel.noteText)
                    .focused($focus, equals: .note)
                
            }
            .padding()
            .navigationTitle("New Item")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        shown = false
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        Task {
                            if viewModel.noteText.isEmpty && !viewModel.linkText.isEmpty {
                                await addLink(link: viewModel.linkText)
                            } else if !viewModel.noteText.isEmpty && viewModel.linkText.isEmpty {
                                modelContext.insert(Item(viewModel.noteText))
                            } else if !viewModel.noteText.isEmpty && !viewModel.linkText.isEmpty {
                                await addLink(link: viewModel.linkText, note: viewModel.noteText)
                            }
                            UpdateAll()
                        }
                        shown = false
                    }
                    .disabled(viewModel.linkText.isEmpty && viewModel.noteText.isEmpty)
                    .keyboardShortcut(.defaultAction)
                    
                }
                
            }
        }
        .onAppear {
            focus = AddView.FocusableField.allCases.first
        }
    }
    
    func addLink(link: String, note: String? = nil) async {
        guard let item = await Item(link: link, note: note) else {
            return
        }
        modelContext.insert(item)
    }
    
    private func focusFirstField() {
        focus = FocusableField.allCases.first
    }

    private func focusNextField() {
        switch focus {
        case .link:
            focus = .note
        case .note:
            Task {
                if viewModel.noteText.isEmpty && !viewModel.linkText.isEmpty {
                    await addLink(link: viewModel.linkText)
                } else if !viewModel.noteText.isEmpty && viewModel.linkText.isEmpty {
                    modelContext.insert(Item(viewModel.noteText))
                } else if !viewModel.noteText.isEmpty && !viewModel.linkText.isEmpty {
                    await addLink(link: viewModel.linkText, note: viewModel.noteText)
                }
                UpdateAll()
                shown = false
            }
        case nil:
            break
        }
    }
}

#Preview {
    AddView(shown: .constant(false))
        .modelContainer(for: Item.self, inMemory: true)
}
