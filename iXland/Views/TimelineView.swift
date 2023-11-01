import SwiftUI

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
                        loadTimeline()
                    }
                }
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
                        loadTimeline()
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
                    loadTimeline()
                }
                .opacity(errorMessage.isEmpty ? 0 : 1)
            }
        }

    }

    private func loadTimeline() {
        shouldDisplayProgressView = true

        AnoBbsApiClient.loadTimelineThreads { threads in
            self.timelineThreads = threads

            for i in 0..<self.timelineThreads.count {
                self.timelineThreads[i].content = self.timelineThreads[i].content.replacingOccurrences(of: "<br>", with: "\n")
                self.timelineThreads[i].content = self.timelineThreads[i].content.replacingOccurrences(of: "<br />", with: "\n")
            }

            self.timelineInitialized = true
            logger.debug("Done loading timeline")
        } failure: { error in
            errorMessage = error
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
