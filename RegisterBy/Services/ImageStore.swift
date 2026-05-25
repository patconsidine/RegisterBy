import UIKit

enum ImageStore {
    private static var directory: URL {
        let base = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dir = base.appendingPathComponent("ProductImages", isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    static func save(_ image: UIImage, for productID: UUID, kind: String) -> String? {
        let filename = "\(productID.uuidString)-\(kind).jpg"
        let url = directory.appendingPathComponent(filename)
        guard let data = image.jpegData(compressionQuality: 0.85) else { return nil }
        do {
            try data.write(to: url)
            return filename
        } catch {
            return nil
        }
    }

    static func load(filename: String?) -> UIImage? {
        guard let filename else { return nil }
        let url = directory.appendingPathComponent(filename)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    static func delete(filename: String?) {
        guard let filename else { return }
        let url = directory.appendingPathComponent(filename)
        try? FileManager.default.removeItem(at: url)
    }
}
