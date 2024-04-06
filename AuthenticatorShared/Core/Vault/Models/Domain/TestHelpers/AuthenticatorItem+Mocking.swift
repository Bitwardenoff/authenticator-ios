@testable import AuthenticatorShared

extension AuthenticatorItem {
    init(authenticatorItemView: AuthenticatorItemView) {
        self.init(
            id: authenticatorItemView.id,
            name: authenticatorItemView.name
        )
    }
}

extension AuthenticatorItemView {
    init(authenticatorItem: AuthenticatorItem) {
        self.init(
            id: authenticatorItem.id,
            name: authenticatorItem.name
        )
    }
}
