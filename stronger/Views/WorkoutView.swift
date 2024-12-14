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
    
    // Variables for Expanded Workout Details
    @State private var isWorkoutExpanded = false
    
    // Variables for Expanded Exercise Details
    @State private var isExerciseExpanded = false
    
//    @State private var linkedWorkout: Workout? = nil
    @State private var linkedGroupExercises: [(String, [Exercise])] = []
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text("\(workout.name!)")
                        .font(.title)
                    NavigationLink {
                        WorkoutSearchView { selectedWorkout in
                            workout.linked = selectedWorkout
                        }
                    } label: {
                        Image(systemName: "link")
                    }
                }
                if let linkedWorkout = workout.linked {
                    Text("\(linkedWorkout.name!)")
                }
                if isWorkoutExpanded {
                    HStack {
                        Text("\(workout.timestamp!, formatter: workoutTimeFormatter)")
                        Text("\(workout.timestamp!, style: .time)")
                    }
                    .font(.subheadline)
                    .fontWeight(.light)
                }
                Button(action: {
                    withAnimation (.spring(response: 0.6, dampingFraction: 0.8)){
                        isWorkoutExpanded.toggle()
                    }
                }, label: {
                    Image(systemName: isWorkoutExpanded ? "chevron.up" : "chevron.down")
                        .padding(EdgeInsets(top: 1, leading: 0, bottom: 3, trailing: 0))
                        .foregroundColor(.blue)
                })
            }
            if let exercises = workout.exercises {
                List {
                    ForEach(groupExerciseByName(exercises), id: \.0) { groupName, groupExercises in
                        Section(header: HStack {
                            Text("\(groupName)")
                            Spacer()
                            Button(action: {isExerciseExpanded = !isExerciseExpanded}) {
                                Image(systemName: "chevron.down")
                            }
                        },  footer: VStack {
                            if isExerciseExpanded {
                                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras in porttitor mi. Duis sit amet laoreet ipsum. Praesent tristique purus aliquam justo eleifend, varius semper libero finibus.")
                            } else {
                                Button(action: {addExerciseToWorkout(name: groupName)}) {
                                    Image(systemName: "plus")
                                        .frame(maxWidth: .infinity)
                                }
                            }
                        }
                        ){
                            let groupExercises = groupExercises.sorted { $0.sortID < $1.sortID }
                            // Linked Exercises List
                            if workout.linked != nil{
                                if let exercisesForGroup = linkedGroupExercises.first(where: { $0.0 == groupName })?.1 {
                                    let groupLinkedExercises = exercisesForGroup.sorted { $0.sortID < $1.sortID }
                                    let combinedExercises = combineExercises(groupExercises, groupLinkedExercises)
                                    ForEach(combinedExercises, id: \.self.0?.id) { original, linked in
                                        if let original = original {
                                            ExerciseListView(exercise: original, linked: linked)
                                        }
                                        if let linked = linked {
                                            if isExerciseExpanded {
                                                LinkedExerciseListView(exercise: linked)
                                                    .listRowBackground(Color.gray.opacity(0.3))
                                            }
                                        }
                                    }
                                }
                            } else {
                                ForEach(groupExercises) { exercise in
                                    ExerciseListView(exercise: exercise)
                                }
                                .onDelete(perform: { indexSet in
                                    deleteExercise(offsets: indexSet, exercises: groupExercises)
                                })
                            }
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
        .onAppear {
            if let linkedWorkout = workout.linked {
                self.linkedGroupExercises = groupExerciseByName(linkedWorkout.exercises ?? [])
            } else {
                self.linkedGroupExercises = []
            }
        }
        .sheet(isPresented: $isPresentForm, content: {
            ExerciseFormView(isPresentForm: $isPresentForm, addExerciseToWorkout: addExerciseToWorkout)
        })
        
    }
    
    func combineExercises<T1, T2>(_ array1: [T1], _ array2: [T2]) -> [(T1?, T2?)] {
        let maxCount = max(array1.count, array2.count)
        var result: [(T1?, T2?)] = []
        
        for i in 0..<maxCount {
            let element1 = i < array1.count ? array1[i] : nil
            let element2 = i < array2.count ? array2[i] : nil
            result.append((element1, element2))
        }
        
        return result
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
    
    return NavigationView {
        WorkoutView(workout: newWorkout).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

struct ExerciseListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var exercise: Exercise
    var linked: Exercise?
    
    var body: some View {
        VStack {
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
                    .disabled(exercise.isCompleted)
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
                    .disabled(exercise.isCompleted)
                    .textFieldStyle(.roundedBorder)
                    .fixedSize()
                    Text("reps")
                }
                Spacer()
                if let linked = linked {
                    compareValues(exercise.reps!, linked.reps!)
                }
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
            .listRowBackground(exercise.isCompleted ? Color.blue : Color(UIColor.systemBackground))
            .animation(.easeInOut(duration: 0.2), value: exercise.isCompleted)
            .foregroundColor(exercise.isCompleted ? .secondary : Color(UIColor.label))
        }
    }
    
    private func compareValues(_ s1: String, _ s2: String?) -> some View {
        if let s2 = s2, let v1 = Double(s1), let v2 = Double(s2) {
            if v1 > v2 {
                return Image(systemName: "arrowtriangle.up.fill").foregroundColor(.green)
            } else if v1 < v2 {
                return Image(systemName: "arrowtriangle.down.fill").foregroundColor(.red)
            }
        }
        return Image(systemName: "minus").foregroundColor(.gray)
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
                    .foregroundStyle(configuration.isOn ? Color.white : .secondary)
                    .imageScale(.large)
            }
        }
        .buttonStyle(.plain)
    }
}

struct LinkedExerciseListView: View {
    var exercise: Exercise
    var original: Exercise?
    
    var body: some View {
        VStack {
            HStack {
                HStack {
                    Text(exercise.weight ?? "0")
                    .fixedSize()
                    Text("kg")
                                    
                }
                Spacer()
                HStack {
                    Text(exercise.reps ?? "0")
                    .fixedSize()
                    Text("reps")
                }
                Spacer()
                Image(systemName: "link")
            }
            .padding(5)
        }
    }
}
