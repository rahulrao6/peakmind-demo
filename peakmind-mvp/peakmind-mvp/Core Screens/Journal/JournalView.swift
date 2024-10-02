import SwiftUI

struct JournalView: View {
    @State private var isPromptAnswered = false
    @State private var currentQuestion: String = "What made you smile today?"
    @State private var journalEntries: [JournalEntry] = []
    @State private var isAddingEntry = false
    @State private var showJournalPrompt = false
    @EnvironmentObject var viewModel: AuthViewModel // Inject the AuthViewModel
    
    private let dailyQuestions: [String] = [
        "What made you smile today?", "What is one thing you are grateful for?", "What was your biggest challenge today?",
        "How did you overcome a difficult situation recently?", "What is something you’re proud of this week?",
        "What does self-care mean to you?", "What do you need more of in your life right now?",
        "How can you prioritize your mental health today?", "What is one small thing you can do to improve your mood?",
        "What was your favorite part of the day?", "What is one thing you want to work on?", "How do you handle stress?",
        "What’s one thing you want to let go of?", "How can you show kindness to yourself today?",
        "What is something you’re looking forward to?", "What is one lesson you learned this week?",
        "How do you recharge when you feel drained?", "What does a perfect day look like to you?",
        "What are three things you love about yourself?", "How do you practice mindfulness in your daily routine?",
        "When was the last time you felt truly at peace?", "What is one goal you want to achieve this month?",
        "How do you comfort yourself when things are tough?", "What does happiness mean to you?",
        "How do you deal with negative emotions?", "What’s a compliment you can give yourself today?",
        "What does success look like for you?", "How do you stay grounded during stressful times?",
        "What do you need to forgive yourself for?", "How do you celebrate small victories?",
        "What is one thing that brings you joy?", "How do you make time for self-care?",
        "What’s one thing you would like to improve about your daily routine?", "How do you express gratitude in your life?",
        "What do you love most about your personality?", "How can you be more present in your daily life?",
        "What is one habit you’d like to develop?", "What do you appreciate about the people in your life?",
        "How do you nurture your relationships?", "What does emotional balance look like for you?",
        "How can you manage your time better?", "What is one activity that helps you feel calm?",
        "How do you support your mental health on hard days?", "What is your favorite way to relax?",
        "How can you add more fun to your life?", "What does feeling ‘in control’ mean to you?",
        "How do you process your emotions?", "What makes you feel confident?", "How can you show yourself love today?",
        "Who has the biggest influence on your life?"
    ]
    var body: some View {
        NavigationStack {
            ZStack {
                // Updated background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "112864")!, Color(hex: "23429a")!]),
                    startPoint: .bottom,
                    endPoint: .top
                )
                .edgesIgnoringSafeArea(.all)
                
                VStack(alignment: .leading) {
                    Text("Your Journal")
                        .font(.custom("SFProText-Heavy", size: 34))
                        .foregroundColor(.white)
                        .padding(.top, 50)
                        .padding(.leading, 20)
                    
                    // Daily Prompt Button
                    Button(action: {
                        currentQuestion = dailyQuestions.randomElement() ?? "How do you feel today?"
                        showJournalPrompt = true
                    }) {
                        Text(isPromptAnswered ? "Daily Prompt Answered!" : "Answer Your Daily Prompt")
                            .font(.custom("SFProText-Bold", size: 18))
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(isPromptAnswered ? Color.gray : Color(hex: "b0e8ff")!)
                            .cornerRadius(10)
                            .padding(.horizontal, 20)
                    }
                    .disabled(isPromptAnswered)
                    .padding(.bottom, 20)
                    
                    
                    // Journal Entries Log
                    ScrollView {
                        ForEach(journalEntries) { entry in
                            NavigationLink(destination: JournalDetailView(entry: .constant(entry))) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(entry.question)
                                            .font(.custom("SFProText-Bold", size: 17))
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.leading)
                                            .lineLimit(nil)
                                            .fixedSize(horizontal: false, vertical: true)
                                            .frame(width: 320, alignment: .leading)
                                        
                                        Text(entry.date, style: .date)
                                            .font(.custom("SFProText-Bold", size: 12))
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding()
                                .background(Color(hex: "0b1953")!)
                                .cornerRadius(12)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 10)
                                .frame(maxWidth: .infinity)
                            }
                        }
                    }
                    
