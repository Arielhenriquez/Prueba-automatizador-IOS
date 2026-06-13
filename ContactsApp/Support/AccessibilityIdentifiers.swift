import Foundation


enum A11y {
    enum ContactList {
        static let screen = "contactList.screen"
        static let newButton = "contactList.newButton"
        static let deleteModeButton = "contactList.deleteModeButton"
        static let searchField = "contactList.searchField"
        static let emptyState = "contactList.emptyState"
        static let list = "contactList.list"

        static func cell(_ slug: String) -> String { "contactList.cell.\(slug)" }
        static func deleteButton(_ slug: String) -> String { "contactList.delete.\(slug)" }
    }

    enum ContactForm {
        static let screen = "contactForm.screen"
        static let cancelButton = "contactForm.cancelButton"
        static let image = "contactForm.image"
        static let randomImageButton = "contactForm.randomImageButton"
        static let firstNameField = "contactForm.firstNameField"
        static let lastNameField = "contactForm.lastNameField"
        static let phoneField = "contactForm.phoneField"
        static let saveButton = "contactForm.saveButton"
        static let errorLabel = "contactForm.errorLabel"
    }
}