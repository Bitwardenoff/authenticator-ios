import BitwardenSdk
import Foundation

/// The processor used to manage state and handle actions/effects for the edit token screen
final class EditAuthenticatorItemProcessor: StateProcessor<
    EditAuthenticatorItemState,
    EditAuthenticatorItemAction,
    EditAuthenticatorItemEffect
> {
    // MARK: Types

    typealias Services = HasAuthenticatorItemRepository
        & HasErrorReporter

    // MARK: Properties

    /// The `Coordinator` that handles navigation.
    private var coordinator: AnyCoordinator<AuthenticatorItemRoute, TokenEvent>

    /// The services required by this processor.
    private let services: Services

    // MARK: Initialization

    /// Creates a new `EditAuthenticatorItemProcessor`.
    ///
    /// - Parameters:
    ///   - coordinator: The `Coordinator` that handles navigation.
    ///   - services: The services required by this processor.
    ///   - state: The initial state for the processor.
    ///
    init(
        coordinator: AnyCoordinator<AuthenticatorItemRoute, TokenEvent>,
        services: Services,
        state: EditAuthenticatorItemState
    ) {
        self.coordinator = coordinator
        self.services = services

        super.init(state: state)
    }

    // MARK: Methods

    override func perform(_ effect: EditAuthenticatorItemEffect) async {
        switch effect {
        case .appeared:
            break
        case .savePressed:
            await saveItem()
        }
    }

    override func receive(_ action: EditAuthenticatorItemAction) {
        switch action {
        case let .accountChanged(account):
            state.account = account
        case .dismissPressed:
            coordinator.navigate(to: .dismiss())
        case let .keyChanged(key):
            state.totpState = LoginTOTPState(key)
        case let .nameChanged(newValue):
            state.name = newValue
        case let .toggleKeyVisibilityChanged(isVisible):
            state.isKeyVisible = isVisible
        case let .toastShown(toast):
            state.toast = toast
        }
    }

    // MARK: Private Methods

    /// Handles dismissing the processor.
    ///
    /// - Parameter didAddItem: `true` if a new cipher was added or `false` if the user is
    ///     dismissing the view without saving.
    ///
    private func handleDismiss(didAddItem: Bool = false) {
        coordinator.navigate(to: .dismiss())
    }

    /// Saves the item currently stored in `state`.
    ///
    private func saveItem() async {
        defer { coordinator.hideLoadingOverlay() }
        do {
            try EmptyInputValidator(fieldName: Localizations.name)
                .validate(input: state.name)
            coordinator.showLoadingOverlay(title: Localizations.saving)
            switch state.configuration {
            case .add:
                return
            case let .existing(authenticatorItemView: authenticatorItemView):
                let newAuthenticatorItemView = AuthenticatorItemView(
                    id: authenticatorItemView.id,
                    name: authenticatorItemView.name,
                    totpKey: state.totpState.rawAuthenticatorKeyString
                )
                try await updateAuthenticatorItem(authenticatorItem: newAuthenticatorItemView)
            }
        } catch let error as InputValidationError {
            coordinator.showAlert(Alert.inputValidationAlert(error: error))
            return
        } catch {
            coordinator.showAlert(.networkResponseError(error))
            services.errorReporter.log(error: error)
        }
    }

    /// Updates the item currently in `state`.
    ///
    private func updateAuthenticatorItem(authenticatorItem: AuthenticatorItemView) async throws {
        let bar = try await services.authenticatorItemRepository.fetchAllAuthenticatorItems()
        try await services.authenticatorItemRepository.updateAuthenticatorItem(authenticatorItem)
        let foo = try await services.authenticatorItemRepository.fetchAllAuthenticatorItems()
        coordinator.hideLoadingOverlay()
        coordinator.navigate(to: .dismiss())
    }
}
