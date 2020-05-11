//
//  AppDelegate.swift
//  OpenDay-Mac
//
//  Created by Martin Hartl on 13.03.20.
//  Copyright © 2020 Martin Hartl. All rights reserved.
//

import Cocoa
import Foundation
import SwiftUI
import DayOneKit
import WeatherService
import Combine
import Secrets
import Models
import OpenKit
import OpenDayService

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserInterfaceValidations {

    var window: NSWindow!
    var entriesStore: EntriesStore!

    var weatherCancellable: AnyCancellable?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let repositroy = OpenDayRepository(client: URLSession.shared)
        entriesStore = EntriesStore(repository: repositroy)

//        entriesStore.deleteAll()

        let contentView = ContentView().environmentObject(entriesStore)

        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = false
        openPanel.begin { result in
            let syncClient = SynchronousClient(urlSession: .shared)
            let repo = OpenDayRepository(client: syncClient)

            if result == NSApplication.ModalResponse.OK {
                guard let url = openPanel.url else {
                    return
                }

                let manager = DayOneKitDataReader(fileURL: url)
                let data = manager.importedData(for: "J")

                for entry in data.entries {
                    var modelLocation: Models.Location? = nil

                    if let location = entry.location {
                        let coordinates = Models.Location.Coordinates(longitude: location.longitude ?? 0.0,
                                                                      latitude: location.latitude ?? 0.0)

                        modelLocation = Models.Location(coordinates: coordinates,
                                                   isoCountryCode: location.countryCode ?? "",
                                                   city: location.administrativeArea,
                                                   name: location.placeName)
                    }

                    var images = [ImageResource]()

                    if let photos = entry.photos {
                        for photo in photos {
                            guard let data = try? Data(contentsOf: photo.fileURL(for: url)) else {
                                print("Coudlnt read file: \(photo.fileURL(for: url))")
                                continue
                            }

                            images.append(.local(data: data, creationDate: nil))
                        }
                    }

                    var modelWeather: Models.Weather? = nil

                    if let weather = entry.weather {
                        modelWeather = Models.Weather(weatherSymbol: Models.WeatherIcon.matched(from: weather.weatherCode),
                                                      fahrenheit: weather.temperatureCelsius)
                    }

                    let modelEntry = Models.Entry(id: nil,
                                             title: entry.title,
                                             bodyText: entry.body,
                                             date: entry.convertedDate ?? Date(),
                                             images: images,
                                             location: modelLocation,
                                             weather: modelWeather,
                                             tags: [])
                    repo.add(entry: modelEntry)
                }
            }
        }

        // Create the window and set the content view. 
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentCloudKitContainer(name: "OpenDay")
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving and Undo support

    @IBAction func saveAction(_ sender: AnyObject?) {
        let context = persistentContainer.viewContext

        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing before saving")
        }
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Customize this code block to include application-specific recovery steps.
                let nserror = error as NSError
                NSApplication.shared.presentError(nserror)
            }
        }
    }

    func windowWillReturnUndoManager(window: NSWindow) -> UndoManager? {
        return persistentContainer.viewContext.undoManager
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        // Save changes in the application's managed object context before the application terminates.
        let context = persistentContainer.viewContext

        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing to terminate")
            return .terminateCancel
        }

        if !context.hasChanges {
            return .terminateNow
        }

        do {
            try context.save()
        } catch {
            let nserror = error as NSError

            // Customize this code block to include application-specific recovery steps.
            let result = sender.presentError(nserror)
            if result {
                return .terminateCancel
            }
            
            let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
            let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
            let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
            let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
            let alert = NSAlert()
            alert.messageText = question
            alert.informativeText = info
            alert.addButton(withTitle: quitButton)
            alert.addButton(withTitle: cancelButton)

            let answer = alert.runModal()
            if answer == .alertSecondButtonReturn {
                return .terminateCancel
            }
        }
        // If we got here, it is time to quit.
        return .terminateNow
    }

    func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
        switch item.action {
        case #selector(delete(_:)):
            return entriesStore.hasSelectedEntry
        default:
            return true
        }
    }

    @IBAction func delete(_ sender: AnyObject) {
        entriesStore.deleteSelectedEntry()
    }
}
