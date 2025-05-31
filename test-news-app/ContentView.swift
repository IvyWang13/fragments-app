import SwiftUI

struct ContentView: View {
    // Available topics for filtering
    let availableTopics = ["AI", "Tech", "Finance", "China"]
    @StateObject private var viewModel = NewsViewModel()
    @State private var selectedCard: NewsCard?
       
       var filteredCards: [NewsCard] {
           if viewModel.selectedTopics.isEmpty {
               return viewModel.newsCards
           } else {
               return viewModel.newsCards.filter { card in
                   !Set(card.topics).isDisjoint(with: viewModel.selectedTopics)
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
                                if viewModel.selectedTopics.contains(topic) {
                                    viewModel.selectedTopics.remove(topic)
                                } else {
                                    viewModel.selectedTopics.insert(topic)
                                }
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
                            .onAppear {
                                    // Load more content when reaching the end
                                    if card.id == filteredCards.last?.id {
                                            Task {
                                                await viewModel.loadMoreNews()
                                            }
                                    }
                            }
                        }
                        if viewModel.isLoading {
                                    ProgressView()
                                .padding()
                        }
                    }
                    .padding(.vertical)
                }
                .background(Color(.systemGroupedBackground))
                .refreshable {
                    await viewModel.loadInitialData()
                }
            }
            .navigationTitle("Fragments")
            .background(Color(.systemGroupedBackground))
            // Navigation link to detail view
            .sheet(item: $selectedCard) { card in
                NewsDetailView(card: card)
            }
            .alert("Error", isPresented: .constant(viewModel.error != nil)) {
                           Button("OK") {
                               viewModel.error = nil
                           }
                       } message: {
                           Text(viewModel.error ?? "")
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
                AsyncImage(url: URL(string: card.imageUrl ?? "")) { image in
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
                     Text(formatRelativeDate(card.date))
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
                AsyncImage(url: URL(string: card.imageUrl ?? "")) { image in
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
                            // Formatted date
                             Text(formatRelativeDate(card.date))
                                 .font(.caption)
                                 .foregroundColor(.white)
                            
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
                    Text(card.content ?? "")
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

// 辅助函数来格式化日期
private func formatRelativeDate(_ dateString: String) -> String {
     let formatter = ISO8601DateFormatter()
     if let date = formatter.date(from: dateString) {
         let calendar = Calendar.current
         let now = Date()
         
         // 如果是今天
         if calendar.isDateInToday(date) {
             let diff = calendar.dateComponents([.hour, .minute], from: date, to: now)
             if let hours = diff.hour, hours > 0 {
                 return "\(hours)h ago"
             } else if let minutes = diff.minute {
                 return "\(max(minutes, 1))m ago"
             }
         }
         
         // 如果是昨天
         if calendar.isDateInYesterday(date) {
             return "Yesterday"
         }
         
         // 如果是本周
         let weekDiff = calendar.dateComponents([.weekOfYear], from: date, to: now)
         if weekDiff.weekOfYear == 0 {
             let dateFormatter = DateFormatter()
             dateFormatter.dateFormat = "EEEE" // Full day name
             return dateFormatter.string(from: date)
         }
         
         // 其他情况
         let dateFormatter = DateFormatter()
         dateFormatter.dateStyle = .medium
         dateFormatter.timeStyle = .none
         return dateFormatter.string(from: date)
     }
     return dateString // 如果解析失败，返回原始字符串
 }
