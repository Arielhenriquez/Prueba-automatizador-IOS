import XCTest

/// Screen Object de la pantalla de creación de contacto.
final class ContactFormScreen: BaseScreen {

    // MARK: - Elementos

    var cancelButton: XCUIElement { app.buttons[A11y.ContactForm.cancelButton] }
    var saveButton: XCUIElement { app.buttons[A11y.ContactForm.saveButton] }
    var randomImageButton: XCUIElement { app.buttons[A11y.ContactForm.randomImageButton] }
    var firstNameField: XCUIElement { app.textFields[A11y.ContactForm.firstNameField] }
    var lastNameField: XCUIElement { app.textFields[A11y.ContactForm.lastNameField] }
    var phoneField: XCUIElement { app.textFields[A11y.ContactForm.phoneField] }
    var errorLabel: XCUIElement { app.staticTexts[A11y.ContactForm.errorLabel] }

    var image: XCUIElement {
        app.descendants(matching: .any)[A11y.ContactForm.image].firstMatch
    }

    // MARK: - Acciones

    func type(firstName: String) {
        let field = waitFor(firstNameField)
        field.tap()
        field.typeText(firstName)
    }

    func type(lastName: String) {
        let field = waitFor(lastNameField)
        field.tap()
        field.typeText(lastName)
    }

    func type(phone: String) {
        let field = waitFor(phoneField)
        field.tap()
        field.typeText(phone)
    }

    func fill(firstName: String, lastName: String, phone: String) {
        type(firstName: firstName)
        type(lastName: lastName)
        type(phone: phone)
    }

    @discardableResult
    func tapSave() -> Self {
        waitFor(saveButton).tap()
        return self
    }

    func tapCancel() {
        waitFor(cancelButton).tap()
    }

    func tapRandomImage() {
        waitFor(randomImageButton).tap()
    }

    // MARK: - Consultas

    /// Texto de error visible (o nil si no aparece).
    func errorText(timeout: TimeInterval? = nil) -> String? {
        guard errorLabel.waitForExistence(timeout: timeout ?? defaultTimeout) else {
            return nil
        }
        return errorLabel.label
    }
}
