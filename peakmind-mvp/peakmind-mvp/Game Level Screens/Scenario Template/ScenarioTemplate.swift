import SwiftUI

struct ScenarioTemplate<nextView: View>: View {
    
    let titleText: String
    let scenarioTexts: [String]
    var nextScreen: nextView
    var closeAction: () -> Void

    
    var body: some View {
        VStack {
            Text(titleText)
                .font(.system(size: 30, weight: .bold, design: .default))
                .foregroundColor(.white)
                .padding(.top, 40)
                .padding(.bottom, 40)
            
            VStack {
                Spacer()
                .padding(.top, 35)
                
                Text("Scenario Time!")
                    .font(.title3)
                    .bold()
                    .foregroundStyle(.white)
                    .shadow(color: .black, radius: 2)
                    .padding(11)
                    .background(Color("Navy Blue"))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.black, lineWidth: 2)
                    )
                    .padding(-20)
                TabView {
                    ForEach(scenarioTexts.indices, id: \.self) { index in
                        Text("\(scenarioTexts[index])")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color(hex: "677072").opacity(0.33))  // Adjusted color for the inner box
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(.black, lineWidth: 2)
                            )
                            .cornerRadius(12)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .frame(height: 200)
                
               // Spacer()
                Button {
                    closeAction()
                } label: {
                    Text("Proceed to quiz")
                        .foregroundStyle(.black)
                        .padding()
                        .background(Color("Ice Blue"))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.black, lineWidth: 2)
                        )
                }
//                Button {
//
//                    
//                } label: {
//                    Text("Proceed to quiz")
//                        .foregroundStyle(.black)
//                        .padding()
//                        .background(Color("Ice Blue"))
//                        .cornerRadius(16)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 16)
//                                .stroke(.black, lineWidth: 2)
//                        )
//                }
            }
            .padding([.horizontal, .bottom], 30)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 110/255, green: 173/255, blue: 240/255),
                        Color(red: 4/255, green: 79/255, blue: 158/255)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .opacity(0.8)
            )
            .cornerRadius(50)
            .shadow(color: .black.opacity(0.5), radius: 5, x: 3, y: 3)  // Added drop shadow here
            .padding(.horizontal, 20)
            
            SherpaTalking(speech: "Let's look at this scenario and see what you should do!", closeAction: closeAction)
        }
        .background(Background())
    }
}

//// Preview
//struct ScenarioTemplate_Previews: PreviewProvider {
//    static var previews: some View {
//        ScenarioTemplate(titleText: "Mt. Anxiety: Phase One",
//                         scenarioTexts: ["Now let’s work through a scenario. These help you with decision making related to mental health choices.", "Let's work through a scenario to help you in the future.", "You’ve had a very stressful day at work. You are getting home late and aren’t happy. How would you most handle the situation?"],
//                         nextScreen: VStack{})
//    }
//}
