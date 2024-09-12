import SwiftUI

struct RSSSourceView: View {
    @StateObject private var viewModel = RSSSourceViewModel()
    @State private var showingClearCacheAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.black, Color(#colorLiteral(red: 0.2, green: 0, blue: 0, alpha: 1))]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 25) {
                        Text("ImusiCast")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.top, 30)
                        
                        VStack(spacing: 15) {
                            TextField("Enter RSS URL", text: $viewModel.url)
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.red.opacity(0.5), lineWidth: 1))
                                .foregroundColor(.white)
                            
                            Button(action: {
                                viewModel.loadPodcast()
                            }) {
                                Text("Load Podcast")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(LinearGradient(gradient: Gradient(colors: [Color.red, Color(#colorLiteral(red: 0.8, green: 0, blue: 0, alpha: 1))]), startPoint: .leading, endPoint: .trailing))
                                    .cornerRadius(10)
                            }
                            .disabled(viewModel.url.isEmpty)
                        }
                        .padding(.horizontal)
                        
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .red))
                                .scaleEffect(1.5)
                        } else if let podcast = viewModel.podcast {
                            podcastInfoView(podcast: podcast)
                        } else if let error = viewModel.error {
                            Text("Error: \(error.localizedDescription)")
                                .foregroundColor(.red)
                                .padding()
                        }
                        
                        Button(action: {
                            showingClearCacheAlert = true
                        }) {
                            Text("Clear Cache")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.3))
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        
                        if !viewModel.urlHistory.isEmpty {
                            recentURLsView
                        }
                    }
                    .padding()
                }
            }
            .alert(isPresented: $showingClearCacheAlert) {
                Alert(
                    title: Text("Clear Cache"),
                    message: Text("Are you sure you want to clear the cache?"),
                    primaryButton: .destructive(Text("Clear")) {
                        viewModel.clearCache()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .preferredColorScheme(.dark)
    }
    
    private func podcastInfoView(podcast: Podcast) -> some View {
        VStack(spacing: 15) {
            Text("Loaded: \(podcast.title)")
                .font(.headline)
                .foregroundColor(.white)
            Text(viewModel.cacheStatus)
                .font(.caption)
                .foregroundColor(.gray)
            NavigationLink(destination: PodcastDetailView(viewModel: PodcastDetailViewModel(podcast: podcast))) {
                Text("View Podcast Details")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(LinearGradient(gradient: Gradient(colors: [Color.red, Color(#colorLiteral(red: 0.8, green: 0, blue: 0, alpha: 1))]), startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(15)
        .padding(.horizontal)
    }
    
    private var recentURLsView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Recent RSS URLs")
                .font(.headline)
                .foregroundColor(.white)
            
            ForEach(viewModel.urlHistory, id: \.self) { url in
                Button(action: {
                    viewModel.url = url
                    viewModel.loadPodcast()
                }) {
                    HStack {
                        Image(systemName: "link")
                            .foregroundColor(.red)
                        Text(url)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(15)
        .padding(.horizontal)
    }
}
