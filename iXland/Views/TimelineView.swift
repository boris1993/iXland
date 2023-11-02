import SwiftUI
import AlertToast

struct TimelineView: View {
    let logger = LoggerHelper.getLoggerForView(name: "TimelineView")

    @Environment(\.managedObjectContext)
    private var managedObjectContext

    @EnvironmentObject
    var globalState: GlobalState

    @State
    var shouldDisplayProgressView = false

    @State
    var timelineInitialized = false

    @State
    var isErrorToastShowing = false

    @State
    var errorMessage = ""

    @State
    var timelineThreads = [ForumThread]()

    var body: some View {
        if (timelineInitialized) {
            NavigationStack {
                GeometryReader { geometry in
                    List($timelineThreads) { $thread in
                        NavigationLink(destination: Text("")) {
                            ForumThreadView(geometry: geometry,
                                            forumThread: $thread)
                            .environmentObject(globalState)
                        }
                        .buttonStyle(.plain)
                    }
                    .listStyle(PlainListStyle())
                    .refreshable {
                        await loadTimeline()
                    }
                }
            }
            .toast(isPresenting: $isErrorToastShowing) {
                AlertToast(type: .regular, title: errorMessage)
            }
        } else {
            VStack {
                ProgressView {
                    Text(String(localized: "msgLoadingTimeline"))
                }
                .progressViewStyle(CircularProgressViewStyle())
                .scaledToFill()
                .onAppear {
                    if (!timelineInitialized) {
                        Task {
                            await loadTimeline()
                        }
                    }
                }
                .opacity(!timelineInitialized && errorMessage.isEmpty ? 1 : 0)

                VStack {
                    Text("msgFailedToLoadTimeline")
                    Text(errorMessage)
                    Text("msgTapToRetry")
                }
                .onTapGesture {
                    errorMessage = ""
                    Task {
                        await loadTimeline()
                    }
                }
                .opacity(!timelineInitialized && !errorMessage.isEmpty ? 1 : 0)
            }
        }

    }

    private func loadTimeline() async {
        do {
            self.timelineThreads = try await AnoBbsApiClient.loadTimelineThreads()
            for i in 0..<self.timelineThreads.count {
                self.timelineThreads[i].content = self.timelineThreads[i].content.replacingOccurrences(of: "<br>", with: "\n")
                self.timelineThreads[i].content = self.timelineThreads[i].content.replacingOccurrences(of: "<br />", with: "\n")
            }

            self.timelineInitialized = true
            logger.debug("Done loading timeline")
        } catch let error {
            errorMessage = "\(String(localized: "msgFailedToLoadTimeline"))\n\(error.localizedDescription)"
            if (timelineInitialized) {
                isErrorToastShowing = true
            }
        }

        shouldDisplayProgressView = false
    }
}

struct TimelineView_Previews: PreviewProvider {
    struct Container: View {
        let context = PersistenceController.preview.container.viewContext

        @State
        var timelineThreads = ForumThread.sample

        @EnvironmentObject
        var globalState: GlobalState

        var body: some View {
            TimelineView(
                timelineInitialized: true,
                timelineThreads: timelineThreads
            )
            .environment(\.managedObjectContext, context)
            .environmentObject(globalState)
        }
    }

    static var previews: some View {
        Container()
            .environmentObject({ () -> GlobalState in
                let globalState = GlobalState()
                
                globalState.cdnUrl = "https://image.nmb.best/"
                globalState.forumIdAndNameDictionary["4"] = "综合版一"

                return globalState
            }())
    }
}
