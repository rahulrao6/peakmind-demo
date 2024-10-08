import SwiftUI

import Firebase

struct DailyCheckInView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var emotionalRating: Double = 3
    @State private var physicalRating: Double = 3
    @State private var socialRating: Double = 3
    @State private var cognitiveRating: Double = 3
    
    // Add these state variables
    @State private var isSubmitting: Bool = false
    @State private var errorMessage: String?
    @State private var showAlert: Bool = false
    
    
    var body: some View {
        ZStack {
            // Background with Linear Gradient
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "112864")!, Color(hex: "23429a")!]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading) {
                Spacer()
                
                // Title
                Text("Daily Check-In")
                    .font(.custom("SFProText-Heavy", size: 22))
                    .foregroundColor(.white)
                    .padding(.bottom, 0)
                    .padding(.top, 30)
                    .padding(.leading, 20) // Left-aligned
                
                // All questions on the same page
                VStack(alignment: .leading, spacing: 10) {
                    QuestionView(
                        question: "How would you rate your emotional well-being today?",
                        rating: $emotionalRating
                    )
                    QuestionView(
                        question: "How would you rate your physical well-being today?",
                        rating: $physicalRating
                    )
                    QuestionView(
                        question: "How would you rate your social well-being today?",
                        rating: $socialRating
                    )
                    QuestionView(
                        question: "How would you rate your cognitive abilities today?",
                        rating: $cognitiveRating
                    )
                }
                .padding(.horizontal, 20) // Equal padding on both sides
                
                Spacer()
                
                // Submit button
                Button(action: submitCheckIn) {
                    if isSubmitting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .black))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "b0e8ff")!)
                            .cornerRadius(12)
                    } else {
                        Text("Submit")
                            .font(.custom("SFProText-Bold", size: 18))
                            .foregroundColor(.black)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(hex: "b0e8ff")!)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
                .padding(.top, 5)
                .disabled(isSubmitting)
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"), message: Text(errorMessage ?? "An unknown error occurred."), dismissButton: .default(Text("OK")))
                }
                
                
            }
        }
    }
    func submitCheckIn() {
        isSubmitting = true
        errorMessage = nil
        
        checkIfAlreadyCheckedIn { alreadyCheckedIn in
            if alreadyCheckedIn {
                errorMessage = "You've already checked in today."
                showAlert = true
                isSubmitting = false
            } else {
                saveCheckInData { success, error in
                    if success {
                        updateWeeklyStatus { success in
                            if success {
                                updateStreak { success in
                                    isSubmitting = false
                                    if success {
                                        presentationMode.wrappedValue.dismiss()
                                    } else {
                                        errorMessage = "Failed to update streak."
                                        showAlert = true
                                    }
                                }
                            } else {
                                errorMessage = "Failed to update weekly status."
                                showAlert = true
                                isSubmitting = false
                            }
                        }
                    } else {
                        errorMessage = error?.localizedDescription ?? "Failed to save check-in data."
                        showAlert = true
                        isSubmitting = false
                    }
                }
            }
        }
    }
    
    
    
    func checkIfAlreadyCheckedIn(completion: @escaping (Bool) -> Void) {
        guard let userId = viewModel.currentUser?.id else {
            completion(false)
            return
        }
        let db = Firestore.firestore()
        let today = Calendar.current.startOfDay(for: Date())

        // FIX COLLECTION + Document for Checkin
        db.collection("users").document(userId).collection("checkIns")
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: today))
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error checking for existing check-in: \(error.localizedDescription)")
                    completion(false)
                } else {
                    if let count = snapshot?.documents.count, count > 0 {
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            }
    }
    func saveCheckInData(completion: @escaping (Bool, Error?) -> Void) {
        guard let userId = viewModel.currentUser?.id else {
            completion(false, nil)
            return
        }

        let checkInData: [String: Any] = [
            "emotionalRating": Int(emotionalRating),
            "physicalRating": Int(physicalRating),
            "socialRating": Int(socialRating),
            "cognitiveRating": Int(cognitiveRating),
            "date": Timestamp(date: Date())
        ]

        let db = Firestore.firestore()
        db.collection("users").document(userId).collection("checkIns").addDocument(data: checkInData) { error in
            if let error = error {
                print("Error saving check-in data: \(error.localizedDescription)")
                completion(false, error)
            } else {
                print("Check-in data saved successfully.")
                completion(true, nil)
            }
        }
    }
    
    func updateWeeklyStatus(completion: @escaping (Bool) -> Void) {
        guard let userId = viewModel.currentUser?.id else {
            completion(false)
            return
        }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId)
        
        let today = Date()
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: today) - 1 // Subtract 1 to adjust for the array index (0-based)

        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let userDocument: DocumentSnapshot
            do {
                try userDocument = transaction.getDocument(userRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            var weeklyStatus = userDocument.get("weeklyStatus") as? [Int] ?? [0, 0, 0, 0, 0, 0, 0]
            
            if weekday == 0 { // It's Monday, reset weekly status
                weeklyStatus = [1, 0, 0, 0, 0, 0, 0]
            } else { // Set current day to 1
                weeklyStatus[weekday] = 1
            }
            
            transaction.updateData([
                "weeklyStatus": weeklyStatus
            ], forDocument: userRef)

            return nil
        }, completion: { (object, error) in
            if let error = error {
                print("Error updating weekly status: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Weekly status updated successfully.")
                completion(true)
                viewModel.fetchUserData(userId: viewModel.currentUser?.id ?? "")
            }
        })
    }
    
    func updateStreak(completion: @escaping (Bool) -> Void) {
        guard let userId = viewModel.currentUser?.id else {
            completion(false)
            return
        }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId)

        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let userDocument: DocumentSnapshot
            do {
                try userDocument = transaction.getDocument(userRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }

            let lastCheckInTimestamp = userDocument.get("lastCheckInDate") as? Timestamp
            let lastCheckInDate = lastCheckInTimestamp?.dateValue() ?? Date.distantPast
            var dailyCheckInStreak = userDocument.get("dailyCheckInStreak") as? Int ?? 0

            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let lastCheckInDay = calendar.startOfDay(for: lastCheckInDate)
            let dayDifference = calendar.dateComponents([.day], from: lastCheckInDay, to: today).day ?? 0

            if dayDifference == 1 {
                // Increment streak
                dailyCheckInStreak += 1
            } else if dayDifference > 1 {
                // Reset streak
                dailyCheckInStreak = 1
            } else if dayDifference == 0 {
                // Already checked in today
                return nil
            }

            // Update the user's streak and last check-in date
            transaction.updateData([
                "dailyCheckInStreak": dailyCheckInStreak,
                "lastCheckInDate": Timestamp(date: Date())
            ], forDocument: userRef)

            return nil
        }, completion: { (object, error) in
            if let error = error {
                print("Error updating streak: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Streak updated successfully.")
                completion(true)
            }
        })
    }


}

