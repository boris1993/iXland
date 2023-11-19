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
    var timelineNameAndIdDictionary = [String: Int]()

    @State
    var currentSelectedTimelineId = 0

    @State
    var maxPageOfThisTimeline = 0

    @State
    var currentPage = 1

    @State
    var timelineThreads = [ForumThread]()

    var body: some View {
        NavigationStack {
            ForumThreadsListView(
                timelineThreads: $timelineThreads,
                timelineInitialized: $timelineInitialized,
                currentPage: $currentPage,
                maxPage: $maxPageOfThisTimeline,
                loadAndRefreshFunction: loadTimeline,
                incrementalLoadingFunction: loadMoreTimelineItems
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
                    .onChange(of: currentSelectedTimelineId) { _ in
                        Task {
                            self.maxPageOfThisTimeline = timelineForums
                                .first { timelineForum in
                                    timelineForum.id == currentSelectedTimelineId
                                }!.maxPage
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
        self.currentPage = 1
        self.timelineThreads = []
        await loadTimeline()
    }

    private func loadTimeline() async {
        do {
            self.timelineThreads = try await AnoBbsApiClient.loadTimelineThreads(id: self.currentSelectedTimelineId)
            for index in 0..<self.timelineThreads.count {
                self.timelineThreads[index].content = HtmlParser.normalizeTexts(
                    content: self.timelineThreads[index].content
                )
            }

            self.timelineInitialized = true
            logger.debug("Done loading timeline")
        } catch let error {
            errorMessage = error.localizedDescription
            if timelineInitialized {
                isErrorToastShowing = true
            }
        }
    }

    private func loadMoreTimelineItems() async {
        if currentPage == maxPageOfThisTimeline {
            return
        }

        do {
            currentPage += 1

            logger.info("Loading page \(currentPage) for timeline ID \(currentSelectedTimelineId)")
            var newThreads = try await AnoBbsApiClient.loadTimelineThreads(
                id: self.currentSelectedTimelineId, page: currentPage
            )
            for index in 0..<newThreads.count {
                newThreads[index].content = HtmlParser.normalizeTexts(content: newThreads[index].content)
            }

            self.timelineThreads += newThreads
        } catch let error {
            errorMessage = error.localizedDescription
            isErrorToastShowing = true
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
