import Foundation

/// ViewModel del formulario de creación (MVVM).
@MainActor
final class ContactFormViewModel: ObservableObject {
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var phone = ""
    @Published var imageURL: URL?
    @Published var errorMessage: String?

    private let imageService: ImageServiceProtocol

    init(imageService: ImageServiceProtocol) {
        self.imageService = imageService
        self.imageURL = imageService.randomImageURL()
    }

    func loadRandomImage() {
        imageURL = imageService.randomImageURL()
    }

    /// Valida los campos. Devuelve el contacto si todo es correcto;
    /// si no, publica el mensaje de error correspondiente.
    func validateAndBuildContact() -> Contact? {
        errorMessage = nil
        let first = firstName.trimmingCharacters(in: .whitespaces)
        let last = lastName.trimmingCharacters(in: .whitespaces)
        let phoneValue = phone.trimmingCharacters(in: .whitespaces)

        guard !first.isEmpty else {
            errorMessage = "El nombre es obligatorio."
            return nil
        }
        guard !last.isEmpty else {
            errorMessage = "El apellido es obligatorio."
            return nil
        }
        guard !phoneValue.isEmpty else {
            errorMessage = "El teléfono es obligatorio."
            return nil
        }
        guard Self.isValidPhone(phoneValue) else {
            errorMessage = "El teléfono no es válido."
            return nil
        }

        return Contact(firstName: first,
                       lastName: last,
                       phone: phoneValue,
                       imageURL: imageURL)
    }

    /// Teléfono válido: opcional "+", inicia con dígito, 7–15 caracteres
    /// permitiendo dígitos, espacios y guiones.
    static func isValidPhone(_ value: String) -> Bool {
        let pattern = #"^\+?[0-9][0-9\s-]{6,14}$"#
        return value.range(of: pattern, options: .regularExpression) != nil
    }
}