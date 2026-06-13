import Foundation

/// Modelo de dominio que representa un contacto.
struct Contact: Identifiable, Codable, Equatable {
    let id: UUID
    var firstName: String
    var lastName: String
    var phone: String
    var imageURL: URL?

    init(id: UUID = UUID(),
         firstName: String,
         lastName: String,
         phone: String,
         imageURL: URL? = nil) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.phone = phone
        self.imageURL = imageURL
    }

    var fullName: String { "\(firstName) \(lastName)" }

    /// Identificador estable para automatización de UI (sin espacios).
    var a11ySlug: String { fullName.replacingOccurrences(of: " ", with: "_") }

    /// Búsqueda por cualquier campo: nombre, apellido o teléfono.
    func matches(query: String) -> Bool {
        guard !query.isEmpty else { return true }
        let q = query.lowercased()
        return firstName.lowercased().contains(q)
            || lastName.lowercased().contains(q)
            || phone.lowercased().contains(q)
            || fullName.lowercased().contains(q)
    }
}