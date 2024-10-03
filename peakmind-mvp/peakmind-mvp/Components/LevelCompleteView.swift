import SwiftUI

struct LevelCompleteView: View {
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        
        Group {
            if let user = viewModel.currentUser {
                ZStack {
                    VStack(spacing: 0) {
                        Spacer()

                        ZStack {
                            VStack {
                                Text("Level Complete!")
                                    .font(.system(size: 32, weight: .bold, design: .default))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .padding(.bottom, -10)
                                
                                Image("StarsCropped")
                                    .resizable()
                                    .frame(width: 300, height: 120)
                                    .padding(.bottom, -50)
                                
                                Image(user.selectedAvatar) // Uses the user's selected avatar
                                    .resizable()
                                    .frame(width: 250, height: 250)
                                    .padding(.bottom, -10)
                                
                                HStack(spacing: -20) {
                                    CustomButton2(title: "Replay", onClick: {
                                        print("Replay tapped")
                                    })
                                    
                                    CustomButton2(title: "Back to Map", onClick: {
                                        print("Map tapped")
                                    })
                                }
                                .padding(.top, 20)
                            }
                            .frame(width: 330, height: 480) // Adjusted dimensions
                            .background(Color("Dark Blue").opacity(1))
                            .cornerRadius(15)
                            .shadow(radius: 5)
                        }

                        Spacer()
                    }
                }
            } else {
                Text("No user data available")
            }
        }
    }
}

struct LevelCompleteView_Previews: PreviewProvider {
    static var previews: some View {
        LevelCompleteView().environmentObject(AuthViewModel())
    }
}
