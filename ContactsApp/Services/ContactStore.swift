import Foundation

/// Abstracción de persistencia. Permite inyectar implementaciones
/// reales (UserDefaults) o de prueba (en memoria) — Dependency Injection.
protocol ContactStoreProtocol {
    func load() -> [Contact]
    func save(_ contacts: [Contact])
}

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

    func save(_ contacts: [Contact]) {
        let data = try? JSONEncoder().encode(contacts)
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
    func save(_ contacts: [Contact]) { self.contacts = contacts }
}