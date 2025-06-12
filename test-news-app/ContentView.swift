import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: NewsViewModel
    @StateObject private var tagManager: TagManager
    @State private var showingProfile = false
   
    init() {
        let newsVM = NewsViewModel()
        self._viewModel = StateObject(wrappedValue: newsVM)
        self._tagManager = StateObject(wrappedValue: TagManager(newsViewModel: newsVM))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(viewModel.availableTopics, id: \.self) { topic in
                                Button(action: {
                                    viewModel.toggleTopic(topic)
                                }) {
                                    Text(topic)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            viewModel.selectedTopics.contains(topic)
                                            ? Color.blue
                                            : Color(.systemGray5)
                                        )
                                        .foregroundColor(
                                            viewModel.selectedTopics.contains(topic)
                                            ? .white
                                            : .primary
                                        )
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 12)
                    .background(Color(.systemGroupedBackground))
                
                
                // News Cards with loading states
                if viewModel.isLoading && viewModel.newsCards.isEmpty {
                    // Initial loading state
                    VStack {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Loading fragments...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.error {
                    // Error state
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 40))
                            .foregroundColor(.orange)
                        Text("Error loading fragments")
                            .font(.headline)
                            .padding(.top, 8)
                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Button("Retry") {
                            Task {
                                await viewModel.loadNewsWithTags(tagManager.selectedTagNames)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top, 16)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // News Cards - now filtered based on selected tags
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            ForEach(filteredNewsCards()) { card in
                                NavigationLink(destination: NewsDetailView(card: card)) {
                                    NewsCardView(card: card)
                                        .padding(.horizontal)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .onAppear {
                                    // Load more when approaching the end
                                    if card.id == viewModel.newsCards.last?.id {
                                        Task {
                                            await viewModel.loadMoreNewsWithTags(tagManager.selectedTagNames)
                                        }
                                    }
                                }
                            }
                            
                            // Loading indicator for pagination
                            if viewModel.isLoading && !viewModel.newsCards.isEmpty {
                                HStack {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                    Text("Loading more...")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                            }
                        }
                        .padding(.vertical)
                    }
                    .background(Color(.systemGroupedBackground))
                }
            }
            .navigationTitle("Fragments")
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingProfile = true
                    }) {
                        Image(systemName: "person.circle")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingProfile) {
                ProfileView()
            }
            .onAppear {
                // Load news based on selected tags when view appears
                Task {
                    await viewModel.loadNewsWithTags(tagManager.selectedTagNames)
                }
            }
            .onChange(of: tagManager.selectedTags) { _ in
                // Reload news when tags change
                Task {
                    await viewModel.loadNewsWithTags(tagManager.selectedTagNames)
                }
            }
        }
    }
    
    // Filter news cards based on selected tags
    private func filteredNewsCards() -> [NewsCard] {
        guard !tagManager.selectedTags.isEmpty else {
            return viewModel.newsCards
        }
        
        return viewModel.newsCards.filter { card in
            let cardTopics = Set(card.topics.map { $0.lowercased() })
            return !cardTopics.isDisjoint(with: tagManager.selectedTagNames)
        }
    }
}


struct NewsCardView: View {
    let card: NewsCard
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Background Image with overlay
            ZStack(alignment: .bottomLeading) {
                // Image with placeholder using AsyncImage (iOS 15+)
                AsyncImage(url: URL(string: card.imageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 250)
                        .clipped()
                } placeholder: {
                    Rectangle()
                        .foregroundColor(.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                                .font(.system(size: 30))
                        )
                        .frame(height: 250)
                }
                .frame(maxWidth: .infinity, maxHeight: 250)
                .clipped()
                
                // Gradient overlay for better text visibility
                LinearGradient(
                    gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                // Date and Topics at bottom
                VStack(alignment: .leading, spacing: 4) {
                    // Formatted date
                    Text(card.dateObject.formatted(.relative(presentation: .named)))
                        .font(.caption)
                        .foregroundColor(.white)
                    
                    // Topics/tags
                    HStack {
                        ForEach(card.topics.prefix(3), id: \.self) { topic in
                            Text(topic)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Color.blue.opacity(0.8))
                                .cornerRadius(4)
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding()
            }
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
            
            // News Title
            Text(card.title)
                .font(.custom("Charter", size: 20))
                .fontWeight(.medium)
                .lineLimit(3)
                .padding(.horizontal, 12)
                .padding(.bottom, 16)
                .foregroundColor(.primary) // Ensure proper text color for navigation
        }
        .background(Color(.systemBackground).opacity(0.6))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
        )
    }
}

