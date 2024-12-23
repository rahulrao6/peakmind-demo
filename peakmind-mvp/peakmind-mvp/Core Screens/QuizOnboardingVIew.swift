
// Checkbox View for Step 1
struct CheckboxView: View {
    var category: MentalHealthCategory
    var isChecked: Bool
    let action: () -> Void

    var body: some View {
        HStack {
            Button(action: {
                action()
            }) {
                Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                    .font(.system(size: 25))
                    .foregroundColor(isChecked ? .green : .gray)
            }
            Text(category.rawValue)
                .font(.custom("SFProText-Heavy", size: 24))
                .foregroundColor(.white)
                .padding(.leading, 10)

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(hex: "180b53")!)
        .cornerRadius(10)
        .padding(.horizontal, 20)
        .padding(.top, -5)
    }
}

enum OnboardingStep: Int, CaseIterable {
    case introductionCategories = 1
    case selectCategories
    case explanationFactors
    case selectFactors
    case setFactorWeights
    case setGoals
    case explainScoring
}
import SwiftUI
import UniformTypeIdentifiers
import FirebaseAuth
import FirebaseFirestore

struct QuizOnboardingView: View {
    @State private var selectedCategories: Set<MentalHealthCategory> = []
    @State private var prioritizedCategories: [MentalHealthCategory] = MentalHealthCategory.allCases
    @State private var currentStep: OnboardingStep = .introductionCategories
    @State private var goals: [MentalHealthCategory: String] = [:]
    @State private var selectedFactors: [MentalHealthCategory: Set<String>] = [:]
    @State private var factorWeights: [MentalHealthCategory: [String: Float]] = [:]
    @State private var showAlert = false // For showing alert on save
    
    @EnvironmentObject var authViewModel: AuthViewModel // Injected AuthViewModel
    
    var body: some View {
        ZStack {
            // Overall background with Linear Gradient
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "452198")!, Color(hex: "1a1164")!]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack {
                switch currentStep {
                case .introductionCategories:
                    IntroductionView(stepTitle: "Welcome to Your Mental Health Journey") {
                        withAnimation {
                            currentStep = .selectCategories
                        }
                    }
                case .selectCategories:
                    SelectCategoriesView(selectedCategories: $selectedCategories) {
                        withAnimation {
                            currentStep = .explanationFactors
                        }
                    }
                case .explanationFactors:
                    ExplanationFactorsView {
                        withAnimation {
                            currentStep = .selectFactors
                        }
                    }
                case .selectFactors:
                    SelectFactorsView(selectedCategories: selectedCategories, selectedFactors: $selectedFactors) {
                        withAnimation {
                            currentStep = .setFactorWeights
                        }
                    }
                case .setFactorWeights:
                    SetFactorWeightsView(selectedCategories: selectedCategories, selectedFactors: selectedFactors, factorWeights: $factorWeights) {
                        withAnimation {
                            currentStep = .setGoals
                        }
                    }
                case .setGoals:
                    SetGoalsView(selectedCategories: selectedCategories, goals: $goals, showAlert: $showAlert) {
                        withAnimation {
                            currentStep = .explainScoring
                        }
                    }
                case .explainScoring:
                    ExplainScoringView {
                        // Final step action, e.g., navigate to the main app
                        // Optionally, you can save all data here if not done earlier
                        Task {
                            do {
                                try await authViewModel.saveOnboardingData(
                                    selectedCategories: selectedCategories,
                                    prioritizedCategories: prioritizedCategories,
                                    selectedFactors: selectedFactors,
                                    factorWeights: factorWeights,
                                    goals: goals
                                )
                                showAlert = true
                            } catch {
                                print("Error saving onboarding data: \(error)")
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Success"),
                message: Text("Your onboarding data has been saved."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

struct IntroductionView: View {
    var stepTitle: String
    var onContinue: () -> Void
    
    var body: some View {
        VStack {
            Spacer() // This pushes the text down from the top of the screen
            
            Text(stepTitle)
                .font(.custom("SFProText-Heavy", size: 34)) // SF Pro Heavy
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            Text("In this app, we focus on two main mental health categories: Emotional and Physical. We'll guide you through selecting the areas that matter most to you and setting personalized goals to enhance your well-being.")
                .font(.custom("SFProText-Bold", size: 20)) // SF Pro Heavy
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.top, 10)

            //Spacer() // This pushes the text up from the bottom of the screen
            
            Button(action: onContinue) {
                Text("Get Started")
                    .font(.custom("SFProText-Heavy", size: 20)) // SF Pro Heavy
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "ca4c73")!)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 20)
            .padding(.top, 30)
            //.padding(.bottom, 40) // Add some padding from the bottom edge
            Spacer() // This pushes the text down from the top of the screen

        }
    }
}


struct SelectCategoriesView: View {
    @Binding var selectedCategories: Set<MentalHealthCategory>
    var onContinue: () -> Void
    
    var body: some View {
        VStack {
            Text("Which of the following mental health categories are you interested in?")
                .font(.custom("SFProText-Heavy", size: 29))
                .foregroundColor(.white)
                .padding()
            
            ForEach(MentalHealthCategory.allCases, id: \.self) { category in
                CheckboxView(category: category, isChecked: selectedCategories.contains(category)) {
                    if selectedCategories.contains(category) {
                        selectedCategories.remove(category)
                    } else {
                        selectedCategories.insert(category)
                    }
                }
                .padding(.bottom, 10)
            }
            
            Button(action: onContinue) {
                Text("Continue")
                    .font(.custom("SFProText-Bold", size: 18))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
            }
            .background(
                selectedCategories.isEmpty ? Color.clear : Color(hex: "ca4c73")!
            )
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white, lineWidth: selectedCategories.isEmpty ? 2 : 0)
            )
            .disabled(selectedCategories.isEmpty)
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
    }
}

struct ExplanationFactorsView: View {
    var onContinue: () -> Void
    
    var body: some View {
        VStack {
            Spacer() // This pushes the text down from the top of the screen
            
            Text("Understanding Factors")
                .font(.custom("SFProText-Heavy", size: 34)) // SF Pro Heavy
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            Text("Factors are specific aspects within each category that contribute to your overall mental health. By selecting and prioritizing these factors, you can tailor the app to better suit your personal needs and goals.")
                .font(.custom("SFProText-Bold", size: 20)) // SF Pro Bold
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.top, 10)

            Button(action: onContinue) {
                Text("Next")
                    .font(.custom("SFProText-Heavy", size: 20)) // SF Pro Heavy
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "ca4c73")!)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 20)
            .padding(.top, 30)
            
            Spacer() // This pushes the button down to the bottom
        }
    }
}


