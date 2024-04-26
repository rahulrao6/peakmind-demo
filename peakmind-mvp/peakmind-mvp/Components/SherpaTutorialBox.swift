import SwiftUI

struct SherpaTutorialBox: View {
    var tutorialText: String

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Image("Sherpa")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 125)

                VStack(alignment: .leading, spacing: 8) {
                    Text(tutorialText)
                        .padding([.top, .bottom], 5)
                        .foregroundColor(.white)
                        .font(.title3)
                        .fontWeight(.bold)

                    Button(action: {
                        print("Continue button tapped")
                    }) {
                        Text("Continue")
                            .bold()
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                    }
                    .background(Color("Ice Blue"))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .background(Color("Dark Blue"))
        .cornerRadius(20)
    }
}

// Preview Provider
struct SherpaTutorialBox_Previews: PreviewProvider {
    static var previews: some View {
        SherpaTutorialBox(tutorialText: "Welcome to the tutorial! Learn how to use our app effectively by following the steps.")
            .previewLayout(.sizeThatFits)
    }
}
