import Combine
import Foundation

// MARK: - StateService

/// A protocol for a `StateService` which manages the saved state of the app
///
protocol StateService: AnyObject {
    /// The language option currently selected for the app.
    var appLanguage: LanguageOption { get set }

    /// Get the app theme.
    ///
    /// - Returns: The app theme.
    ///
    func getAppTheme() async -> AppTheme

    /// Gets the clear clipboard value for an account.
    ///
    /// - Parameter userId: The user ID associated with the clear clipboard value. Defaults to the active
    ///   account if `nil`
    /// - Returns: The time after which the clipboard should clear.
    ///
    func getClearClipboardValue(userId: String?) async throws -> ClearClipboardValue

    /// Sets the app theme.
    ///
    /// - Parameter appTheme: The new app theme.
    ///
    func setAppTheme(_ appTheme: AppTheme) async

    /// Sets the clear clipboard value for an account.
    ///
    /// - Parameters:
    ///   - clearClipboardValue: The time after which to clear the clipboard.
    ///   - userId: The user ID of the account. Defaults to the active account if `nil`.
    ///
    func setClearClipboardValue(_ clearClipboardValue: ClearClipboardValue?, userId: String?) async throws
}

// MARK: - DefaultStateService

/// A default implementation of `StateService`.
///
actor DefaultStateService: StateService {
    // MARK: Properties

    /// The language option currently selected for the app.
    nonisolated var appLanguage: LanguageOption {
        get { LanguageOption(appSettingsStore.appLocale) }
        set { appSettingsStore.appLocale = newValue.value }
    }

    // MARK: Private Properties

    /// The service that persists app settings.
    let appSettingsStore: AppSettingsStore

    /// A subject containing the app theme.
    private var appThemeSubject: CurrentValueSubject<AppTheme, Never>

    /// The data store that handles performing data requests.
    private let dataStore: DataStore

    // MARK: Initialization

    /// Initialize a `DefaultStateService`.
    ///
    /// - Parameters:
    ///  - appSettingsStore: The service that persists app settings.
    ///  - dataStore: The data store that handles performing data requests.
    ///
    init(
        appSettingsStore: AppSettingsStore,
        dataStore: DataStore
    ) {
        self.appSettingsStore = appSettingsStore
        self.dataStore = dataStore

        appThemeSubject = CurrentValueSubject(AppTheme(appSettingsStore.appTheme))
    }

    // MARK: Methods

    func getAppTheme() async -> AppTheme {
        AppTheme(appSettingsStore.appTheme)
    }

    func getClearClipboardValue(userId: String?) async throws -> ClearClipboardValue {
        let userId = try userId ?? getActiveAccountUserId()
        return appSettingsStore.clearClipboardValue(userId: userId)
    }

    func setAppTheme(_ appTheme: AppTheme) async {
        appSettingsStore.appTheme = appTheme.value
        appThemeSubject.send(appTheme)
    }

    func setClearClipboardValue(_ clearClipboardValue: ClearClipboardValue?, userId: String?) async throws {
        let userId = try userId ?? getActiveAccountUserId()
        appSettingsStore.setClearClipboardValue(clearClipboardValue, userId: userId)
    }

    // MARK: Private

    /// Returns the user ID for the active account.
    ///
    /// - Returns: The user ID for the active account.
    ///
    private func getActiveAccountUserId() throws -> String {
        appSettingsStore.localUserId
    }
}
