import Foundation
import SwiftData

@Model
final class ServiceEvent {
    var id: UUID
    var date: Date
    var odometerKm: Double
    var cost: Double?
    var notes: String?

    // Store photos as Data (JPEG compressed)
    var photoData1: Data?
    var photoData2: Data?
    var photoData3: Data?
    var photoData4: Data?
    var photoData5: Data?

    var vehicle: Vehicle?
    var serviceType: ServiceTypeTemplate?

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        odometerKm: Double,
        cost: Double? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.date = date
        self.odometerKm = odometerKm
        self.cost = cost
        self.notes = notes
    }

    // Helper computed property to get all photos
    var photos: [Data] {
        [photoData1, photoData2, photoData3, photoData4, photoData5].compactMap { $0 }
    }

    // Helper to set photos (max 5)
    func setPhotos(_ photos: [Data]) {
        let limited = Array(photos.prefix(5))
        photoData1 = limited.count > 0 ? limited[0] : nil
        photoData2 = limited.count > 1 ? limited[1] : nil
        photoData3 = limited.count > 2 ? limited[2] : nil
        photoData4 = limited.count > 3 ? limited[3] : nil
        photoData5 = limited.count > 4 ? limited[4] : nil
    }
}
