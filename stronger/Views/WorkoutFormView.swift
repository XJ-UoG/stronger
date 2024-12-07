//
//  WorkoutFormView.swift
//  stronger
//
//  Created by Tan Xin Jie on 7/12/24.
//

import SwiftUI

struct WorkoutFormView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \Workout.timestamp, ascending: false)],
//        animation: .default)
//    private var items: FetchedResults<Workout>
//
    @Binding var isPresentForm:  Bool
    
    @State private var workoutName: String = ""
    @State private var exerciseNames: [String] = ["", ""]
    @State private var workoutDate = Date()
    
    var addNewWorkout: (String, Date, [String]) -> Void
    
    private var isFormValid: Bool {
           !workoutName.isEmpty
       }
    
    var body: some View {
        VStack {
            Form {
                Section (header: Text("Workout Template")) {
                    Picker("Selected: ", selection: $workoutName) {
                        // Map exercises into set of exercises names
//                        ForEach(Array(Set(exercises.compactMap { $0.name })), id: \.self) { name in
//                            Text(name)
//                        }
                    }
//                    .onAppear {
//                        if let firstName = exercises.first?.name {
//                            exerciseName = firstName
//                        }
//                    }
                }
                
                Section (header: Text("Workout Details")) {
                    TextField(
                        "My New Workout",
                        text: $workoutName
                    )
                    DatePicker(
                        "Date",
                        selection: $workoutDate,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }
                
                Section (header: Text("Exercises")) {
                    ForEach(exerciseNames.indices, id: \.self) { index in
                        TextField(
                            "Exercise \(index + 1)",
                            text: Binding(
                                get: { exerciseNames[index] },
                                set: { exerciseNames[index] = $0 }
                            )
                        )
                        .onSubmit {
                            if !exerciseNames.contains("") {
                                exerciseNames.append("")
                            }
                        }
                    }
                }
                
                Button(action: {
                    isPresentForm = false
                    let validExerciseNames = exerciseNames
                        .map { $0.trimmingCharacters(in: .whitespaces) }
                        .filter { !$0.isEmpty }
                    addNewWorkout(workoutName, workoutDate, validExerciseNames)
                }) {
                    Label("Add Workout", systemImage: "plus")
                }
                .disabled(!isFormValid)
            }
        }
    }
    
    
}

#Preview {
    WorkoutFormView(isPresentForm: .constant(true), addNewWorkout: { name, date, exerciseNames in print(name, date, exerciseNames)})
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
