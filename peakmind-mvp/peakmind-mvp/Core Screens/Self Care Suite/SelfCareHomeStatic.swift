import SwiftUI

struct SelfCareHomeStatic: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // Top Section
                VStack {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Welcome, User!")
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .font(.system(size: 22))
                            
                            Text("This is your self-care suite where you can find your personal plan, analytics and much more!")
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                                .font(.system(size: 18))
                        }
                        .padding()
                        .frame(width: geometry.size.width * 0.65)
                        
                        Spacer()
                        
                        Image("Sherpa")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60)
                        Spacer()
                    }
                    .frame(height: geometry.size.height * 0.2)
                }
                .frame(maxWidth: .infinity)
                .background(
                    Image("SelfCare")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .clipped()
                )
                
                // Sheet-Like View
                ScrollView {
                    LazyVStack(spacing: 20) {
                        Spacer()
                        
                        VStack{
                            VStack {
                                MoodPreviewStatic(title: "Weekly Moods", color: Color("Navy Blue"))
                                    .frame(width: geometry.size.width - 30)
                            }
                            
                            VStack{
                                taskListViewStatic(title: "Personal Plan", color: Color("Navy Blue"))
                                    .frame(width: geometry.size.width - 30)
                            }
                            
                            HStack(spacing: -15) {
                                CustomButtonStatic(title: "Check In")
                                    .frame(maxWidth: .infinity)
                                CustomButtonStatic(title: "Pick Widgets")
                                    .frame(maxWidth: .infinity)
                            }
                            .frame(width: geometry.size.width)
                        }
                        
                        Spacer(minLength: geometry.size.height * 0.2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 15)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.darkBlue)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: -5)
                .offset(y: geometry.size.height * 0.2)
            }
            .background(Color.iceBlue)
        }
        .navigationBarTitle("Self Care Suite", displayMode: .inline)
        .foregroundColor(.white)
    }
    
    @ViewBuilder
    private func taskListViewStatic(title: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding()

            VStack(alignment: .leading, spacing: 5) {
                ForEach(0..<3, id: \.self) { index in
                    TaskCardFirebaseStatic()
                        .padding(.leading, 0)
                        .padding(.top, index == 0 ? 5 : 0)
                }
            }
            .padding([.horizontal, .bottom])
        }
        .background(RoundedRectangle(cornerRadius: 10).fill(color))
        .foregroundColor(.white)
    }

    @ViewBuilder
    private func MoodPreviewStatic(title: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding()

            VStack {
                Rectangle() // Placeholder for the chart
                    .fill(Color.gray)
                    .frame(height: 150)
            }
            .padding([.horizontal])

            CustomButtonStatic(title: "Analytics")
                .padding()
        }
        .background(RoundedRectangle(cornerRadius: 10).fill(color))
        .foregroundColor(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct TaskCardFirebaseStatic: View {
    var body: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .frame(height: 50)
            .cornerRadius(10)
            .overlay(
                Text("Task Name")
                    .foregroundColor(.white)
            )
    }
}

struct CustomButtonStatic: View {
    let title: String
    
    var body: some View {
        Text(title)
            .bold()
            .foregroundColor(.white)
            .padding()
            .frame(width: 200, height: 50)
            .background(Color.blue)
            .cornerRadius(10)
    }
}

struct SelfCareHomeStatic_Previews: PreviewProvider {
    static var previews: some View {
        SelfCareHomeStatic()
    }
}
