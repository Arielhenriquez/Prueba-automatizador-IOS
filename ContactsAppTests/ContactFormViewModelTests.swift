import XCTest
@testable import ContactsApp

/// Mock del servicio de imágenes — retorna URLs únicas por llamada para verificar cambios.
private final class MockImageService: ImageServiceProtocol {
    private var callCount = 0
    func randomImageURL() -> URL {
        callCount += 1
        return URL(string: "https://example.com/test-\(callCount).jpg")!
    }
}

final class ContactFormViewModelTests: XCTestCase {
    @MainActor
    private func makeSUT() -> ContactFormViewModel {
        ContactFormViewModel(imageService: MockImageService())
    }

    // MARK: - Casos negativos

    @MainActor
    func test_camposVacios_devuelveNilYError() {
        let sut = makeSUT()
        let contact = sut.validateAndBuildContact()
        XCTAssertNil(contact)
        XCTAssertEqual(sut.errorMessage, "El nombre es obligatorio.")
    }

    @MainActor
    func test_apellidoVacio_devuelveError() {
        let sut = makeSUT()
        sut.firstName = "Ana"
        XCTAssertNil(sut.validateAndBuildContact())
        XCTAssertEqual(sut.errorMessage, "El apellido es obligatorio.")
    }

    @MainActor
    func test_telefonoVacio_devuelveError() {
        let sut = makeSUT()
        sut.firstName = "Ana"
        sut.lastName = "Lopez"
        XCTAssertNil(sut.validateAndBuildContact())
        XCTAssertEqual(sut.errorMessage, "El teléfono es obligatorio.")
    }

    @MainActor
    func test_telefonoInvalido_devuelveError() {
        let sut = makeSUT()
        sut.firstName = "Ana"
        sut.lastName = "Lopez"
        sut.phone = "123"
        XCTAssertNil(sut.validateAndBuildContact())
        XCTAssertEqual(sut.errorMessage, "El teléfono no es válido.")
    }

    // MARK: - Caso exitoso

    @MainActor
    func test_datosValidos_construyeContacto() {
        let sut = makeSUT()
        sut.firstName = "  Ana "
        sut.lastName = "Lopez"
        sut.phone = "8095550001"
        let contact = sut.validateAndBuildContact()
        XCTAssertNotNil(contact)
        XCTAssertNil(sut.errorMessage)
        XCTAssertEqual(contact?.firstName, "Ana") // valida trimming
        XCTAssertEqual(contact?.fullName, "Ana Lopez")
    }

    // MARK: - Validación de teléfono (tabla de casos)

    @MainActor
    func test_validacionDeTelefono_casosValidosEInvalidos() {
        XCTAssertTrue(ContactFormViewModel.isValidPhone("8095551234"))
        XCTAssertTrue(ContactFormViewModel.isValidPhone("+1 809-555-1234"))
        XCTAssertTrue(ContactFormViewModel.isValidPhone("809 555 1234"))
        XCTAssertFalse(ContactFormViewModel.isValidPhone("123"))
        XCTAssertFalse(ContactFormViewModel.isValidPhone("abcdefgh"))
        XCTAssertFalse(ContactFormViewModel.isValidPhone(""))
        XCTAssertFalse(ContactFormViewModel.isValidPhone("1------"))
    }

    // MARK: - Imagen aleatoria

    @MainActor
    func test_loadRandomImage_actualizaURL() {
        let sut = makeSUT()
        let initialURL = sut.imageURL
        XCTAssertNotNil(initialURL)
        sut.loadRandomImage()
        XCTAssertNotNil(sut.imageURL)
        XCTAssertNotEqual(sut.imageURL, initialURL, "loadRandomImage debe actualizar imageURL a una URL distinta")
    }
}
