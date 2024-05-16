import SwiftUI
import Firebase
import JournalingSuggestions


struct JournalEntriesView: View {
    @EnvironmentObject var dataManager: JournalDataManager
    @EnvironmentObject var viewModel : AuthViewModel
    @State var journalEntries: [JournalEntry] = []
    @State private var showingAddJournalEntryView = false
    @State private var journalSuggestion: JournalingSuggestion?
    @State private var selectedEntry: JournalEntry? = nil


    var body: some View {
        NavigationView {
            ZStack {
                Image("MainBG")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Text("My Journal")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()

                    if journalEntries.isEmpty {
                        EmptyStateView().padding(.top)
                    } else {
                        entriesList
 
                    }
                    
                    JournalingSuggestionsPicker {
                        Image("AddButton")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .shadow(radius: 10)
                    }
                    onCompletion: { suggestion in
                        journalSuggestion = suggestion
                        showingAddJournalEntryView = true
                    }
                    .padding([.trailing, .bottom], 20)

                    Spacer()

                    //addButton.padding(.bottom)
                }
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(true)
            .onAppear {
                fetchJournalEntries()
            }
            .sheet(isPresented: $showingAddJournalEntryView, onDismiss: fetchJournalEntries) {
                JournalView(suggestion: $journalSuggestion).environmentObject(dataManager)
            }
        }

    }

    private var entriesList: some View {
        List {
            ForEach(journalEntries.sorted { $0.date > $1.date }, id: \.id) { entry in
                Button(action: {
                    self.selectedEntry = entry
                }) {
                    JournalEntryCard(entry: entry)
                }
                .listRowBackground(Color.clear)
            }
            .onDelete(perform: deleteItem)
        }
        .listStyle(PlainListStyle())
        .sheet(item: $selectedEntry, onDismiss: fetchJournalEntries) { entry in
            JournalDetailView(entry: entry)
        }
    }

    private var addButton: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    showingAddJournalEntryView = true
                }) {
                    Image("AddButton")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .shadow(radius: 10)
                }
                .padding()
            }
        }
    }
    
    private func deleteItem(at offsets: IndexSet) {
        guard let currentUser = viewModel.currentUser else {
            print("Current user not found.")
            return
        }
        
        let db = Firestore.firestore()
        
        offsets.forEach { index in
            let entry = journalEntries.sorted { $0.date > $1.date }[index]
            
            let entryRef = db.collection("users").document(currentUser.id).collection("journal_entries").document(entry.id)
            
            entryRef.delete { error in
                if let error = error {
                    print("Error deleting document: \(error)")
                } else {
                    // Remove the entry from the local array
                    if let entryIndex = journalEntries.firstIndex(where: { $0.id == entry.id }) {
                        journalEntries.remove(at: entryIndex)
                    }
                }
            }
        }
    }
    
    
    private func fetchJournalEntries() {
        guard let currentUser = viewModel.currentUser else {
            print("Current user not found.")
            return
        }
        let db = Firestore.firestore()
        db.collection("users").document(currentUser.id).collection("journal_entries").getDocuments { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            self.journalEntries = documents.compactMap { document in
                do {
                    let entry = try document.data(as: JournalEntry.self)
                    return entry
                } catch {
                    print("Error decoding journal entry: \(error.localizedDescription)")
                    return nil
                }
            }
        }
    }}



struct EmptyStateView: View {
    var body: some View {
        VStack {
            Text("No journal entries yet. Enter one below!")
                .font(.title)
                .foregroundColor(.white)
        }
    }
}


struct JournalEntryCard: View {
    var entry: JournalEntry

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(entry.title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(entry.date, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
            Spacer()
            moodIcon
            Image(systemName: "chevron.right") // Custom arrow
                .foregroundColor(.white) // Set arrow color to white
        }
        .padding()
        .background {
            Color("SentMessage").ignoresSafeArea()
        }
        .cornerRadius(12)
        .shadow(color: Color.gray.opacity(0.4), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }

    private var moodIcon: some View {
        Image(systemName: entry.moodDetails.iconName)
            .resizable()
            .scaledToFit()
            .frame(width: 24, height: 24)
            .foregroundColor(Color(entry.moodDetails.color))
            .background(Circle().fill(Color.white))
            .shadow(radius: 2)
    }
}

#Preview {
    JournalEntriesView()
}

