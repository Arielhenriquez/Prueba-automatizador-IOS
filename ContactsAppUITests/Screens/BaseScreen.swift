import XCTest

/// Clase base de todos los Screen Objects (Page Object pattern).
/// Centraliza el acceso a XCUIApplication y las esperas robustas,
/// evitando sleeps fijos y selectores duplicados en los tests.
class BaseScreen {
    let app: XCUIApplication
    let defaultTimeout: TimeInterval = 5

    init(app: XCUIApplication) {
        self.app = app
    }

    /// Espera explícita: falla el test con mensaje claro si el elemento no aparece.
    @discardableResult
    func waitFor(_ element: XCUIElement,
                 timeout: TimeInterval? = nil,
                 file: StaticString = #filePath,
                 line: UInt = #line) -> XCUIElement {
        let exists = element.waitForExistence(timeout: timeout ?? defaultTimeout)
        XCTAssertTrue(exists,
                      "El elemento esperado no apareció a tiempo: \(element)",
                      file: file, line: line)
        return element
    }

    /// Convierte "Juan Perez" → "Juan_Perez" (mismo slug que usa la app).
    func slug(_ fullName: String) -> String {
        fullName.replacingOccurrences(of: " ", with: "_")
    }
}
