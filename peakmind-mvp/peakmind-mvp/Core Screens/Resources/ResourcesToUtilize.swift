import SwiftUI

struct ResourcesToUtilize: View {
    var body: some View {
        ZStack {
            // Background
            Image("MainBG")
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .aspectRatio(contentMode: .fill)
            
            VStack {
                Spacer()
                
                // Title
                Text("Resources to Utilize")
                    .font(.system(size: 30, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .padding(.bottom, 20)
                
                // Resource Box
                VStack(spacing: 20) {
                    LinkButton(title: "SAMHSA Helpline", url: "https://www.samhsa.gov/find-help/national-helpline")
                    LinkButton(title: "988 Suicide and Crisis Hotline", url: "https://988lifeline.org/")
                    LinkButton(title: "Crisis Text Line", url: "https://www.crisistextline.org/")
                    LinkButton(title: "Veteran Crisis Hotline", url: "https://www.veteranscrisisline.net/")
                    LinkButton(title: "National Domestic Violence Hotline", url: "https://www.thehotline.org/")
                    LinkButton(title: "NEDA", url: "https://www.nationaleatingdisorders.org/get-help/")
                    LinkButton(title: "Mental Health America Helpline", url: "https://www.mhanational.org/")
                }
                .frame(width: 350, height: 600)
                .background(Color("Dark Blue").opacity(0.75))
                .cornerRadius(30)
                .shadow(radius: 5)
                .padding(.bottom, 20)
                
                // Emergency Text
                Text("If you have a genuine emergency, call 911")
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                    .padding(.bottom, 20)
                    .padding(.top, -20)
                
                Spacer()
            }
            .padding(.horizontal, 20) // Add horizontal padding to center the content
        }
    }
}

struct LinkButton: View {
    var title: String
    var url: String

    var body: some View {
        Button(action: {
            if let url = URL(string: url) {
                UIApplication.shared.open(url)
            }
        }) {
            Text(title)
                .foregroundColor(.black)
                .fontWeight(.bold)
                .frame(width: 320, height: 50)
                .background(Color("Ice Blue"))
                .cornerRadius(25)
        }
    }
}

struct ResourcesToUtilize_Previews: PreviewProvider {
    static var previews: some View {
        ResourcesToUtilize()
    }
}
