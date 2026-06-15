import Foundation

/// ISP — contrato de solo lectura. Permite inyectar vistas de consulta sin exponer escritura.
protocol ContactReader {
    func load() -> [Contact]
}

/// ISP — contrato de solo escritura. Permite inyectar escritores sin exponer carga.
protocol ContactWriter {
    func save(_ contacts: [Contact]) throws
}

/// Combinación de ambos protocolos para el caso de uso completo (DI en ViewModels).
typealias ContactStoreProtocol = ContactReader & ContactWriter

/// Persistencia local simple usando UserDefaults + JSON.
final class UserDefaultsContactStore: ContactStoreProtocol {
    private let key = "contacts_storage_v1"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> [Contact] {
        guard let data = defaults.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([Contact].self, from: data)) ?? []
    }

    func save(_ contacts: [Contact]) throws {
        let data = try JSONEncoder().encode(contacts)
        defaults.set(data, forKey: key)
    }
}

/// Implementación en memoria para pruebas unitarias (mock).
final class InMemoryContactStore: ContactStoreProtocol {
    private var contacts: [Contact]

    init(initial: [Contact] = []) {
        self.contacts = initial
    }

    func load() -> [Contact] { contacts }
    func save(_ contacts: [Contact]) throws { self.contacts = contacts }
}