struct SelectFactorsView: View {
    var selectedCategories: Set<MentalHealthCategory>
    @Binding var selectedFactors: [MentalHealthCategory: Set<String>]
    var onContinue: () -> Void
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            ForEach(Array(selectedCategories), id: \.self) { category in
                VStack(alignment: .leading, spacing: 20) {
                    Text("Select \(category.rawValue.lowercased()) factors:")
                        .font(.custom("SFProText-Heavy", size: 25))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 20) // Align this text with CheckboxView

                    
                    ForEach(getFactors(for: category), id: \.self) { factor in
                        CheckboxView(category: category, isChecked: selectedFactors[category]?.contains(factor) ?? false) {
                            if selectedFactors[category]?.contains(factor) ?? false {
                                selectedFactors[category]?.remove(factor)
                            } else {
                                selectedFactors[category, default: Set<String>()].insert(factor)
                            }
                        }
                    }
                }
            }
            
            Spacer().frame(height: 30)
            
            Button(action: onContinue) {
                Text("Continue")
                    .font(.custom("SFProText-Bold", size: 18))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(selectedFactors.values.contains(where: { !$0.isEmpty }) ? Color(hex: "ca4c73")! : Color.clear)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white, lineWidth: selectedFactors.values.contains(where: { !$0.isEmpty }) ? 0 : 2)
                    )
            }
            .disabled(!selectedFactors.values.contains(where: { !$0.isEmpty }))
            .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 0)
        .multilineTextAlignment(.center) // Centered all text
    }
    
    func getFactors(for category: MentalHealthCategory) -> [String] {
        switch category {
        case .Emotional:
            return ["Mood", "Stress", "Emotional Resilience"]
        case .Physical:
            return ["Movement", "Sleep", "Energy"]
        }
    }
}



struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: { configuration.isOn.toggle() }) {
            HStack {
                Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                    .foregroundColor(configuration.isOn ? .green : .gray)
                configuration.label
                Spacer()
            }
            .padding()
            .background(Color(hex: "180b53")!)
            .cornerRadius(8)
        }
    }
}

struct SetFactorWeightsView: View {
    var selectedCategories: Set<MentalHealthCategory>
    var selectedFactors: [MentalHealthCategory: Set<String>]
    @Binding var factorWeights: [MentalHealthCategory: [String: Float]]
    var onContinue: () -> Void
    
    @State private var currentCategoryIndex: Int = 0
    @State private var localWeights: [String: Float] = [:]
    
