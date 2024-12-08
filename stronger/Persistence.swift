//
//  Persistence.swift
//  stronger
//
//  Created by Tan Xin Jie on 4/12/24.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        for i in 0..<7 {
            if i % 2 == 0 {
                let newWorkout = Workout(context: viewContext)
                newWorkout.timestamp = Date().addingTimeInterval(TimeInterval(-i * 24 * 60 * 60))
                newWorkout.name = "Upper Workout"
                
                let exercise1 = Exercise(context: viewContext)
                exercise1.name = "Push-Ups"
                exercise1.reps = "30"
                exercise1.weight = "0"
                exercise1.sortID = 1
                newWorkout.addToExercises(exercise1)
                
                let exercise2 = Exercise(context: viewContext)
                exercise2.name = "Pull-Ups"
                exercise2.reps = "15"
                exercise2.weight = "0"
                exercise2.sortID = 2
                newWorkout.addToExercises(exercise2)
                
            } else {
                let newWorkout2 = Workout(context: viewContext)
                newWorkout2.timestamp = Date().addingTimeInterval(TimeInterval(-i * 24 * 60 * 60))
                newWorkout2.name = "Lower Workout"
                
                let exercise3 = Exercise(context: viewContext)
                exercise3.name = "Squats"
                exercise3.reps = "20"
                exercise3.weight = "50"
                exercise3.sortID = 1
                newWorkout2.addToExercises(exercise3)
                
                let exercise4 = Exercise(context: viewContext)
                exercise4.name = "Deadlifts"
                exercise4.reps = "10"
                exercise4.weight = "100"
                exercise4.sortID = 2
                newWorkout2.addToExercises(exercise4)
            }
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        return result
    }()


    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "stronger")
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
    
    func clearData() {
        let entityNames = container.managedObjectModel.entities.map { $0.name! }
        
        for entityName in entityNames {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try container.viewContext.execute(deleteRequest)
                print("CoreData cleared")
            } catch {
                let nsError = error as NSError
                print("Failed to delete data for entity \(entityName): \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
