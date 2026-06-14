import SwiftUI

@main
struct ContactsAppApp: App {
    private let store: ContactStoreProtocol
    private let imageService: ImageServiceProtocol

    init() {
        let args = ProcessInfo.processInfo.arguments
        let store = UserDefaultsContactStore()

        if args.contains("--uitesting-reset") {
            store.save([])
        }
        if args.contains("--uitesting-seed") {
            store.save(Self.seedContacts)
        }

        self.store = store
        self.imageService = PicsumImageService()
    }

    var body: some Scene {
        WindowGroup {
            ContactListView(
                viewModel: ContactListViewModel(store: store),
                imageService: imageService
            )
        }
    }

    /// Datos de prueba conocidos por la suite de UI tests.
    static let seedContacts: [Contact] = [
        Contact(firstName: "Juan",  lastName: "Perez",    phone: "8095551234"),
        Contact(firstName: "Maria", lastName: "Garcia",   phone: "8295555678"),
        Contact(firstName: "Pedro", lastName: "Martinez", phone: "8495559012")
    ]
}