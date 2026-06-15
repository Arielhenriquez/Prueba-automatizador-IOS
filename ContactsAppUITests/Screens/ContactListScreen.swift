import XCTest

/// Screen Object de la pantalla de listado de contactos.
final class ContactListScreen: BaseScreen {

    // MARK: - Elementos

    var newButton: XCUIElement { app.buttons[A11y.ContactList.newButton] }
    var deleteModeButton: XCUIElement { app.buttons[A11y.ContactList.deleteModeButton] }
    var searchField: XCUIElement { app.textFields[A11y.ContactList.searchField] }
    var emptyState: XCUIElement { app.staticTexts[A11y.ContactList.emptyState] }

    /// Celda de un contacto. Se busca por identifier en cualquier tipo de
    /// elemento para no acoplarse a la representación interna de SwiftUI List.
    func cell(for fullName: String) -> XCUIElement {
        app.descendants(matching: .any)[A11y.ContactList.cell(slug(fullName))].firstMatch
    }

    func deleteButton(for fullName: String) -> XCUIElement {
        app.buttons[A11y.ContactList.deleteButton(slug(fullName))]
    }

    // MARK: - Acciones

    @discardableResult
    func tapNew() -> ContactFormScreen {
        waitFor(newButton).tap()
        return ContactFormScreen(app: app)
    }

    func search(_ text: String) {
        let field = waitFor(searchField)
        field.tap()
        field.typeText(text)
    }

    /// Borra el texto actual del campo de búsqueda.
    func clearSearch() {
        let field = waitFor(searchField)
        guard let current = field.value as? String, !current.isEmpty else { return }
        field.tap()
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: current.count)
        field.typeText(deleteString)
    }

    /// Activa el modo borrado ("Borrar" → estado con botones de papelera visibles).
    func enterDeleteMode() {
        waitFor(deleteModeButton).tap()
    }

    /// Desactiva el modo borrado ("Listo" → estado normal).
    func exitDeleteMode() {
        waitFor(deleteModeButton).tap()
    }

    /// Flujo completo de borrado: activa el modo y toca el botón de la fila.
    func deleteContact(named fullName: String) {
        enterDeleteMode()
        waitFor(deleteButton(for: fullName)).tap()
    }

    // MARK: - Consultas para assertions

    func isShowingContact(_ fullName: String,
                          timeout: TimeInterval? = nil) -> Bool {
        cell(for: fullName).waitForExistence(timeout: timeout ?? defaultTimeout)
    }

    func isShowingEmptyState(timeout: TimeInterval? = nil) -> Bool {
        emptyState.waitForExistence(timeout: timeout ?? defaultTimeout)
    }
}