    var body: some View {
        VStack {
            if currentCategoryIndex < selectedCategories.count {
                let category = Array(selectedCategories)[currentCategoryIndex]
                let factors = Array(selectedFactors[category] ?? [])
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("Set Weightage for \(category.rawValue)")
                        .font(.custom("SFProText-Heavy", size: 30))
                        .foregroundColor(.white)
                    
                    ForEach(factors, id: \.self) { factor in
                        VStack(alignment: .leading) {
                            Text(factor)
                                .font(.custom("SFProText-Bold", size: 16))
                                .foregroundColor(.white)
                            
                            Slider(value: Binding(
                                get: { localWeights[factor] ?? 0 },
                                set: { newValue in
                                    localWeights[factor] = newValue
                                    normalizeWeights(for: category)
                                }
                            ), in: 0...100, step: 1)
                            .accentColor(Color(hex: "ca4c73")!)
                            
                            Text("\(Int(localWeights[factor] ?? 0))%")
                                .font(.custom("SFProText-Bold", size: 14))
                                .foregroundColor(.white)
                        }
                    }
                    
                    Text("Total: \(localWeights.values.reduce(0, +), specifier: "%.0f")%")
                        .font(.custom("SFProText-Bold", size: 16))
                        .foregroundColor(.white)
                    
                    Button(action: {
                        factorWeights[category] = localWeights
                        localWeights = [:]
                        currentCategoryIndex += 1
                    }) {
                        Text(currentCategoryIndex < selectedCategories.count - 1 ? "Next" : "Continue")
                            .font(.custom("SFProText-Bold", size: 18))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(localWeights.values.reduce(0, +) == 100 ? Color(hex: "ca4c73")! : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(localWeights.values.reduce(0, +) != 100)
                }
                .padding()
                .background(Color(hex: "180b53")!)
                .cornerRadius(10)
                .padding(.horizontal, 20)
            } else {
                Button(action: onContinue) {
                    Text("Continue")
                        .font(.custom("SFProText-Bold", size: 18))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "ca4c73")!)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 20)
            }
        }
        .onAppear {
            if currentCategoryIndex < selectedCategories.count {
                let category = Array(selectedCategories)[currentCategoryIndex]
                localWeights = factorWeights[category]?.reduce(into: [String: Float]()) { result, entry in
                    result[entry.key] = entry.value
                } ?? Array(selectedFactors[category] ?? []).reduce(into: [String: Float]()) { result, factor in
                    result[factor] = 100 / Float(selectedFactors[category]?.count ?? 1)
                }
            }
        }
    }
    
    func normalizeWeights(for category: MentalHealthCategory) {
        let total = localWeights.values.reduce(0, +)
        if total > 100 {
            // Scale down all weights proportionally
            for factor in localWeights.keys {
                localWeights[factor]! = (localWeights[factor]! / Float(total)) * 100
            }
        }
    }
}
struct QuizOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        QuizOnboardingView()
            .environmentObject(AuthViewModel()) // Assuming the AuthViewModel is used
    }
}

struct SetGoalsView: View {
    var selectedCategories: Set<MentalHealthCategory>
    @Binding var goals: [MentalHealthCategory: String]
    @Binding var showAlert: Bool
    var onContinue: () -> Void
    
    @State private var currentGoalIndex = 0
    @State private var isTyping: Bool = false
    @State private var keyboardHeight: CGFloat = 0
    @FocusState private var isTextEditorFocused: Bool
    
