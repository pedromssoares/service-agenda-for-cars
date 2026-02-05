import SwiftUI
import PhotosUI

struct PhotoPicker: View {
    @Binding var photos: [Data]
    let maxPhotos: Int = 5

    @State private var selectedItems: [PhotosPickerItem] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Photos")
                    .font(.headline)
                Spacer()
                Text("\(photos.count)/\(maxPhotos)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if !photos.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(photos.enumerated()), id: \.offset) { index, photoData in
                            if let uiImage = UIImage(data: photoData) {
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))

                                    Button {
                                        removePhoto(at: index)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.title3)
                                            .foregroundStyle(.white)
                                            .background(Circle().fill(.black.opacity(0.6)))
                                    }
                                    .padding(4)
                                }
                            }
                        }

                        if photos.count < maxPhotos {
                            PhotosPickerButton(selectedItems: $selectedItems)
                        }
                    }
                }
            } else {
                PhotosPickerButton(selectedItems: $selectedItems)
            }
        }
        .onChange(of: selectedItems) { _, newItems in
            loadPhotos(from: newItems)
        }
    }

    private func removePhoto(at index: Int) {
        photos.remove(at: index)
    }

    private func loadPhotos(from items: [PhotosPickerItem]) {
        Task {
            for item in items {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    // Compress image
                    if let uiImage = UIImage(data: data),
                       let compressed = uiImage.jpegData(compressionQuality: 0.7) {
                        await MainActor.run {
                            if photos.count < maxPhotos {
                                photos.append(compressed)
                            }
                        }
                    }
                }
            }

            // Clear selection
            await MainActor.run {
                selectedItems = []
            }
        }
    }
}

struct PhotosPickerButton: View {
    @Binding var selectedItems: [PhotosPickerItem]

    var body: some View {
        PhotosPicker(selection: $selectedItems, maxSelectionCount: 5, matching: .images) {
            VStack {
                Image(systemName: "photo.badge.plus")
                    .font(.largeTitle)
                    .foregroundStyle(.blue)
                Text("Add Photos")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 80, height: 80)
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var photos: [Data] = []

        var body: some View {
            Form {
                Section {
                    PhotoPicker(photos: $photos)
                }
            }
        }
    }

    return PreviewWrapper()
}
