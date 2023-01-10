import SwiftUI
import CodeScanner
import AlertToast

struct SettingsView: View {
    let logger = LoggerHelper.getLoggerForView(name: "SettingsView")
    
    private let jsonDecoder = JSONDecoder()
    private let persistenceController = PersistenceController.shared
    
    @Environment(\.managedObjectContext)
    var managedObjectContext
    
    @Environment(\.colorScheme)
    var systemColorScheme
    
    @FetchRequest(
        entity: Cookie.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Cookie.name, ascending: true)],
        animation: .default
    )
    private var cookies: FetchedResults<Cookie>
    
    @State
    private var isHapticFeedbackEnabled = UserDefaultsHelper.getHapticFeedbackEnabledState()
    
    @State
    private var subscriptionId: String = ""
    
    @State
    private var themePickerSelectedValue: Themes = Themes.dark
    
    @State
    private var currentSelectedCookie: Cookie? = try? UserDefaultsHelper.getCurrentCookie()
    
    @State
    private var isQrCodeScannerShowing = false
    
    @State
    private var isErrorToastShowing = false
    
    @State
    private var errorMessage: String = ""
    
    var body: some View {
        NavigationView {
            List {
                // MARK: 设定
                Section(
                    header: Text("tabNameSettings")
                ) {
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
                }
                
                // MARK: 饼干列表
                Section(
                    header: Text("sectionNameCookieList")
                ) {
                    ForEach(cookies) { cookie in
                        Button {
                            currentSelectedCookie = cookie
                            do {
                                try UserDefaultsHelper.setCurrentCookie(currentCookieName: cookie.name!)
                            } catch {
                                errorMessage = error.localizedDescription
                                isErrorToastShowing = true
                            }
                        } label: {
                            Text(cookie.name!)
                                .fontWeight(currentSelectedCookie == cookie ? .bold : .regular)
                        }
                        .foregroundColor(.primary)
                    }
                    .onDelete(perform: handleRemoveCookie)
                    
                    Menu("buttonAddCookie") {
                        Button("buttonScanQRCode") {
                            self.isQrCodeScannerShowing.toggle()
                        }
                        
                        Button("buttonImportFromPhotos") {
                            
                        }
                    }
                    .sheet(isPresented: $isQrCodeScannerShowing) {
                        CodeScannerView(
                            codeTypes: [.qr],
                            completion: handleQrCodeScan(result:))
                    }
                }
                
                // MARK: 关于
                Section(
                    header: Text("sectionNameAbout")
                ) {
                    HStack {
                        Link(
                            "fieldTitleViewInGitHub",
                            destination: URL(string: Constants.GITHUB_REPO_ADDRESS)!)
                    }
                }
            }
        }
        .onAppear() {
            if (isHapticFeedbackEnabled) {
                HapticsHelper.playHapticFeedback()
            }
            
            subscriptionId = UserDefaultsHelper.getSubscriptionId()
            
            let selectedTheme = UserDefaultsHelper.getSelectedTheme() ??
            (systemColorScheme == .dark ? Themes.dark.rawValue : Themes.light.rawValue)
            
            themePickerSelectedValue = Themes(rawValue: selectedTheme)!
            ThemeHelper.setAppTheme(themePickerSelectedValue: themePickerSelectedValue)
            
            logger.debug("Current cookie: \(currentSelectedCookie)")
        }
        .toast(isPresenting: $isErrorToastShowing) {
            AlertToast(type: .regular, title: errorMessage)
        }
    }
    
    private func handleQrCodeScan(result: Result<ScanResult, ScanError>) {
        isQrCodeScannerShowing = false
        
        switch result {
        case .success(let result):
            let qrCodeRawData = result.string
            logger.debug("QR Code result = \(qrCodeRawData)")
                        
            let anoBbsCookie: AnoBbsCookie
            do {
                anoBbsCookie = try jsonDecoder.decode(
                    AnoBbsCookie.self,
                    from: qrCodeRawData.data(using: .utf8)!)
            } catch {
                logger.error("\(error.localizedDescription)")
                showErrorToast(message: error.localizedDescription)
                return
            }
            
            let isCookieAlreadyImported: Bool
            do {
                isCookieAlreadyImported =
                try persistenceController.isCookieImported(name: anoBbsCookie.name)
            } catch {
                logger.error("\(error.localizedDescription)")
                showErrorToast(message: error.localizedDescription)
                return
            }
            
            if (isCookieAlreadyImported) {
                let errorMessage = String(localized: "msgCookieAlreadyImported")
                showErrorToast(message: errorMessage)
                return
            }
            
            let cookie = Cookie(context: persistenceController.container.viewContext)
            cookie.name = anoBbsCookie.name
            cookie.cookie = anoBbsCookie.cookie
            
            do {
                try persistenceController.addCookie(cookie: cookie)
            } catch {
                showErrorToast(message: error.localizedDescription)
            }
        case .failure(let error):
            logger.error("\(error.localizedDescription)")
        }
    }
    
    private func handleRemoveCookie(at offsets: IndexSet) {
        for index in offsets {
            let cookieToBeDeleted = cookies[index]
            
            do {
                try persistenceController.removeCookie(cookie: cookieToBeDeleted)
            } catch {
                showErrorToast(message: error.localizedDescription)
                return
            }
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
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        
        SettingsView()
            .previewDisplayName("en")
            .environment(\.managedObjectContext, context)
            .environment(\.locale, .init(identifier: "en"))
        SettingsView()
            .previewDisplayName("zh-Hans")
            .environment(\.managedObjectContext, context)
            .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
