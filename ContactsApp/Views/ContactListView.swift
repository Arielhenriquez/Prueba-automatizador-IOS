import SwiftUI

/// Pantalla de listado de contactos.
struct ContactListView: View {
    @StateObject private var viewModel: ContactListViewModel
    private let imageService: ImageServiceProtocol

    @State private var isPresentingForm = false
    @State private var isDeleting = false

    init(viewModel: ContactListViewModel, imageService: ImageServiceProtocol) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.imageService = imageService
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchBar
                content
            }
            .navigationTitle("Contactos")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(isDeleting ? "Listo" : "Borrar") {
                        isDeleting.toggle()
                    }
                    .accessibilityIdentifier(A11y.ContactList.deleteModeButton)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Nuevo") { isPresentingForm = true }
                        .accessibilityIdentifier(A11y.ContactList.newButton)
                }
            }
            .sheet(isPresented: $isPresentingForm) {
                ContactFormView(
                    viewModel: ContactFormViewModel(imageService: imageService),
                    onSave: { contact in
                        viewModel.add(contact)
                        isPresentingForm = false
                    },
                    onCancel: { isPresentingForm = false }
                )
            }
        }
        .accessibilityIdentifier(A11y.ContactList.screen)
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField("Buscar por nombre, apellido o teléfono",
                      text: $viewModel.searchText)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
                .accessibilityIdentifier(A11y.ContactList.searchField)
        }
        .padding(10)
        .background(Color.gray.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
        .padding(.top, 8)
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.filteredContacts.isEmpty {
            VStack(spacing: 8) {
                Image(systemName: "person.crop.circle.badge.questionmark")
                    .font(.largeTitle)
                    .foregroundColor(.secondary)
                Text("Sin resultados")
                    .foregroundColor(.secondary)
                    .accessibilityIdentifier(A11y.ContactList.emptyState)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            List {
                ForEach(viewModel.filteredContacts) { contact in
                    ContactRow(
                        contact: contact,
                        isDeleting: isDeleting,
                        onDelete: { viewModel.delete(contact) }
                    )
                }
                .onDelete { viewModel.delete(at: $0) }
            }
            .listStyle(.plain)
            .accessibilityIdentifier(A11y.ContactList.list)
        }
    }
}

private struct ContactRow: View {
    let contact: Contact
    let isDeleting: Bool
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            if isDeleting {
                Button(action: onDelete) {
                    Image(systemName: "trash.circle.fill")
                        .font(.title2)
                        .foregroundColor(.red)
                }
                .buttonStyle(.borderless)
                .accessibilityIdentifier(A11y.ContactList.deleteButton(contact.a11ySlug))
            }

            AsyncImage(url: contact.imageURL) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .foregroundColor(.gray.opacity(0.4))
                }
            }
            .frame(width: 44, height: 44)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(contact.fullName)
                    .font(.headline)
                Text(contact.phone)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(A11y.ContactList.cell(contact.a11ySlug))
    }
}