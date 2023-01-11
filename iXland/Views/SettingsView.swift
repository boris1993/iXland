import SwiftUI
import CodeScanner
import ImagePickerView
import ZXingObjC
import AlertToast

struct SettingsView: View {
    let logger = LoggerHelper.getLoggerForView(name: "SettingsView")
    
    private let jsonDecoder = JSONDecoder()
    private let persistenceController = PersistenceController.shared
    
    @Environment(\.managedObjectContext)
    private var managedObjectContext
    
    @Environment(\.colorScheme)
    private var systemColorScheme
    
    @ObservedObject
    var globalState: GlobalState
    
    @FetchRequest(
        entity: Cookie.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Cookie.name, ascending: true)],
        animation: .default
    )
    private var cookies: FetchedResults<Cookie>
    
    @State
    private var isHapticFeedbackEnabled = UserDefaultsHelper.getHapticFeedbackEnabledState()
    
    @State
    private var subscriptionId: String = UserDefaultsHelper.getSubscriptionId()
    
    @State
    private var themePickerSelectedValue: Themes = Themes.dark
    
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
                                UserDefaultsHelper.setSelectedTheme(theme: themePickerSelectedValue.rawValue)
                                ThemeHelper.setAppTheme(themePickerSelectedValue: themePickerSelectedValue)
                            }
                            .pickerStyle(.segmented)
                            .fixedSize()
                    }
                    
                    HStack {
                        Toggle(isOn: $isHapticFeedbackEnabled) {
                            Text("fieldTitleHapticFeedback")
                        }.onChange(of: isHapticFeedbackEnabled) { isHapticFeedbackEnabled in
                            UserDefaultsHelper.setHapticFeedbackEnabledState(isHapticFeedbackEnabled: isHapticFeedbackEnabled)
                        }
                    }
                    
                    HStack {
                        Text("fieldTitleSubscriptionId")
                        Spacer()
                        TextField("", text: $subscriptionId)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.asciiCapable)
                            .onChange(of: subscriptionId, perform: { _ in
                                updateSubscriptionId()
                            })
                        Button(
                            action: {
                                generateNewSubscriptionId()
                            }, label: {
                                Image(systemName: "arrow.clockwise")
                            }
                        )
                        .buttonStyle(.borderless)
                    }
                    
                    NavigationLink(destination: CookieListView(globalState: globalState)) {
                        Text("CookieList")
                    }
                }
                
                // MARK: 关于
                Section {
                    HStack {
                        Link(
                            "fieldTitleViewInGitHub",
                            destination: URL(string: Constants.GITHUB_REPO_ADDRESS)!)
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
        .onAppear() {
            let selectedTheme = UserDefaultsHelper.getSelectedTheme() ??
            (systemColorScheme == .dark ? Themes.dark.rawValue : Themes.light.rawValue)
            
            themePickerSelectedValue = Themes(rawValue: selectedTheme)!
            
//            let currentSelectedCookie = try? UserDefaultsHelper.getCurrentCookie()
            logger.debug("Current cookie: \(globalState.currentSelectedCookie)")
        }
        .toast(isPresenting: $isErrorToastShowing) {
            AlertToast(type: .regular, title: errorMessage)
        }
    }
    
    private func generateNewSubscriptionId() {
        self.subscriptionId = UUID().uuidString
        updateSubscriptionId()
    }
    
    private func updateSubscriptionId() {
        UserDefaultsHelper.setSubscriptionId(subscriptionId: self.subscriptionId)
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