                    Spacer()
                }

                // Floating Add Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            isAddingEntry = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color(hex: "b0e8ff")!)
                                .clipShape(Circle())
                                .shadow(radius: 10)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $isAddingEntry) {
                AddJournalEntryView(journalEntries: $journalEntries)
                    .onDisappear {
                        Task {
                            try await viewModel.saveJournalEntry(entry: journalEntries.last!)
                        }
                    }
            }
            .fullScreenCover(isPresented: $showJournalPrompt) {
                JournalPromptView(
                    question: currentQuestion,
                    isPromptAnswered: $isPromptAnswered,
                    journalEntries: $journalEntries
                )
                .onDisappear {
                    Task {
                        try await viewModel.saveJournalEntry(entry: journalEntries.last!)
                    }
                }
            }
            .onAppear {
                viewModel.fetchJournalEntries { entries in
                    self.journalEntries = entries
                    checkIfPromptAnswered()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func checkIfPromptAnswered() {
        guard let lastEntry = journalEntries.first else {
            isPromptAnswered = false
            return
        }
        let calendar = Calendar.current
        if calendar.isDateInToday(lastEntry.date) {
            isPromptAnswered = true
        } else {
            isPromptAnswered = false
        }
    }
}

// Journal Prompt View where user answers the prompt
struct JournalPromptView: View {
    var question: String
    @Binding var isPromptAnswered: Bool
    @Binding var journalEntries: [JournalEntry]
    
    @State private var userAnswer = ""
    @FocusState private var isTextEditorFocused: Bool
    @State private var isTyping: Bool = false
    
    @Environment(\.dismiss) var dismiss // For dismissing the view
    
    var body: some View {
        ZStack {
            // Background with Linear Gradient
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "112864")!, Color(hex: "23429a")!]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 8) {
                HStack {
                    Text(question)
                        .font(.custom("SFProText-Heavy", size: isTextEditorFocused ? 20 : 35)) // Change font size when focused
                        .foregroundColor(.white) // Change text to black
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .padding(.horizontal, 30)
                        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 0)
                    
                    Spacer() // Ensures the text stays left-aligned
                }
                .padding(.bottom, 20)

                // Input box
                ZStack(alignment: .topLeading) {
                    if userAnswer.isEmpty {
                        Text("Start typing here...")
                            .foregroundColor(Color.gray.opacity(0.5))
                            .padding(.vertical, 14)
                            .padding(.horizontal, 16)
                    }

                    TextEditor(text: $userAnswer)
                        .font(.custom("SFProText-Bold", size: 16))
                        .foregroundColor(.black) // Set text color to black for better contrast
                        .focused($isTextEditorFocused)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .frame(height: 300, alignment: .topLeading)
                        .scrollContentBackground(.hidden) // Disable dark mode background
                        .background(Color.white) // Set text editor background to white
                        .cornerRadius(10)
                        .onChange(of: userAnswer) { newValue in
                            withAnimation {
                                isTyping = !userAnswer.isEmpty
                            }
                            if newValue.count > 500 {
                                userAnswer = String(newValue.prefix(500))
                            }
                        }

                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text("\(userAnswer.count)/500")
                                .font(.custom("SFProText-Bold", size: 12))
                                .foregroundColor(.black)
                                .padding(8)
                                .background(Color.black.opacity(0.2))
                                .cornerRadius(8)
                                .padding(8)
                        }
                    }
                }
                .frame(height: 300)
                .padding(.horizontal, 20)

                Button(action: {
                    isPromptAnswered = true
                    let entry = JournalEntry(question: question, answer: userAnswer, date: Date())
                    journalEntries.append(entry)
                    dismiss() // Dismiss view after submission
                }) {
                    Text("Submit")
                        .font(.custom("SFProText-Bold", size: 20))
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "b0e8ff")!)
                        .cornerRadius(10)
                        .shadow(color: userAnswer.isEmpty ? Color.clear : Color.white.opacity(0.7), radius: 10, x: 0, y: 0)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .disabled(userAnswer.isEmpty)
            }
        }
    }
}

// Model for Journal Entry
struct JournalEntry: Identifiable {
    var id: String
    var question: String
    var answer: String
    var date: Date
    
    init(id: String = UUID().uuidString, question: String, answer: String, date: Date) {
        self.id = id
        self.question = question
        self.answer = answer
        self.date = date
    }
}


// Journal Entry Detail View
struct JournalDetailView: View {
    @Binding var entry: JournalEntry
    @State private var isEditing = false // Track if the user is in edit mode
    @State private var editedQuestion: String = ""
    @State private var editedAnswer: String = ""
    @EnvironmentObject var viewModel: AuthViewModel // Inject the AuthViewModel

    var body: some View {
        ZStack {
            // Background with Linear Gradient
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "112864")!, Color(hex: "23429a")!]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    // Display the question
                    Text(isEditing ? editedQuestion : entry.question)
                        .font(.custom("SFProText-Heavy", size: 29))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                    
                    Spacer()

