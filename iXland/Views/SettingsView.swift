import SwiftUI
import CodeScanner
import AlertToast
import ImagePickerView
import ZXingObjC

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
    private var subscriptionId: String = UserDefaultsHelper.getSubscriptionId()
    
    @State
    private var themePickerSelectedValue: Themes = Themes.dark
    
    @State
    private var currentSelectedCookie: Cookie? = try? UserDefaultsHelper.getCurrentCookie()
    
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
                            self.isPhotoPickerShowing.toggle()
                        }
                    }
                    .sheet(isPresented: $isQrCodeScannerShowing) {
                        CodeScannerView(
                            codeTypes: [.qr],
                            completion: handleQrCodeScan(result:))
                    }
                    .sheet(isPresented: $isPhotoPickerShowing) {
                        ImagePickerView(sourceType: .photoLibrary) { image in
                            handleDecodeQrCodeFromPicture(uiImage: image)
                        }
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
            
            deserializeAndSaveCookie(cookieContent: qrCodeRawData)
        case .failure(let error):
            logger.error("\(error.localizedDescription)")
        }
    }
    
    private func handleDecodeQrCodeFromPicture(uiImage: UIImage) {
        let cgImage = uiImage.cgImage
        let source = ZXCGImageLuminanceSource(cgImage: cgImage)
        let bitmap = ZXBinaryBitmap.init(binarizer: ZXHybridBinarizer(source: source))
        if let reader = ZXMultiFormatReader.reader() as? ZXMultiFormatReader {
            do {
                let hints = ZXDecodeHints.hints()
                let result = try reader.decode(bitmap, hints: hints as? ZXDecodeHints)
                let contents = result.text
                
                if (contents == nil) {
                    showErrorToast(message: String(localized: "msgInvalidCookieQrCode"))
                    return
                }
                
                logger.debug("Content of QR code decoded from picture: \(contents!)")
                
                deserializeAndSaveCookie(cookieContent: contents!)
            } catch {
                showErrorToast(message: error.localizedDescription)
            }
        } else {
            showErrorToast(message: String(localized: "msgFailedToCreateZXMultiFormatReader"))
        }
    }
    
    private func deserializeAndSaveCookie(cookieContent: String) {
        let anoBbsCookie: AnoBbsCookie
        do {
            anoBbsCookie = try jsonDecoder.decode(
                AnoBbsCookie.self,
                from: cookieContent.data(using: .utf8)!)
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
    }
    
    private func handleRemoveCookie(at offsets: IndexSet) {
        for index in offsets {
            let cookieToBeDeleted = cookies[index]
            
            if (cookieToBeDeleted == currentSelectedCookie) {
                currentSelectedCookie = nil
                UserDefaultsHelper.removeCurrentCookie()
            }
            
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
