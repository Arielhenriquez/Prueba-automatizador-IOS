import Foundation

/// ViewModel de la pantalla de listado (MVVM).
@MainActor
final class ContactListViewModel: ObservableObject {
    @Published var contacts: [Contact] = []
    @Published var searchText: String = ""

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
        let toDelete = offsets.map { visible[$0] }
        contacts.removeAll { c in toDelete.contains(where: { $0.id == c.id }) }
        persist()
    }

    private func persist() {
        store.save(contacts)
    }
}