    var body: some View {
        if currentGoalIndex < selectedCategories.count {
            let currentCategory = Array(selectedCategories)[currentGoalIndex]
            
            VStack(spacing: 8) {
                Spacer()
                    .frame(height: isTextEditorFocused || isTyping ? 100 : 10)
                
                // Question text
                Text("Write down a goal for your \(currentCategory.rawValue.lowercased()) wellbeing.")
                    .font(.custom("SFProText-Heavy", size: isTextEditorFocused || isTyping ? 12 : 29))
                    .foregroundColor(.white)
                    .lineLimit(nil)
                    .padding(.top, isTextEditorFocused || isTyping ? -30 : 0)
                    .padding(.horizontal, 20)
                    .shadow(color: Color.white.opacity(0.3), radius: 10, x: 0, y: 0)
                    .animation(.easeInOut(duration: 0.5), value: isTyping)
                    .animation(.easeInOut(duration: 0.5), value: isTextEditorFocused)
                
                // Input box
                ZStack(alignment: .topLeading) {
                    if goals[currentCategory, default: ""].isEmpty {
                        Text("Start typing here...")
                            .foregroundColor(Color.gray.opacity(0.5))
                            .padding(.vertical, 14)
                            .padding(.horizontal, 16)
                            .zIndex(1)
                    }
                    
                    TextEditor(text: Binding(
                        get: { goals[currentCategory, default: "" ] },
                        set: { goals[currentCategory] = $0 }
                    ))
                    .font(.custom("SFProText-Bold", size: 16))
                    .foregroundColor(Color("TextInsideBoxColor"))
                    .focused($isTextEditorFocused)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .frame(height: 200, alignment: .topLeading)
                    .background(Color.clear)
                    .scrollContentBackground(.hidden)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color("PurpleBoxGradientColor1"), Color("PurpleBoxGradientColor2")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .cornerRadius(10)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color("PurpleBorderColor"), lineWidth: 3.5)
                    )
                    .onChange(of: goals[currentCategory, default: ""]) { newValue in
                        withAnimation {
                            isTyping = !goals[currentCategory, default: ""].isEmpty
                        }
                        // Enforce character limit
                        if newValue.count > 250 {
                            goals[currentCategory] = String(newValue.prefix(250))
                        }
                    }
                    .onSubmit {
                        isTextEditorFocused = false
                    }
                    
                    // Character counter
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text("\(goals[currentCategory, default: ""].count)/250")
                                .font(.custom("SFProText-Bold", size: 12))
                                .foregroundColor(Color("TextInsideBoxColor"))
                                .padding(8)
                                .background(Color.black.opacity(0.2))
                                .cornerRadius(8)
                                .padding(8)
                        }
                    }
                }
                .frame(height: 200)
                .padding(.horizontal)
                
                Spacer()
                    .frame(height: isTextEditorFocused || isTyping ? (keyboardHeight / 2) : 20)
                
                // Submit button
                Button(action: {
                    isTextEditorFocused = false
                    if currentGoalIndex < selectedCategories.count - 1 {
                        withAnimation {
                            currentGoalIndex += 1
                        }
                    } else {
                        onContinue()
                    }
                }) {
                    Text(currentGoalIndex < selectedCategories.count - 1 ? "Next" : "Finish")
                        .font(.custom("SFProText-Bold", size: 18))
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .frame(maxWidth: .infinity)
                        .background(goals[currentCategory, default: ""].isEmpty ? Color.gray : Color(hex: "ca4c73")!)
                        .cornerRadius(10)
                        .shadow(color: goals[currentCategory, default: ""].isEmpty ? Color.clear : Color.white.opacity(1), radius: 10, x: 0, y: 0)
                }
                .padding(.horizontal, 20)
                .disabled(goals[currentCategory, default: ""].isEmpty)
            }
        }
    }
}

struct ExplainScoringView: View {
    var onFinish: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Understanding Your Scores")
                .font(.custom("SFProText-Heavy", size: 29))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding()
            
            Text("Your mental health scores are calculated based on the factors and their weightage that you’ve selected. These scores help you track your progress and identify areas that may need more attention.")
                .font(.custom("SFProText-Regular", size: 18))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            Spacer()
            
            Button(action: onFinish) {
                Text("Finish")
                    .font(.custom("SFProText-Bold", size: 18))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "ca4c73")!)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 20)
        }
    }
}

extension AuthViewModel {
    func saveOnboardingData(
        selectedCategories: Set<MentalHealthCategory>,
        prioritizedCategories: [MentalHealthCategory],
        selectedFactors: [MentalHealthCategory: Set<String>],
        factorWeights: [MentalHealthCategory: [String: Float]],
        goals: [MentalHealthCategory: String]
    ) async throws {
        guard let userId = currentUser?.id else {
            throw NSError(domain: "AuthError", code: 1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated."])
        }
        
        let db = Firestore.firestore()
        
        // Prepare data
        let priorityData: [String: Any] = [
            "selectedCategories": selectedCategories.map { $0.rawValue },
            "prioritizedCategories": prioritizedCategories.map { $0.rawValue },
            "goals": goals.reduce(into: [String: String]()) { result, entry in
                result[entry.key.rawValue] = entry.value
            }
        ]
        
        let factorsData: [String: Any] = selectedFactors.reduce(into: [String: Any]()) { result, entry in
            result[entry.key.rawValue] = Array(entry.value)
        }
        
        let weightsData: [String: Any] = factorWeights.reduce(into: [String: Any]()) { result, entry in
            result[entry.key.rawValue] = entry.value
        }
        
        // Save data
        try await db.collection("priority").document(userId).setData(priorityData, merge: true)
        try await db.collection("priority").document(userId).collection("preferences").document("selected_factors").setData(factorsData, merge: true)
        try await db.collection("priority").document(userId).collection("preferences").document("factor_weights").setData(weightsData, merge: true)
        
        print("All onboarding data saved successfully.")
    }
}

enum MentalHealthCategory: String, CaseIterable, Identifiable {
    case Emotional = "Emotional"
    case Physical = "Physical"
    
    var id: String { rawValue }
}
// Correct preview declaration
