import SwiftUI

struct JournalDetailView: View {
    @EnvironmentObject var dataManager: JournalDataManager
    @Environment(\.presentationMode) var presentationMode
    @State private var editedEntry: JournalEntry
    @State private var isEditing: Bool = false

    init(entry: JournalEntry) {
        _editedEntry = State(initialValue: entry)        

    }

    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    editingTitle
                    Divider()
                    moodSection
                    Divider()
                    tagSection
                    Divider()
                    contentSection
                }
                .padding()
                .animation(.easeInOut, value: isEditing)
            }
        }
        .navigationTitle("Journal Entry")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) { backButton }
            ToolbarItem(placement: .navigationBarTrailing) { editSaveButton }
        }
    }
    
    private var editingTitle: some View {
        TextField("Title", text: $editedEntry.title)
            .font(.title)
            .padding()
            .background(isEditing ? Color.white : Color.clear)
            .cornerRadius(8)
            .disabled(!isEditing)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isEditing ? Color.blue : Color.clear, lineWidth: 2)
            )
    }
    
    private var moodSection: some View {
        HStack {
            if isEditing {
                MoodPicker(selectedMood: $editedEntry.mood)
            } else {
                Text("Mood: \(editedEntry.mood)")
            }
        }
    }
    
    private var tagSection: some View {
        TagEditor(tags: $editedEntry.tags)
            .opacity(isEditing ? 1 : 0)
    }
    
    private var contentSection: some View {
        TextEditor(text: $editedEntry.content)
            .frame(minHeight: 200)
            .padding()
            .background(Color.white)
            .cornerRadius(8)
            .disabled(!isEditing)
    }
    
    private var editSaveButton: some View {
        Button(isEditing ? "Save" : "Edit") {
            withAnimation {
                isEditing.toggle()
                if !isEditing {
                    saveChanges()
                }
            }
        }
    }
    
    private var backButton: some View {
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
            }
        }
    
    private func saveChanges() {
        guard let index = dataManager.journalEntries.firstIndex(where: { $0.id == editedEntry.id }) else { return }
        dataManager.journalEntries[index] = editedEntry
        dataManager.saveJournalEntries()
    }
}

struct MoodPicker: View {
    @Binding var selectedMood: String
    let moods = ["Happy", "Sad", "Excited", "Calm", "Anxious"]

    var body: some View {
        Picker("Select Mood", selection: $selectedMood) {
            ForEach(moods, id: \.self) { mood in
                Text(mood).tag(mood)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }
}

struct TagEditor: View {
    @Binding var tags: [String]
    @State private var newTag: String = ""

    var body: some View {
        VStack {
            ForEach(tags, id: \.self) { tag in
                Text(tag)
                    .padding(.all, 5)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(5)
            }
            HStack {
                TextField("New Tag", text: $newTag)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: addTag) {
                    Text("Add")
                }
            }
        }
    }

    private func addTag() {
        let cleanedTag = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
        if !cleanedTag.isEmpty && !tags.contains(cleanedTag) {
            tags.append(cleanedTag)
            newTag = "" // Reset the input field
        }
    }
}

struct TagCloudView: View {
    var tags: [String]
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(tags, id: \.self) { tag in
                Text(tag)
                    .padding(.all, 5)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(5)
            }
        }
    }
}

