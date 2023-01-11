import SwiftUI
import CodeScanner
import ImagePickerView
import ZXingObjC
import AlertToast

struct CookieListView: View {
    private let logger = LoggerHelper.getLoggerForView(name: "SettingsView")
    private let persistenceController = PersistenceController.shared
    private let jsonDecoder = JSONDecoder()
    
    @FetchRequest(
        entity: Cookie.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Cookie.name, ascending: true)],
        animation: .default
    )
    private var cookies: FetchedResults<Cookie>
    
    @ObservedObject
    var globalState: GlobalState
    
    @State
    private var isQrCodeScannerShowing = false
    
    @State
    private var isPhotoPickerShowing = false
    
    @State
    private var isErrorToastShowing = false
    
    @State
    private var errorMessage: String = ""
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(cookies) { cookie in
                    Button {
                        globalState.currentSelectedCookie = cookie
                        logger.debug("globalState.currentSelectedCookie = \(globalState.currentSelectedCookie)")
                        
                        do {
                            try UserDefaultsHelper.setCurrentCookie(currentCookieName: cookie.name!)
                        } catch {
                            errorMessage = error.localizedDescription
                            isErrorToastShowing = true
                        }
                    } label: {
                        Text(cookie.name!)
                            .fontWeight(globalState.currentSelectedCookie == cookie ? .bold : .regular)
                    }
                    .foregroundColor(.primary)
                }
                .onDelete(perform: handleRemoveCookie)
            }
            .toast(isPresenting: $isErrorToastShowing) {
                AlertToast(type: .regular, title: errorMessage)
            }
            .navigationTitle("CookieList")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("buttonScanQRCode") {
                            self.isQrCodeScannerShowing.toggle()
                        }

                        Button("buttonImportFromPhotos") {
                            self.isPhotoPickerShowing.toggle()
                        }
                    } label: {
                        Image(systemName: "plus")
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
            }
            .navigationViewStyle(.stack)
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
            
            if (cookieToBeDeleted == globalState.currentSelectedCookie) {
                globalState.currentSelectedCookie = nil
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
    
    private func showErrorToast(message: String) {
        errorMessage = message
        isErrorToastShowing = true
    }
}

struct CookieListView_Previews: PreviewProvider {
    @ObservedObject
    static var globalState = GlobalState()
    
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        CookieListView(globalState: globalState)
            .previewDisplayName("en")
            .environment(\.managedObjectContext, context)
            .environment(\.colorScheme, .dark)
            .environment(\.locale, .init(identifier: "en"))
        
        CookieListView(globalState: globalState)
            .previewDisplayName("zh-Hans")
            .environment(\.managedObjectContext, context)
            .environment(\.colorScheme, .dark)
            .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