                    // Edit button (top-right, next to question)
                    Button(action: {

                        update()
                    }) {
                        Text(isEditing ? "Save" : "Edit")
                            .font(.custom("SFProText-Bold", size: 16))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color(hex: "b0e8ff")!)
                            .cornerRadius(10)
                    }
                    .padding(.trailing, 20)
                }
                
                if isEditing {
                    // Editable fields for editing the journal entry
                    TextField("Edit question", text: $editedQuestion)
                        .font(.custom("SFProText-Bold", size: 20))
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .foregroundColor(.black)
                        .padding(.horizontal, 20)
                    
                    TextEditor(text: $editedAnswer)
                        .font(.custom("SFProText-Bold", size: 16))
                        .foregroundColor(.black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .frame(height: 200, alignment: .topLeading)
                        .background(Color.white)
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                } else {
                    // Display the journal entry when not in edit mode
                    Text(entry.answer)
                        .font(.custom("SFProText-Bold", size: 16))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                }
                
                Spacer()
            }
        }
        // Disable dark mode by setting the color scheme to light
        .preferredColorScheme(.light)
    }
    func update() {
        if isEditing {
            var entryt = JournalEntry(question: editedQuestion, answer: editedAnswer, date: entry.date)
            Task{
               try await viewModel.updateJournalEntry(entry: entryt)
                viewModel.fetchJournalEntries { entries in
                    print(entries)
                }
            }
        } else {
            // Prepare fields for editing
            editedQuestion = entry.question
            editedAnswer = entry.answer
        }
        isEditing.toggle()
    }
}

import SwiftUI

struct AddJournalEntryView: View {
    @Binding var journalEntries: [JournalEntry]
    
    @State private var title = ""
    @State private var entry = ""
    @FocusState private var isTextEditorFocused: Bool
    @State private var isTyping: Bool = false
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "112864")!, Color(hex: "23429a")!]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                
                // Top title
                HStack {
                    Text("Add Journal Entry")
                        .font(.custom("SFProText-Heavy", size: 34))
                        .foregroundColor(.white)
                        .padding(.leading, 20)
                        .padding(.top, 50)
                    
                    Spacer() // Align the text to the left
                }

                // Title input with custom placeholder
                ZStack(alignment: .leading) {
                    if title.isEmpty {
                        Text("Enter title here...")
                            .font(.custom("SFProText-Bold", size: 16)) // Font set to SFProText-Bold
                            .foregroundColor(Color.white.opacity(0.7)) // Placeholder color
                            .padding(.leading, 36) // Ensuring left margin alignment
                            .padding(.vertical, 12)
                    }
                    
                    TextField("", text: $title)
                        .font(.custom("SFProText-Bold", size: 16)) // Font set to SFProText-Bold
                        .padding()
                        .background(Color.white.opacity(0.1)) // Light background in dark mode
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                        .foregroundColor(.white) // Text color for dark mode
                }
                
                // Entry text box with custom placeholder
                ZStack(alignment: .topLeading) {
                    if entry.isEmpty {
                        Text("Enter text here...")
                            .font(.custom("SFProText-Bold", size: 16)) // Font set to SFProText-Bold
                            .foregroundColor(Color.white.opacity(0.7)) // Placeholder color
                            .padding(.top, 14)
                            .padding(.leading, 16) // Ensuring left margin alignment
                    }

                    TextEditor(text: $entry)
                        .font(.custom("SFProText-Bold", size: 16)) // Font set to SFProText-Bold
                        .foregroundColor(.white) // Text color for dark mode
                        .focused($isTextEditorFocused)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .frame(height: 200, alignment: .topLeading)
                        .scrollContentBackground(.hidden) // Remove default background
                        .background(Color.white.opacity(0.1)) // Light background in dark mode
                        .cornerRadius(10)
                        .onChange(of: entry) { newValue in
                            withAnimation {
                                isTyping = !entry.isEmpty
                            }
                            if newValue.count > 500 {
                                entry = String(newValue.prefix(500))
                            }
                        }

                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text("\(entry.count)/500")
                                .font(.custom("SFProText-Bold", size: 12))
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.black.opacity(0.2))
                                .cornerRadius(8)
                                .padding(8)
                        }
                    }
                }
                .frame(height: 200)
                .padding(.horizontal, 20)

                // Add Entry Button
                Button(action: {
                    let newEntry = JournalEntry(question: title, answer: entry, date: Date())
                    journalEntries.append(newEntry)
                    dismiss()
                    title = ""
                    entry = ""
                }) {
                    Text("Add Entry")
                        .font(.custom("SFProText-Bold", size: 18))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "b0e8ff")!)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 20)
                .disabled(title.isEmpty || entry.isEmpty)
            }
        }
    }
}



// Preview
struct JournalView_Previews: PreviewProvider {
    static var previews: some View {
        JournalView()
    }
}
