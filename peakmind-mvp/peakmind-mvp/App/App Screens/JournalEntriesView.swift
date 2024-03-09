import SwiftUI
import Firebase

struct JournalEntriesView: View {
    @EnvironmentObject var dataManager: JournalDataManager
    @EnvironmentObject var viewModel : AuthViewModel
    @State var journalEntries: [JournalEntry] = []
    @State private var showingAddJournalEntryView = false
    @State private var selectedEntry: JournalEntry? = nil


    var body: some View {
        NavigationView {
            ZStack {
                Image("ChatBG2")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Text("My Journal Entries")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top)

                    if journalEntries.isEmpty {
                        EmptyStateView().padding(.top)
                    } else {
                        entriesList
 
                    }

                    addButton.padding(.bottom)
                }
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(true)
            .onAppear {
                fetchJournalEntries()
            }
            .sheet(isPresented: $showingAddJournalEntryView, onDismiss: fetchJournalEntries) {
                JournalView().environmentObject(dataManager)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())

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
        .sheet(item: $selectedEntry) { entry in
            JournalDetailView(entry: entry)
        }
    }

    private var addButton: some View {
        VStack {
            Spacer()
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
            Image(systemName: "note.text")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.gray)
                .opacity(0.5)
            Text("No journal entries yet")
                .font(.title)
                .foregroundColor(.gray)
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
                    .foregroundColor(.primary)
                
                Text(entry.date, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            moodIcon
            Image(systemName: "chevron.right") // Custom arrow
                .foregroundColor(.white) // Set arrow color to white
        }
        .padding()
        .background(LinearGradient(gradient: Gradient(colors: [Color.white, Color(UIColor.secondarySystemBackground)]), startPoint: .top, endPoint: .bottom))
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
