import SwiftUI
import AlertToast

struct TimelineView: View {
    let logger = LoggerHelper.getLoggerForView(name: "TimelineView")

    @Environment(\.managedObjectContext)
    private var managedObjectContext

    @EnvironmentObject
    var globalState: GlobalState

    @State
    var timelineInitialized = false

    @State
    var isErrorToastShowing = false

    @State
    var errorMessage = ""

    @State
    var timelineForums = [TimelineForum]()

    @State
    var timelineNameAndIdDictionary = [String:Int]()

    @State
    var currentSelectedTimelineId = 0

    @State
    var timelineThreads = [ForumThread]()

    var body: some View {
        NavigationStack {
            ForumThreadViewNavigationLink(
                timelineThreads: $timelineThreads,
                loadAndRefreshFunction: loadTimeline
            )
            .environmentObject(globalState)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Picker(selection: $currentSelectedTimelineId) {
                        ForEach(timelineForums) { timelineForum in
                            Text(timelineForum.name).tag(timelineForum.id)
                        }
                    } label: {
                    }
                    .pickerStyle(.menu)
                    .onChange(of: currentSelectedTimelineId) { selectedTimelineForumId in
                        Task {
                            await clearTimelineAndReload()
                        }
                    }
                }
            }
        }
        .onAppear {
            Task {
                await loadTimelineForums()
            }
        }
        .overlay {
            VStack {
                ProgressView {
                    Text("msgLoadingTimeline")
                }
                .progressViewStyle(CircularProgressViewStyle())
                .scaledToFill()
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
        .toast(isPresenting: $isErrorToastShowing) {
            AlertToast(type: .regular, title: errorMessage)
        }
    }

    private func loadTimelineForums() async {
        do {
            self.timelineForums = try await AnoBbsApiClient.loadTimelineForums()
            self.currentSelectedTimelineId = self.timelineForums[0].id
            self.timelineForums.forEach { timelineForum in
                self.timelineNameAndIdDictionary[timelineForum.name] = timelineForum.id
            }
        } catch let error {
            errorMessage = error.localizedDescription
        }
    }

    private func clearTimelineAndReload() async {
        self.timelineInitialized = false
        self.errorMessage = ""
        self.timelineThreads = []
        await loadTimeline()
    }

    private func loadTimeline() async {
        do {
            self.timelineThreads = try await AnoBbsApiClient.loadTimelineThreads(id: self.currentSelectedTimelineId)
            for i in 0..<self.timelineThreads.count {
                self.timelineThreads[i].content = self.timelineThreads[i].content.replacingOccurrences(of: "<br>", with: "\n")
                self.timelineThreads[i].content = self.timelineThreads[i].content.replacingOccurrences(of: "<br />", with: "\n")
            }

            self.timelineInitialized = true
            logger.debug("Done loading timeline")
        } catch let error {
            errorMessage = error.localizedDescription
            if (timelineInitialized) {
                isErrorToastShowing = true
            }
        }
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
                timelineForums: TimelineForum.sample,
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
