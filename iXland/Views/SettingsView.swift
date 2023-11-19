import SwiftUI
import CodeScanner
import ImagePickerView
import ZXingObjC
import AlertToast

struct SettingsView: View {
    let logger = LoggerHelper.getLoggerForView(name: "SettingsView")

#if DEBUG
    // Test Ad Units
    // https://developers.google.com/admob/ios/test-ads#demo_ad_units
    private let adUnitId = "ca-app-pub-3940256099942544/2934735716"
#else
    private let adUnitId = "ca-app-pub-1056823357231661/5419266498"
#endif

    private let jsonDecoder = JSONDecoder()
    private let persistenceController = PersistenceController.shared

    @ObservedObject
    var globalState: GlobalState

    @Environment(\.managedObjectContext)
    private var managedObjectContext

    @FetchRequest(
        entity: Cookie.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Cookie.name, ascending: true)],
        animation: .default
    )
    private var cookies: FetchedResults<Cookie>

    @State
    private var isQrCodeScannerShowing = false

    @State
    private var isPhotoPickerShowing = false

    @State
    private var image: UIImage?

    @State
    private var isErrorToastShowing = false

    @State
    private var errorMessage: String = ""

    @AppStorage(UserDefaultsKey.Theme)
    private var themePickerSelectedValue: Themes = Themes.dark

    @AppStorage(UserDefaultsKey.HapticFeedback)
    private var hapticFeedbackEnabled: Bool = false

    @AppStorage(UserDefaultsKey.SubscriptionID)
    private var subscriptionId: String = ""

    var body: some View {
        NavigationStack {
            List {
                // MARK: 设定
                Section {
                    HStack {
                        Text("fieldTitleTheme")
                        Spacer()
                        Picker(
                            selection: $themePickerSelectedValue,
                            label: Text("fieldTitleDarkMode")) {
                                Text("themeDark").tag(Themes.dark)
                                Text("themeLight").tag(Themes.light)
                            }
                            .onChange(of: themePickerSelectedValue) { _ in
                                ThemeHelper.setAppTheme(themePickerSelectedValue: themePickerSelectedValue)
                            }
                            .pickerStyle(.segmented)
                            .fixedSize()
                    }

                    HStack {
                        Text("fieldTitleSubscriptionId")
                        Spacer()
                        TextField("", text: $subscriptionId)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.asciiCapable)
                        Button(
                            action: {
                                generateNewSubscriptionId()
                            }, label: {
                                Image(systemName: "arrow.clockwise")
                            }
                        )
                        .buttonStyle(.borderless)
                    }

                    HStack {
                        Toggle(isOn: $hapticFeedbackEnabled) {
                            Text("HapticFeedback")
                        }
                    }
                }

                Section {
                    NavigationLink(destination: CookieListView(globalState: globalState)) {
                        Text("CookieList")
                    }

                    HStack {
                        Text("fieldCurrentSelectedCookie")
                        Spacer()
                        Text(globalState.currentSelectedCookie?.name ?? "")
                    }
                }

                // MARK: 关于
                Section {
                    HStack {
                        Link(
                            "fieldTitleViewInGitHub",
                            destination: URL(string: Constants.GitHubRepoAddress)!)
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            SwiftUIBannerAd(adPosition: .bottom, adUnitId: adUnitId)
        }
        .navigationViewStyle(.stack)
        .onAppear {
            let selectedTheme = themePickerSelectedValue.rawValue
            themePickerSelectedValue = Themes(rawValue: selectedTheme)!

            logger.debug("Current cookie: \(globalState.currentSelectedCookie)")
        }
        .toast(isPresenting: $isErrorToastShowing) {
            AlertToast(type: .regular, title: errorMessage)
        }
    }

    private func generateNewSubscriptionId() {
        self.subscriptionId = UUID().uuidString
    }

    private func showErrorToast(message: String) {
        errorMessage = message
        isErrorToastShowing = true
    }
}

struct SettingsView_Previews: PreviewProvider {
    @ObservedObject
    static var globalState = GlobalState()

    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext

        SettingsView(globalState: globalState)
            .previewDisplayName("en")
            .environment(\.managedObjectContext, context)
            .environment(\.colorScheme, .dark)
            .environment(\.locale, .init(identifier: "en"))
        SettingsView(globalState: globalState)
            .previewDisplayName("zh-Hans")
            .environment(\.managedObjectContext, context)
            .environment(\.colorScheme, .dark)
            .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
