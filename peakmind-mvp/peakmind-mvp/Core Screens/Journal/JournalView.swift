import SwiftUI
import Firebase

import JournalingSuggestions

struct JournalView: View {
    @EnvironmentObject var dataManager: JournalDataManager
    @EnvironmentObject var viewModel : AuthViewModel
    
    @Binding var suggestion: JournalingSuggestion?
    
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var mood: String = "Neutral"
    @State private var tags: [String] = []
    @State private var entryDate: Date = Date()
    @State private var showingMoodPicker = false
    @State private var tagInput: String = ""
    
    @State private var suggestionPhotos: [JournalingSuggestion.Photo] = []
    
    @Environment(\.presentationMode) var presentationMode
    
    
    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                ScrollView {
                    VStack(alignment: .leading) {
                        Text("Add Journal Entry")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        titleField
                        datePicker
                        moodPicker
                        tagsView
                        contentEditor
                        
                        ScrollView(.horizontal) {
                            HStack {
                                if let suggestion = suggestion {
                                    ForEach(suggestionPhotos, id: \.photo) { item in
                                        AsyncImage(url: item.photo) { image in
                                            image.image?
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                        }
                                        .frame(maxHeight: 200)
                                    }
                                } else {
                                    Text("No suggestion available")
                                }
                            }
                        }.onAppear {
                            loadPhotos()
                        }
                        
                    }
                    .padding(.horizontal)
                }
            }
            .navigationBarItems(leading: cancelButton, trailing: saveButton)
            .sheet(isPresented: $showingMoodPicker) {
                MoodPickerView(selectedMood: $mood)
            }
        }
        .environment(\.colorScheme, .light)
        
    }
    
    private func loadPhotos() {
        if let suggestion = suggestion {
            Task {
                suggestionPhotos = await suggestion.content(forType: JournalingSuggestion.Photo.self)
                print("suggestion loaded")
            }
        }
    }
                    
    
    private var titleField: some View {
        TextField("Title", text: $title)
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
            .onAppear {
                if (suggestion != nil) {
                    title = suggestion!.title
                    
                }
            }
    }
    
    private var datePicker: some View {
        DatePicker("Date", selection: $entryDate, displayedComponents: .date)
            .padding()
            .background(Color.white)
            .cornerRadius(10)
    }
    
    private var moodPicker: some View {
        HStack {
            Text("Mood: \(mood)")
            Spacer()
            Menu {
                ForEach(["Happy", "Sad", "Excited", "Calm", "Anxious", "Neutral"], id: \.self) { mood in
                    Button(mood) {
                        self.mood = mood
                    }
                }
            } label: {
                Image(systemName: "chevron.down.circle.fill")
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }
    
    private var tagsView: some View {
        VStack {
            HStack {
                TextField("Enter Tags", text: $tagInput, onCommit: addTag)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: addTag) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding()
            
            WrapView(tags: $tags, onDelete: { tag in
                self.removeTag(tag)
            })
        }
    }
    
    private func addTag() {
        let cleanedTag = tagInput.trimmingCharacters(in: .whitespacesAndNewlines)
        if !cleanedTag.isEmpty && !tags.contains(cleanedTag) {
            tags.append(cleanedTag)
            tagInput = ""
        }
    }
    
    private func removeTag(_ tag: String) {
        tags.removeAll(where: { $0 == tag })
    }
    
    private var contentEditor: some View {
        TextEditor(text: $content)
            .frame(height: 200)
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
    }
    
    private var cancelButton: some View {
        Button("Cancel") { presentationMode.wrappedValue.dismiss() }
    }
    
    private var saveButton: some View {
        Button("Save") { saveEntry() }
    }
    
    private func saveEntry() {
        let newEntry = JournalEntry(id: "", title: title, content: content, date: entryDate, mood: mood, tags: tags)
        let db = Firestore.firestore()
        guard let currentUser = viewModel.currentUser else {
            print("Current user not found.")
            return
        }
        
        let userJournalRef = db.collection("users").document(currentUser.id).collection("journal_entries").document()
        
        userJournalRef.setData([
            "id": "\(userJournalRef.documentID)",
            "title": newEntry.title,
            "content": newEntry.content,
            "date": Timestamp(date: newEntry.date),
            "mood": newEntry.mood,
            "tags": newEntry.tags
        ]) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Document added with ID: \(userJournalRef.documentID)")
            }
        }
        //dataManager.addJournalEntry(newEntry)
        presentationMode.wrappedValue.dismiss()
    }
}

struct MoodPickerView: View {
    @Binding var selectedMood: String
    let moods = ["Happy", "Sad", "Excited", "Calm", "Anxious", "Neutral"]
    
    var body: some View {
        List(moods, id: \.self) { mood in
            Button(mood) {
                selectedMood = mood
            }
            .buttonStyle(PlainButtonStyle()) // Ensure button does not highlight
        }
    }
}




struct FilledButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .background(configuration.isPressed ? Color.blue.opacity(0.8) : Color.blue)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .padding(.horizontal)
    }
}


struct WrapView: View {
    @Binding var tags: [String]
    let onDelete: (String) -> Void
    
    private let tagSpacing: CGFloat = 8
    private let lineSpacing: CGFloat = 8
    private var totalHorizontalPadding: CGFloat { tagSpacing * 2 }
    
    var body: some View {
        VStack(alignment: .leading, spacing: lineSpacing) {
            ForEach(calculateRows(), id: \.self) { rowTags in
                HStack(spacing: tagSpacing) {
                    ForEach(rowTags, id: \.self) { tag in
                        TagView(tag: tag)
                            .onTapGesture { self.onDelete(tag) }
                    }
                }
            }
        }
        .padding(.horizontal, tagSpacing)
    }
    
    private func calculateRows() -> [[String]] {
        var rows: [[String]] = [[]]
        var currentRowWidth: CGFloat = 0
        
        for tag in tags {
            let tagWidth = self.width(for: tag)
            
            // Check if adding this tag to the current row would exceed the available width
            if currentRowWidth + tagWidth + totalHorizontalPadding > UIScreen.main.bounds.width {
                // Start a new row
                rows.append([tag])
                currentRowWidth = tagWidth
            } else {
                // Add the tag to the current row
                rows[rows.count - 1].append(tag)
                currentRowWidth += tagWidth + tagSpacing
            }
        }
        
        return rows
    }
    
    // Estimate the width of a tag based on its text content
    private func width(for tag: String) -> CGFloat {
        let font = UIFont.systemFont(ofSize: 14) // Adjust font size as needed
        let attributes = [NSAttributedString.Key.font: font]
        let size = (tag as NSString).size(withAttributes: attributes)
        return size.width + 32 // Add some padding inside the tag view
    }
}

struct TagView: View {
    var tag: String
    
    var body: some View {
        Text(tag)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(5)
    }
}
