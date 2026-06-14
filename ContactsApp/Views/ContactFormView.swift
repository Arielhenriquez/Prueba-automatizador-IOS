import SwiftUI

/// Pantalla de creación de contacto.
struct ContactFormView: View {
    @StateObject private var viewModel: ContactFormViewModel
    let onSave: (Contact) -> Void
    let onCancel: () -> Void

    init(viewModel: ContactFormViewModel,
         onSave: @escaping (Contact) -> Void,
         onCancel: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onSave = onSave
        self.onCancel = onCancel
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(spacing: 12) {
                        AsyncImage(url: viewModel.imageURL) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable().scaledToFill()
                            case .failure:
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .padding(30)
                                    .foregroundColor(.secondary)
                            default:
                                ProgressView()
                            }
                        }
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .accessibilityIdentifier(A11y.ContactForm.image)

                        Button("Cargar imagen aleatoria") {
                            viewModel.loadRandomImage()
                        }
                        .accessibilityIdentifier(A11y.ContactForm.randomImageButton)
                    }
                    .frame(maxWidth: .infinity)
                }

                Section("Datos del contacto") {
                    TextField("Nombre", text: $viewModel.firstName)
                        .accessibilityIdentifier(A11y.ContactForm.firstNameField)
                    TextField("Apellido", text: $viewModel.lastName)
                        .accessibilityIdentifier(A11y.ContactForm.lastNameField)
                    TextField("Teléfono", text: $viewModel.phone)
                        .keyboardType(.phonePad)
                        .accessibilityIdentifier(A11y.ContactForm.phoneField)
                }

                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                            .accessibilityIdentifier(A11y.ContactForm.errorLabel)
                    }
                }

                Section {
                    Button("Guardar") {
                        if let contact = viewModel.validateAndBuildContact() {
                            onSave(contact)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .accessibilityIdentifier(A11y.ContactForm.saveButton)
                }
            }
            .navigationTitle("Nuevo contacto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar", action: onCancel)
                        .accessibilityIdentifier(A11y.ContactForm.cancelButton)
                }
            }
        }
        .accessibilityIdentifier(A11y.ContactForm.screen)
        .interactiveDismissDisabled()
    }
}