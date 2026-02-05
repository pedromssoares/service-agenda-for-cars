import SwiftUI

struct PhotoViewer: View {
    let photos: [Data]
    @State private var currentIndex: Int
    @Environment(\.dismiss) private var dismiss

    init(photos: [Data], startingAt index: Int = 0) {
        self.photos = photos
        _currentIndex = State(initialValue: index)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                TabView(selection: $currentIndex) {
                    ForEach(Array(photos.enumerated()), id: \.offset) { index, photoData in
                        if let uiImage = UIImage(data: photoData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .tag(index)
                        }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("\(currentIndex + 1) of \(photos.count)")
                        .foregroundStyle(.white)
                        .font(.headline)
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.white)
                    }
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(.black.opacity(0.8), for: .navigationBar)
        }
    }
}

#Preview {
    PhotoViewer(photos: [])
}
