import Foundation

/// ViewModel de la pantalla de listado (MVVM).
/// Contiene la lógica de filtrado, alta y borrado — sin dependencias de UI.
@MainActor
final class ContactListViewModel: ObservableObject {
    @Published var contacts: [Contact] = []
    @Published var searchText: String = ""
    @Published var saveError: String?

    private let store: ContactStoreProtocol

    init(store: ContactStoreProtocol) {
        self.store = store
        self.contacts = store.load()
    }

    /// Lista visible según el texto de búsqueda (nombre, apellido o teléfono).
    var filteredContacts: [Contact] {
        let query = searchText.trimmingCharacters(in: .whitespaces)
        return contacts.filter { $0.matches(query: query) }
    }

    func add(_ contact: Contact) {
        contacts.append(contact)
        persist()
    }

    func delete(_ contact: Contact) {
        contacts.removeAll { $0.id == contact.id }
        persist()
    }

    /// Soporta swipe-to-delete sobre la lista filtrada.
    func delete(at offsets: IndexSet) {
        let visible = filteredContacts
        let toDelete = Set(offsets.map { visible[$0].id })
        contacts.removeAll { toDelete.contains($0.id) }
        persist()
    }

    private func persist() {
        do {
            try store.save(contacts)
        } catch {
            saveError = "No se pudieron guardar los cambios. Intenta nuevamente."
        }
    }
}
