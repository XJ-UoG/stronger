//
//  ContentView.swift
//  stronger
//
//  Created by Tan Xin Jie on 4/12/24.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Workout.timestamp, ascending: false)],
        animation: .default)
    private var items: FetchedResults<Workout>

    var body: some View {
        TabView {
            NavigationView {
                List {
                    ForEach(groupWorkoutByDay(items), id: \.0) { daysAgo, workouts in
                        Section(header: Text("\(getDaysAgoString(daysAgo))")) {
                            ForEach(workouts) { workout in
                                NavigationLink {
                                    WorkoutView(workout: workout)
                                } label: {
                                    VStack (alignment: .leading) {
                                        Text(workout.name!)
                                            .font(.headline)
                                        Text(workout.timestamp!, formatter: workoutTimeFormatter)
                                    }
                                }
                            }
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                    ToolbarItem {
                        Button(action: addItem) {
                            Label("Add Item", systemImage: "plus")
                        }
                    }
                }
                Text("Select an item")
            }
            .tabItem {
                Label("Workout", systemImage: "square.and.pencil")
            }
            Color.red
                .tabItem{
                    Label("Map", systemImage: "map")
                }
        }
    }

    private func addItem() {
        withAnimation {
//            let newItem = Workout(context: viewContext)
//            newItem.timestamp = Date()

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

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

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
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
