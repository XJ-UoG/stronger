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
                Text("\(workout.name!) at \(workout.timestamp!, formatter: workoutTimeFormatter)")
                    .font(.title)
                if let exercises = workout.exercises {
                    List {
                        ForEach(groupExerciseByName(exercises), id: \.0) { groupName, groupExercises in
                            Section(header: Text("\(groupName)")){
                                ForEach(groupExercises.sorted { $0.sortID < $1.sortID }) { exercise in
                                    ExerciseListView(exercise: exercise)
                                }
                            }
                        }
                    }
                } else {
                    Text("No exercises found")
                }
            }
            .padding()
            .toolbar {
                ToolbarItem {
                    Button(action: {isPresentForm = true}) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
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
