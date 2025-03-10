//
//  ContentView.swift
//  stronger
//
//  Created by Tan Xin Jie on 4/12/24.
//

import SwiftUI
import CoreData

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Workout.timestamp, ascending: false)],
        animation: .default)
    private var items: FetchedResults<Workout>
    
    // Variables for ExerciseFormView
    @State private var isPresentForm = false
    @State private var selectedExerciseName = ""
    
    var body: some View {
        TabView {
            NavigationView {
                List {
                    ForEach(groupWorkoutByDay(items), id: \.0) {
                        daysAgo,
                        groups in
                        Section(header: Text("\(getDaysAgoString(daysAgo))")) {
                            ForEach(groups) { workout in
                                NavigationLink {
                                    WorkoutView(workout: workout)
                                } label: {
                                    VStack (alignment: .leading) {
                                        Text(workout.name!)
                                            .font(.headline)
                                        Text(workout.timestamp!, formatter: workoutTimeFormatter)
                                            .font(.footnote)
                                            .fontWeight(.thin)
                                    }
                                }
                            }
                            .onDelete(perform: { indexSet in
                                deleteItems(offsets: indexSet, workout: groups)
                            })
                        }
                    }
                }
                .overlay(Group {
                    if items.isEmpty {
                        Text("No workout found.")
                    }
                })
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                    ToolbarItem {
                        Button(action: {isPresentForm = true}) {
                            Label("Add Item", systemImage: "plus")
                        }
                    }
                }
                Text("Select an item")
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            Color.red
                .tabItem{
                    Label("Social", systemImage: "person.2")
                }
        }
        .sheet(isPresented: $isPresentForm, content: {
            WorkoutFormView(isPresentForm: $isPresentForm, addNewWorkout: addNewWorkout)
        })
    }
    
    private func addItem() {
        withAnimation {
            let newWorkout = Workout(context: viewContext)
            newWorkout.timestamp = Date()
            newWorkout.name = "Workout"
            let exercise1 = Exercise(context: viewContext)
            exercise1.name = "Push-Ups"
            exercise1.reps = "15"
            exercise1.weight = "0"
            exercise1.sortID = 1
            newWorkout.addToExercises(exercise1)
            
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func addNewWorkout(workoutName: String, workoutDate: Date, exerciseNames: [String]) {
        withAnimation {
            let newWorkout = Workout(context: viewContext)
            newWorkout.timestamp = workoutDate
            newWorkout.name = workoutName
            
            for (index, exerciseName) in exerciseNames.enumerated() {
                let exercise = Exercise(context: viewContext)
                exercise.name = exerciseName
                exercise.sortID = Int16(index)
                newWorkout.addToExercises(exercise)
            }
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet, workout: [Workout]) {
        withAnimation {
            offsets.map { workout[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    // Group workouts by the numbers of days ago
    private func groupWorkoutByDay(_ workouts: FetchedResults<Workout>) -> [(Int, [Workout])] {
        let grouped = Dictionary(grouping: workouts) { workout in
            Int(workout.timestamp!.distance(to: Date()) / (24 * 60 * 60))
        }
        
        // Sort the grouped workouts by days ago, convert dictionary to tuple (required to be used with ForEach List)
        let sortedGroups = grouped.sorted { $0.key < $1.key }
        return sortedGroups
    }
    
    private func getDaysAgoString(_ input: Int) -> String {
        return input == 0 ? "Today" : input == 1 ? "Yesterday" : "\(input) days ago"
    }
}

let workoutTimeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .none
    return formatter
}()

#Preview {
    HomeView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
