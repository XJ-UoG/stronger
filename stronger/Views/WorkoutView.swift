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
    
    // Variables for ExerciseFormView
    @State private var isPresentForm = false
    @State private var selectedExerciseName = ""
    
    var body: some View {
        NavigationView {
            VStack {
                Text("\(workout.name!)")
                    .font(.title)
                Text("\(workout.timestamp!, formatter: workoutTimeFormatter)")
                    .font(.subheadline)
                    .fontWeight(.light)
                if let exercises = workout.exercises {
                    List {
                        ForEach(groupExerciseByName(exercises), id: \.0) { groupName, groupExercises in
                            Section(header: HStack {
                                Text("\(groupName)")
                                Spacer()
                                Button(action: {addExerciseToWorkout(name: groupName)}) {
                                    Image(systemName: "plus")
                                }
                            }){
                                let groupExercises = groupExercises.sorted { $0.sortID < $1.sortID }
                                ForEach(groupExercises) { exercise in
                                    ExerciseListView(exercise: exercise)
                                }
                                .onDelete(perform: { indexSet in
                                    deleteExercise(offsets: indexSet, exercises: groupExercises)
                                })
                            }
                        }
                        Button(action: {
                            isPresentForm = true
                        }) {
                            Text("Add New Exercise")
                                .foregroundColor(.blue)
                                .padding()
                                .frame(maxWidth: .infinity)
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                                .foregroundColor(.blue)
                        )
                        .listRowBackground(Color.clear)
                    }
                } else {
                    Text("Empty Workout")
                }
            }
//            .toolbar {
//                ToolbarItem {
//                    Button(action: {isPresentForm = true}) {
//                        Label("Add Item", systemImage: "plus")
//                    }
//                }
//            }
            .sheet(isPresented: $isPresentForm, content: {
                ExerciseFormView(isPresentForm: $isPresentForm, addExerciseToWorkout: addExerciseToWorkout)
            })
        }
    }
    
    private func addExerciseToWorkout(name: String) {
        print("Adding \(name) exercise to workout...")
        
        withAnimation {
            let exercise1 = Exercise(context: viewContext)
            exercise1.name = name
            exercise1.reps = "15"
            exercise1.weight = "0"
            exercise1.sortID = getNextSortID()
            workout.addToExercises(exercise1)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func deleteExercise(offsets: IndexSet, exercises: [Exercise]) {
        withAnimation {
            offsets.map { exercises[$0] }.forEach(viewContext.delete)
            
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
    
    // Group exercises by their names
    private func groupExerciseByName(_ exercises: NSSet) -> [(String, [Exercise])] {
        let exerciseArray = exercises.allObjects as? [Exercise] ?? []
        let grouped = Dictionary(grouping: exerciseArray) { exercise in
            exercise.name ?? "Unknown"
        }
        
        return grouped.sorted { $0.key < $1.key }
    }
    
    func getNextSortID() -> Int16 {
        if let exercises = workout.exercises as? Set<Exercise> {
            let sortedExercises = exercises.sorted { ($0.sortID) > ($1.sortID) }
            
            if let lastExercise = sortedExercises.first?.sortID {
                return lastExercise + 1
            } else {
                return 1
            }
        }
        return 1
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
    exercise1.sortID = 1
    newWorkout.addToExercises(exercise1)
    
    return WorkoutView(workout: newWorkout).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

struct ExerciseListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var exercise: Exercise
    
    var body: some View {
        HStack {
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
                .fixedSize()
                Text("kg")
            }
            Spacer()
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
                .fixedSize()
                Text("reps")
            }
            Spacer()
            Toggle(isOn: $exercise.isCompleted){}
                .onChange(of: exercise.isCompleted) {
                    do {
                        try viewContext.save()
                    } catch {
                        let nsError = error as NSError
                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                    }
                }
                .toggleStyle(CheckToggleStyle())
        }
        .padding(5)
    }
}

struct CheckToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            Label {
                configuration.label
            } icon: {
                Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(configuration.isOn ? Color.accentColor : .secondary)
                    .accessibility(label: Text(configuration.isOn ? "Checked" : "Unchecked"))
                    .imageScale(.large)
            }
        }
        .buttonStyle(.plain)
    }
}
