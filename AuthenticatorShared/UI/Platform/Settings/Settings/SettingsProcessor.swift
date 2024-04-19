// MARK: - SettingsProcessor

/// The processor used to manage state and handle actions for the settings screen.
///
final class SettingsProcessor: StateProcessor<SettingsState, SettingsAction, SettingsEffect> {
    // MARK: Types

    typealias Services = HasErrorReporter
        & HasExportItemsService
        & HasPasteboardService
        & HasStateService

    // MARK: Private Properties

    /// The `Coordinator` that handles navigation.
    private let coordinator: AnyCoordinator<SettingsRoute, SettingsEvent>

    /// The services for this processor.
    private var services: Services

    // MARK: Initialization

    /// Creates a new `SettingsProcessor`.
    ///
    /// - Parameters:
    ///   - coordinator: The `Coordinator` that handles navigation.
    ///   - services: The services for this processor.
    ///   - state: The initial state of the processor.
    ///
    init(
        coordinator: AnyCoordinator<SettingsRoute, SettingsEvent>,
        services: Services,
        state: SettingsState
    ) {
        self.coordinator = coordinator
        self.services = services
        super.init(state: state)
    }

    // MARK: Methods

    override func perform(_ effect: SettingsEffect) async {
        switch effect {
        case .loadData:
            state.currentLanguage = services.stateService.appLanguage
            state.appTheme = await services.stateService.getAppTheme()
        }
    }

    override func receive(_ action: SettingsAction) {
        switch action {
        case let .appThemeChanged(appTheme):
            state.appTheme = appTheme
            Task {
                await services.stateService.setAppTheme(appTheme)
            }
        case .clearURL:
            state.url = nil
        case .exportItemsTapped:
            confirmExportItems()
        case .helpCenterTapped:
            state.url = ExternalLinksConstants.helpAndFeedback
        case .languageTapped:
            coordinator.navigate(to: .selectLanguage(currentLanguage: state.currentLanguage), context: self)
        case .privacyPolicyTapped:
            coordinator.showAlert(.privacyPolicyAlert {
                self.state.url = ExternalLinksConstants.privacyPolicy
            })

        case let .toastShown(newValue):
            state.toast = newValue
        case .tutorialTapped:
            coordinator.navigate(to: .tutorial)
        case .versionTapped:
            handleVersionTapped()
        }
    }

    // MARK: - Private Methods

    /// Shows the alert to confirm the items export.
    private func confirmExportItems() {
        let format = ExportFileType.json

        coordinator.showAlert(.confirmExportItems() {
            do {
                let fileUrl = try await self.services.exportItemsService.exportItems(format: .json)
                self.coordinator.navigate(to: .shareExportedItems(fileUrl))
            } catch {
                self.services.errorReporter.log(error: error)
            }
        })
    }

    /// Prepare the text to be copied.
    private func handleVersionTapped() {
        // Copy the copyright text followed by the version info.
        let text = "Bitwarden Authenticator\n\n" + state.copyrightText + "\n\n" + state.version
        services.pasteboardService.copy(text)
        state.toast = Toast(text: Localizations.valueHasBeenCopied(Localizations.appInfo))
    }
}

// MARK: - SelectLanguageDelegate

extension SettingsProcessor: SelectLanguageDelegate {
    /// Update the language selection.
    func languageSelected(_ languageOption: LanguageOption) {
        state.currentLanguage = languageOption
    }
}
