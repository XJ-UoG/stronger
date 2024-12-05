//
//  WorkoutView.swift
//  stronger
//
//  Created by Tan Xin Jie on 5/12/24.
//

import SwiftUI

struct WorkoutView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var workout: Workout
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Text("\(workout.name!) at \(workout.timestamp!, formatter: workoutTimeFormatter)")
                        .font(.title)
                    if let exercises = workout.exercises as? Set<Exercise> {
                        ForEach(Array(exercises), id: \.self) { exercise in
                            HStack {
                                Text(exercise.name ?? "Unnamed Exercise")
                                HStack {
                                    TextField(
                                        "0",
                                        text: Binding(
                                            get: {
                                                exercise.weight ?? "0"
                                            },
                                            set: { newValue in
                                                exercise.weight = newValue
                                            }
                                        )
                                    )
                                    .onSubmit {
                                        do {
                                            try viewContext.save()
                                        } catch {
                                            let nsError = error as NSError
                                            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                                        }
                                    }
                                    .textFieldStyle(.roundedBorder)
                                    Text("kg")
                                }
                                Spacer(minLength: 50)
                                HStack {
                                    TextField(
                                        "0",
                                        text: Binding(
                                            get: {
                                                exercise.reps ?? "0"
                                            },
                                            set: { newValue in
                                                exercise.reps = newValue
                                            }
                                        )
                                    )
                                    .onSubmit {
                                        do {
                                            try viewContext.save()
                                        } catch {
                                            let nsError = error as NSError
                                            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                                        }
                                    }
                                    .textFieldStyle(.roundedBorder)
                                    Text("reps")
                                }
                            }
                            .padding()
                            
                        }
                    } else {
                        Text("No exercises found")
                    }
                }
                .padding()
                .toolbar {
                    ToolbarItem {
                        Button(action: addExerciseToWorkout) {
                            Label("Add Item", systemImage: "plus")
                        }
                    }
                }
            }
        }
    }
    
    private func addExerciseToWorkout() {
        print("Adding exercise to workout...")
        
        withAnimation {
            let exercise1 = Exercise(context: viewContext)
            exercise1.name = "Push-Ups"
            exercise1.reps = "15"
            exercise1.weight = "0"
            workout.addToExercises(exercise1)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    // Group workouts by the numbers of days ago
    private func groupExerciseByName(_ exercises: [Exercise]) -> [String: [Exercise]] {
        return Dictionary(grouping: exercises) { exercise in
            exercise.name ?? "Unknown"
        }
        //
        //        // Sort the grouped workouts by days ago, convert dictionary to tuple (required to be used with ForEach List)
        //        let sortedGroups = grouped.sorted { $0.key < $1.key }
        //        return sortedGroups
    }
    
    private func getDaysAgoString(_ input: Int) -> String {
        return input == 0 ? "Today" : input == 1 ? "Yesterday" : "\(input) days ago"
    }
}

#Preview {
    let viewContext = PersistenceController.preview.container.viewContext
    let newWorkout = Workout(context: viewContext)
    newWorkout.timestamp = Date()
    newWorkout.name = "Workout"
    let exercise1 = Exercise(context: viewContext)
    exercise1.name = "Push-Ups"
    exercise1.reps = "15"
    exercise1.weight = "0"
    newWorkout.addToExercises(exercise1)
    
    return WorkoutView(workout: newWorkout).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
