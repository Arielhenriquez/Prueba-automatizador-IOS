import Foundation

/// ViewModel del formulario de creación (MVVM).
/// Encapsula validación y construcción del contacto — testeable sin UI.
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

    /// Teléfono válido: 7–15 dígitos reales, opcionalmente separados por espacios/guiones y con "+" inicial.
    static func isValidPhone(_ value: String) -> Bool {
        let digits = value.filter { $0.isNumber }
        guard digits.count >= 7, digits.count <= 15 else { return false }
        return value.range(of: Self.phonePattern, options: .regularExpression) != nil
    }

    private static let phonePattern = #"^\+?[0-9][0-9\s-]{6,14}$"#
}
