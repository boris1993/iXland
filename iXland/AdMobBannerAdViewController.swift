import SwiftUI
import UIKit
import GoogleMobileAds

// https://medium.com/geekculture/adding-google-mobile-ads-admob-to-your-swiftui-app-in-ios-14-5-5073a2b99cf9
final class AdMobBannerAdViewController: UIViewController {
    let adUnitId: String
    
    init(adUnitId: String) {
        self.adUnitId = adUnitId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var bannerAdView = GADBannerView()
    
    override func viewDidLoad() {
        bannerAdView.adUnitID = adUnitId
        bannerAdView.rootViewController = self
        
        view.addSubview(bannerAdView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadBannerAd()
    }
    
    //Allows the banner to resize when transition from portrait to landscape orientation
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { _ in
            self.bannerAdView.isHidden = true //So banner doesn't disappear in middle of animation
        } completion: { _ in
            self.bannerAdView.isHidden = false
            self.loadBannerAd()
        }
    }
    
    func loadBannerAd() {
        let frame = view.frame.inset(by: view.safeAreaInsets)
        let viewWidth = frame.size.width
        bannerAdView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
        bannerAdView.load(GADRequest())
    }
}

struct BannerAd: UIViewControllerRepresentable {
    let adUnitId: String
    
    init(adUnitId: String) {
        self.adUnitId = adUnitId
    }
    
    func makeUIViewController(context: Context) -> AdMobBannerAdViewController {
        return AdMobBannerAdViewController(adUnitId: adUnitId)
    }
    
    func updateUIViewController(_ uiViewController: AdMobBannerAdViewController, context: Context) {
        
    }
}

struct SwiftUIBannerAd: View {
    @State var height: CGFloat = 0 //Height of ad
    @State var width: CGFloat = 0 //Width of ad
    @State var adPosition: AdPosition
    let adUnitId: String
    
    init(adPosition: AdPosition, adUnitId: String) {
        self.adPosition = adPosition
        self.adUnitId = adUnitId
    }
    
    enum AdPosition {
        case top
        case bottom
    }
    
    public var body: some View {
        VStack {
            if adPosition == .bottom {
                Spacer() //Pushes ad to bottom
            }
            
            //Ad
            BannerAd(adUnitId: adUnitId)
                .frame(width: width, height: height, alignment: .center)
                .onAppear {
                    //Call this in .onAppear() b/c need to load the initial frame size
                    //.onReceive() will not be called on initial load
                    setFrame()
                }
                //Changes the frame of the ad whenever the device is rotated.
                //This is what creates the adaptive ad
                .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                    setFrame()
                }
            
            if adPosition == .top {
                Spacer() //Pushes ad to top
            }
        }
    }
    
    func setFrame() {
        //Get the frame of the safe area
        let safeAreaInsets =
        UIApplication.shared.connectedScenes
            .map({ $0 as? UIWindowScene })
            .compactMap({ $0 })
            .first?
            .windows.first?
            .safeAreaInsets ?? .zero
        let frame = UIScreen.main.bounds.inset(by: safeAreaInsets)
        
        //Use the frame to determine the size of the ad
        let adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(frame.width)
        
        //Set the ads frame
        self.width = adSize.size.width
        self.height = adSize.size.height
    }
}
