import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentCloudKitContainer
    let logger = LoggerHelper.getLoggerForPersistence(name: "PersistenceController")

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "iXland")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        // swiftlint:disable unused_closure_parameter
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        // swiftlint:enable unused_closure_parameter
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    func addCookie(cookie: Cookie) throws {
        do {
            try self.container.viewContext.save()
        } catch {
            logger.error("An error occurred when saving a cookie. \(error.localizedDescription)")
            throw error
        }
    }

    func findCookieByName(name: String) throws -> Cookie? {
        let context = PersistenceController.shared.container.viewContext

        let fetchRequest = Cookie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name LIKE %@", name)
        fetchRequest.returnsObjectsAsFaults = false

        let cookie = try context.fetch(fetchRequest)

        return cookie.count == 0 ? nil : cookie.first
    }

    func isCookieImported(name: String) throws -> Bool {
        return try findCookieByName(name: name) != nil
    }

    func removeCookie(cookie: Cookie) throws {
        logger.info("Removing cookie \(cookie)")
        self.container.viewContext.delete(cookie)

        do {
            try self.container.viewContext.save()
        } catch {
            logger.error("An error occurred when removing a cookie. \(error.localizedDescription)")
            throw error
        }
    }

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext

        for dummyCookieID in 1...5 {
            let cookie = Cookie(context: viewContext)
            cookie.name = String(dummyCookieID)
            cookie.cookie = "cookie \(dummyCookieID)"
        }

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
}
