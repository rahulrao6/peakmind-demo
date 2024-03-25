//import SwiftUI
//import FirebaseFirestore
//
//struct AvatarIglooMenuView: View {
//    @Environment(\.presentationMode) var presentationMode
//    @EnvironmentObject var viewModel: AuthViewModel
//    @State private var isAvatarMenuPresented = false
//    @State private var isIglooMenuPresented = false
//    @State private var isAvatarUpdateSuccessful = false
//    @State private var isIglooUpdateSuccessful = false
//
//    var body: some View {
//        ZStack {
//            Image("ChatBG2")
//                .resizable()
//                .aspectRatio(contentMode: .fill)
//                .edgesIgnoringSafeArea(.all)
//
//            VStack {
//                Text("Select Your Avatar and Igloo")
//                    .font(.system(size: 38, weight: .bold))
//                    .foregroundColor(.white)
//                    .padding(.top, 20)
//
//                Spacer()
//
//                ZStack {
//                    Color.black.opacity(0.6)
//                        .cornerRadius(20)
//                        .padding(.horizontal, 40)
//                        .padding(.vertical, 40)
//
//                    VStack(spacing: 10) {
//                        Button("Change Avatar") {
//                            isAvatarMenuPresented = true
//                        }
//                        .padding()
//                        .frame(maxWidth: 200)
//                        .foregroundColor(.white)
//                        .background(Color.blue)
//                        .cornerRadius(10)
//                        .sheet(isPresented: $isAvatarMenuPresented) {
//                            AvatarMenuView(isPresented: $isAvatarMenuPresented)
//                                .onDisappear {
//                                    if isAvatarMenuPresented {
//                                        isAvatarUpdateSuccessful = true
//                                    }
//                                }
//                        }
//
//                        Button("Change Igloo") {
//                            isIglooMenuPresented = true
//                        }
//                        .padding()
//                        .frame(maxWidth: 200)
//                        .foregroundColor(.white)
//                        .background(Color.green)
//                        .cornerRadius(10)
//                        .sheet(isPresented: $isIglooMenuPresented) {
//                            IglooMenuView(isPresented: $isIglooMenuPresented)
//                                .onDisappear {
//                                    if isIglooMenuPresented {
//                                        isIglooUpdateSuccessful = true
//                                    }
//                                }
//                        }
//
//                        Button("Close") {
//                            presentationMode.wrappedValue.dismiss() // Dismiss the current view
//                        }
//                        .padding()
//                        .frame(maxWidth: 200)
//                        .foregroundColor(.white)
//                        .background(Color.red)
//                        .cornerRadius(10)
//                    }
//                    .padding(.bottom, 20)
//                }
//            }
//        }
//        .navigationBarHidden(true)
//        .onReceive(viewModel.$currentUser) { _ in
//            if isAvatarUpdateSuccessful || isIglooUpdateSuccessful {
//                self.presentationMode.wrappedValue.dismiss() // Dismiss the sheet after successful update
//            }
//        }
//    }
//}
