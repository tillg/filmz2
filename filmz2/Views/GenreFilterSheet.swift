//
//  GenreFilterSheet.swift
//  filmz2
//
//  Created by Claude on 02.06.25.
//

import SwiftUI
import SwiftData

struct GenreFilterSheet: View {
    @ObservedObject var viewModel: CollectionViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    if viewModel.availableGenres.isEmpty {
                        HStack {
                            Spacer()
                            VStack(spacing: 12) {
                                ProgressView()
                                Text("Loading genres...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 20)
                            Spacer()
                        }
                    } else {
                        ForEach(viewModel.availableGenres, id: \.self) { genre in
                            HStack {
                                Text(genre)
                                Spacer()
                                if viewModel.filter.genres.contains(genre) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.accentColor)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if viewModel.filter.genres.contains(genre) {
                                    viewModel.filter.genres.remove(genre)
                                } else {
                                    viewModel.filter.genres.insert(genre)
                                }
                            }
                        }
                    }
                } header: {
                    if !viewModel.filter.genres.isEmpty {
                        Text("\(viewModel.filter.genres.count) selected")
                    }
                }
                
                if !viewModel.filter.genres.isEmpty {
                    Section {
                        Button("Clear All") {
                            viewModel.filter.genres.removeAll()
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Filter by Genre")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    GenreFilterSheet(viewModel: CollectionViewModel())
}