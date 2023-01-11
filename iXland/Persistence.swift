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
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
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

        for i in 1...5 {
            let cookie = Cookie(context: viewContext)
            cookie.name = String(i)
            cookie.cookie = "cookie \(i)"
        }

        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
}
