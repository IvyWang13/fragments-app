import SwiftUI

struct ProfileView: View {
    @StateObject private var tagManager: TagManager
    @Environment(\.dismiss) private var dismiss
    init() {
        let newsVM = NewsViewModel()
//        self._viewModel = StateObject(wrappedValue: newsVM)
        self._tagManager = StateObject(wrappedValue: TagManager(newsViewModel: newsVM))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Profile Header
                    VStack(spacing: 16) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        
                        Text("Customize Your News")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Select topics you're interested in to get personalized news fragments")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top)
                    
                    // Selected Tags Count
                    if !tagManager.selectedTags.isEmpty {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("\(tagManager.selectedTags.count) topic\(tagManager.selectedTags.count == 1 ? "" : "s") selected")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Add New Tag Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Add Custom Topic")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        HStack {
                            TextField("Enter topic name...", text: $tagManager.newTagText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .onSubmit {
                                    tagManager.addCustomTag()
                                }
                            
                            Button(action: {
                                tagManager.addCustomTag()
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                            .disabled(tagManager.newTagText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Available Tags Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Available Topics")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 100), spacing: 12)
                        ], spacing: 12) {
                            ForEach(tagManager.userTags) { tag in
                                TagButton(tag: tag, tagManager: tagManager)
                            }
                         
                        }
                        .padding(.horizontal)
                    }
                    
                    // Bottom spacing
                    Color.clear.frame(height: 20)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Tag Button Component
struct TagButton: View {
    let tag: UserTag
    let tagManager: TagManager
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        Button(action: {
            tagManager.toggleTag(tag)
        }) {
            HStack(spacing: 8) {
                Text(tag.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                if tag.isCustom {
                    Button(action: {
                        showDeleteConfirmation = true
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.red.opacity(0.7))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                tag.isSelected
                ? Color.blue
                : Color(.systemGray5)
            )
            .foregroundColor(
                tag.isSelected
                ? .white
                : .primary
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        tag.isSelected ? Color.blue : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .confirmationDialog(
            "Remove \"\(tag.name)\"?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Remove", role: .destructive) {
                tagManager.removeCustomTag(tag)
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This custom topic will be permanently removed.")
        }
    }
}


// MARK: - Preview
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
        
//        UpdatedContentView()
//            .previewDisplayName("Main View with Profile")
    }
}