struct NewsDetailView: View {
    let card: NewsCard
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Hero Image
                AsyncImage(url: URL(string: card.imageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 300)
                        .clipped()
                } placeholder: {
                    Rectangle()
                        .foregroundColor(.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                                .font(.system(size: 40))
                        )
                        .frame(height: 300)
                }
                .frame(maxWidth: .infinity, maxHeight: 300)
                .clipped()
                
                VStack(alignment: .leading, spacing: 16) {
                    // Title
                    Text(card.title)
                        .font(.custom("Charter", size: 28))
                        .fontWeight(.bold)
                        .lineLimit(nil)
                    
                    // Date and Topics
                    HStack {
                        Text(card.dateObject.formatted(.dateTime.day().month().year()))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(card.topics, id: \.self) { topic in
                                    Text(topic)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .cornerRadius(8)
                                }
                            }
                            .padding(.horizontal, 1)
                        }
                    }
                    
                    Divider()
                    
                    // Summary
                    Text(card.summary)
                        .font(.custom("Charter", size: 18))
                        .foregroundColor(.secondary)
                        .lineLimit(nil)
                    
                    // Content
                    Text(card.summary)
                        .font(.custom("Charter", size: 16))
                        .lineLimit(nil)
                        .lineSpacing(4)
                    
                    // References Section
                    if !card.references.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Sources")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                Spacer()
                                
                                Text("\(card.references.count) reference\(card.references.count == 1 ? "" : "s")")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            LazyVStack(spacing: 12) {
                                ForEach(card.references) { reference in
                                    ReferenceView(reference: reference)
                                }
                            }
                        }
                        .padding(.top, 8)
                    }
                    
                    // Bottom padding for better scrolling experience
                    Color.clear
                        .frame(height: 20)
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Article")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ReferenceView: View {
    let reference: Reference
    
    var body: some View {
        Button(action: {
            // Open URL in Safari
            if let url = URL(string: reference.url) {
                UIApplication.shared.open(url)
            }
        }) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(reference.source)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Text(reference.dateObject.formatted(.dateTime.day().month()))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(reference.title)
                    .font(.footnote)
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.primary)
                
                HStack {
                    Image(systemName: "link")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text(reference.url)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.right")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// Extension to handle date formatting for Reference
extension Reference {
    var dateObject: Date {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: date) ?? Date()
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.light)
        
        NewsDetailView(card: NewsCard(
            id: "preview_1",
            title: "AI Breakthrough Enables Real-Time Language Translation",
            summary: "Revolutionary AI system achieves unprecedented accuracy in real-time translation across 40 languages, potentially transforming global communication and breaking down language barriers worldwide.",
            imageUrl: "https://picsum.photos/400/300?random=1",
            date: "2025-06-02T10:00:00Z",
            topics: ["AI", "Tech"],
            references: [
                Reference(
                    id: "ref_1",
                    url: "https://example.com/ai-news",
                    source: "TechCrunch",
                    title: "AI Translation Breakthrough Announced",
                    date: "2025-06-02T09:00:00Z"
                ),
                Reference(
                    id: "ref_2",
                    url: "https://example.com/ai-research",
                    source: "Nature",
                    title: "Neural Networks Achieve Human-Level Translation",
                    date: "2025-06-02T08:30:00Z"
                )
            ]
        ))
        .previewDisplayName("Detail View")
    }
}
