import Foundation

/// Abstracción del proveedor de imágenes — permite mockear en tests.
protocol ImageServiceProtocol {
    func randomImageURL() -> URL
}

/// Implementación real usando la API pública Lorem Picsum.
/// https://picsum.photos — no requiere API key.
struct PicsumImageService: ImageServiceProtocol {
    func randomImageURL() -> URL {
        let seed = UUID().uuidString
        return URL(string: "https://picsum.photos/seed/\(seed)/300/300")!
    }
}