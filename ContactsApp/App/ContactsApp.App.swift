import SwiftUI

@main
struct ContactsAppApp: App {
    private let store: ContactStoreProtocol
    private let imageService: ImageServiceProtocol

    init() {
        let args = ProcessInfo.processInfo.arguments
        let isUITesting = args.contains("--uitesting-reset")
                       || args.contains("--uitesting-seed")
                       || args.contains("--uitesting")

        // UI tests usan un suite aislado para no tocar los datos reales del usuario.
        let defaults = isUITesting
            ? (UserDefaults(suiteName: "app.uitesting") ?? .standard)
            : .standard
        let store = UserDefaultsContactStore(defaults: defaults)

        // Hooks para automatización de UI (estado determinista):
        // --uitesting-reset  → arranca sin datos
        // --uitesting-seed   → arranca con contactos conocidos
        if args.contains("--uitesting-reset") {
            try? store.save([])
        }
        if args.contains("--uitesting-seed") {
            try? store.save(Self.seedContacts)
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
