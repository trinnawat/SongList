import SwiftUI


struct Results: Codable {
    let results: [Result]
}

struct Result: Codable {
    var trackId: Int
    var trackName: String
    var collectionName: String
}

enum NetworkError: Error {
    case badUrl
    case invalidRequest
    case badResponse
    case badStatus
    case failedToDecodeResponse
}

struct SongList: View {
    @State private var songs = [Result]()
    @State private var isLoadingData = false
    
    func loadData() async {
        let urlString = "https://itunes.apple.com/search?term=taylor+swift&entity=song"
        guard let url = URL(string: urlString) else {
            print("Invalid URL \(urlString)")
            return
        }
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let response = response as? HTTPURLResponse else { throw NetworkError.badResponse }
            print(response.statusCode)
            guard let decodedResponse = try? JSONDecoder().decode(Results.self, from: data) else { throw NetworkError.failedToDecodeResponse }
            songs = decodedResponse.results
            isLoadingData = false
        } catch(let error) {
            print("Cannot load data: \(error)")
        }
        
    }
    
    var body: some View {
        HStack {
            Button("Load Songs") {
                Task {
                    isLoadingData = true
                    await loadData()
                }
            }
            Spacer()
            Button("Clear Songs") {
                songs = []
            }
        }
        .padding(16)
        Spacer()
        if isLoadingData {
            Text("Loading Data...")
        } else {
            List(songs, id: \.trackId) { song in
                HStack {
                    Image(systemName: "star.fill")
                    Text("\(song.trackName) by \(song.collectionName)")
                }
            }
        }
    }
}



#Preview {
    SongList()
}
