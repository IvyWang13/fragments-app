import SwiftUI

struct NewsCard: Identifiable {
    let id = UUID()
    let title: String
    let date: Date
    let topics: [String]
    let imageURL: URL?
    let content: String // Added for detail view
}

struct ContentView: View {
    // Available topics for filtering
    let availableTopics = ["AI", "Tech", "Finance", "China"]
    @State private var selectedTopics: Set<String> = []
    
    // Sample data - replaced with expanded data including content
    @State private var newsCards: [NewsCard] = [
        NewsCard(
            title: "AI Breakthrough Enables Real-Time Language Translation",
            date: Date().addingTimeInterval(-3600 * 5), // 5 hours ago
            topics: ["AI", "Tech"],
            imageURL: URL(string: "https://picsum.photos/400/300?random=1"),
            content: """
            Researchers at DeepMind have developed a new AI model that can translate between languages in real-time with near-human accuracy. The system, called Universal Translator, uses a novel neural architecture that processes speech directly without first converting to text.
            
            "This represents a significant leap forward in machine translation," said Dr. Sarah Chen, lead researcher on the project. "Our model achieves 98.7% accuracy on standardized tests, outperforming previous state-of-the-art systems by 15%."
            
            The technology could revolutionize global communication, making real-time translation seamless in video calls, international conferences, and even casual conversations between people speaking different languages. Early adopters include the United Nations and several multinational corporations.
            """
        ),
        NewsCard(
            title: "Global Climate Summit Reaches Historic Agreement",
            date: Date().addingTimeInterval(-3600 * 24), // 1 day ago
            topics: ["Finance", "China"],
            imageURL: URL(string: "https://picsum.photos/400/300?random=2"),
            content: """
            After two weeks of intense negotiations, world leaders at the COP28 climate summit in Dubai have reached a landmark agreement to accelerate emissions reductions. The deal includes unprecedented commitments from both developed and developing nations.
            
            Key provisions of the agreement include:
            - Phasing out coal power by 2040 in developed countries and 2050 in developing nations
            - $100 billion annual climate finance package to help vulnerable countries adapt
            - Methane emissions cuts of 30% by 2030
            - Commitment to net-zero emissions by 2060 from China and India
            
            "This is the most significant step forward in global climate cooperation since the Paris Agreement," said UN Secretary-General António Guterres.
            """
        ),
        NewsCard(
            title: "New Study Reveals Benefits of Mediterranean Diet",
            date: Date().addingTimeInterval(-3600 * 48), // 2 days ago
            topics: ["Tech", "Finance"],
            imageURL: URL(string: "https://picsum.photos/400/300?random=3"),
            content: """
            A comprehensive 10-year study published in the New England Journal of Medicine has confirmed significant health benefits from following a Mediterranean diet. The research followed over 25,000 participants across 12 countries.
            
            Key findings include:
            - 30% reduction in cardiovascular events
            - 24% lower risk of developing type 2 diabetes
            - 15% reduction in overall mortality
            - Improved cognitive function in older adults
            
            "The evidence is now overwhelming," said Dr. Elena Papadakis, lead author. "This eating pattern rich in olive oil, nuts, fish, and vegetables provides benefits that no single supplement or medication can match."
            
            The study also found economic benefits, with Mediterranean diet followers spending 23% less on healthcare over the study period.
            """
        )
    ]
    
    // State for navigation to detail view
    @State private var selectedCard: NewsCard?
    
    // Computed property to filter cards based on selected topics
    var filteredCards: [NewsCard] {
        if selectedTopics.isEmpty {
            return newsCards
        } else {
            return newsCards.filter { card in
                !Set(card.topics).isDisjoint(with: selectedTopics)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Topic Filter Section
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(availableTopics, id: \.self) { topic in
                            Button(action: {
                                if selectedTopics.contains(topic) {
                                    selectedTopics.remove(topic)
                                } else {
                                    selectedTopics.insert(topic)
                                }
                            }) {
                                Text(topic)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        selectedTopics.contains(topic)
                                        ? Color.blue
                                        : Color(.systemGray5)
                                    )
                                    .foregroundColor(
                                        selectedTopics.contains(topic)
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
                
                // News Cards
                ScrollView {
                    LazyVStack(spacing: 20) {
                        ForEach(filteredCards) { card in
                            Button(action: {
                                selectedCard = card
                            }) {
                                NewsCardView(card: card)
                                    .padding(.horizontal)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.vertical)
                }
                .background(Color(.systemGroupedBackground))
            }
            .navigationTitle("Fragments")
            .background(Color(.systemGroupedBackground))
            // Navigation link to detail view
            .sheet(item: $selectedCard) { card in
                NewsDetailView(card: card)
            }
        }
    }
}

// add function to optionally hide the topics filter. by default , do not expand it.
struct NewsCardView: View {
    let card: NewsCard
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Background Image with overlay
            ZStack(alignment: .bottomLeading) {
                AsyncImage(url: card.imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(16/9, contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .foregroundColor(.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                                .font(.system(size: 30))
                        )
                }
                .frame(height: 250)
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
                    Text(card.date.formatted(.relative(presentation: .named)))
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
            VStack(alignment: .leading, spacing: 20) {
                // Header Image
                AsyncImage(url: card.imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(16/9, contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .foregroundColor(.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                                .font(.system(size: 30))
                        )
                }
                .frame(height: 250)
                .clipped()
                
                VStack(alignment: .leading, spacing: 16) {
                    // Title and Date
                    VStack(alignment: .leading, spacing: 8) {
                        Text(card.title)
                            .font(.custom("Charter", size: 28))
                            .fontWeight(.bold)
                        
                        HStack {
                            Text(card.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            // Topics/tags
                            HStack {
                                ForEach(card.topics, id: \.self) { topic in
                                    Text(topic)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.blue.opacity(0.2))
                                        .cornerRadius(4)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                    
                    // Content
                    Text(card.content)
                        .font(.custom("Charter", size: 18))
                        .lineSpacing(6)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal)
            }
            .padding(.bottom)
        }
        .navigationTitle("Article")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    // Share action would go here
                }) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.light)
        
        // Also preview the detail view
        NewsDetailView(card: NewsCard(
            title: "Sample News Article",
            date: Date(),
            topics: ["Tech", "AI"],
            imageURL: URL(string: "https://picsum.photos/400/300?random=4"),
            content: "This is a sample news article content that would appear in the detail view. It contains all the details and information about the news story that was summarized in the card view."
        ))
    }
}