// Question view with a slider
struct QuestionView: View {
    var question: String
    @Binding var rating: Double

    let descriptors = ["Poor", "Fair", "Average", "Good", "Great"]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Multi-line Question Text
            Text(question)
                .font(.custom("SFProText-Bold", size: 18))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .lineLimit(nil) // Allow multi-line
                .fixedSize(horizontal: false, vertical: true) // Prevent truncation and allow text to wrap
            
            // Custom slider with a smaller thumb
            CustomSlider(value: $rating, range: 1...5)
                .frame(height: 20) // Custom frame for better alignment
            
            // Descriptor Text
            Text(descriptors[Int(rating) - 1])
                .font(.custom("SFProText-Bold", size: 16))
                .foregroundColor(.white)
                .padding(.top, -15)
        }
        .padding() // Padding inside the background
        .background(Color(hex: "0b1953")!) // Color-coded background behind the question block
        .cornerRadius(12) // Optional: Rounded corners for better appearance
    }
}

// Custom Slider View
struct CustomSlider: View {
    @Binding var value: Double
    var range: ClosedRange<Double>
    
    var body: some View {
        GeometryReader { geometry in
            // Slider track
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 11)
                
                Capsule()
                    .fill(Color(hex: "b0e8ff")!)
                    .frame(width: CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)) * geometry.size.width, height: 11)
                
                // Custom thumb circle
                Circle()
                    .fill(Color(hex: "b0e8ff")!)
                    .frame(width: 18, height: 18) // Smaller circle for thumb
                    .offset(x: CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)) * geometry.size.width - 6) // Align thumb properly
                    .gesture(DragGesture(minimumDistance: 0)
                        .onChanged { gesture in
                            let sliderValue = max(min(Double(gesture.location.x / geometry.size.width) * (range.upperBound - range.lowerBound) + range.lowerBound, range.upperBound), range.lowerBound)
                            value = sliderValue.rounded()
                        }
                    )
            }
        }
        .frame(height: 20) // Height of the whole slider
    }
}



struct DailyCheckInView_Previews: PreviewProvider {
    static var previews: some View {
        DailyCheckInView()
    }
}
