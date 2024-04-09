import BitwardenSdk
import Foundation

// MARK: - TokenState

/// An object that defines the current state of any view interacting with an authenticator item.
///
struct AuthenticatorItemState: Equatable {
    // MARK: Types

    /// An enum defining if the state is a new or existing token.
    enum Configuration: Equatable {
        /// We are creating a new token.
        case add

        /// We are viewing or editing an existing token.
        case existing(authenticatorItemView: AuthenticatorItemView)

        /// The existing `AuthenticatorItemView` if the configuration is `existing`.
        var existingToken: AuthenticatorItemView? {
            guard case let .existing(authenticatorItemView) = self else { return nil }
            return authenticatorItemView
        }
    }

    // MARK: Properties

    /// The account of the token
    var account: String

    /// The Add or Existing Configuration.
    let configuration: Configuration

    /// A flag indicating if the key field is visible
    var isKeyVisible: Bool = false

    /// The issuer of the token
    var issuer: String

    /// The name of this item.
    var name: String

    /// A toast for views
    var toast: Toast?

    /// The TOTP key/code state.
    var totpState: LoginTOTPState

    // MARK: Initialization

    init(
        configuration: Configuration,
        name: String,
        totpState: LoginTOTPState
    ) {
        self.configuration = configuration
        self.name = name
        self.totpState = totpState
        account = "Fixme"
        issuer = "Fixme"
    }

    init?(existing authenticatorItemView: AuthenticatorItemView) {
        self.init(
            configuration: .existing(authenticatorItemView: authenticatorItemView),
            name: authenticatorItemView.name,
            totpState: LoginTOTPState(authenticatorItemView.totpKey)
        )
    }
}

extension AuthenticatorItemState: EditAuthenticatorItemState {
    var editState: EditAuthenticatorItemState {
        self
    }
}

extension AuthenticatorItemState: ViewAuthenticatorItemState {
    var authenticatorKey: String? {
        totpState.rawAuthenticatorKeyString
    }

    var authenticatorItemView: AuthenticatorItemView {
        switch configuration {
        case let .existing(authenticatorItemView):
            return authenticatorItemView
        case .add:
            return newAuthenticatorItemView()
        }
    }

    var totpCode: TOTPCodeModel? {
        totpState.codeModel
    }
}

extension AuthenticatorItemState {
    /// Returns a `Token` based on the properties of the `AuthenticatorItemState`.
    ///
    func newAuthenticatorItemView() -> AuthenticatorItemView {
        AuthenticatorItemView(
            id: UUID().uuidString,
            name: name,
            totpKey: totpState.rawAuthenticatorKeyString
        )
    }
}
