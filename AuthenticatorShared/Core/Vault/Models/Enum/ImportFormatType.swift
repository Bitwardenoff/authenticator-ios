// MARK: - ImportFormatType

/// An enum describing the format of the imported items file by provider.
/// This is used in the UI to know if additional information (such as password)
/// needs to be acquired before doing the import.
///
enum ImportFormatType: Menuable {
    /// A JSON exported from Bitwarden
    case bitwardenJson

    /// A JSON exported from Raivo
    case raivoJson

    // MARK: Type Properties

    /// The ordered list of options to display in the menu.
    static let allCases: [ImportFormatType] = [
        .bitwardenJson,
        .raivoJson,
    ]

    // MARK: Properties

    /// The name of the type to display in the dropdown menu.
    var localizedName: String {
        switch self {
        case .bitwardenJson:
            "Authenticator Export (JSON)"
        case .raivoJson:
            "Raivo (JSON)"
        }
    }
}
