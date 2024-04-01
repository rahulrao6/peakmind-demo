//
//  ProfileView.swift
//  peakmind-mvp
//
//  Created by Raj Jagirdar on 2/17/24.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel : AuthViewModel
    @State private var isModule1Active = false
    @State private var isModule2Active = false
    @State private var isModule3Active = false
    @State private var isTentPurchaseActive = false
    @State private var isStoreViewActive = false
    @State private var isAnxietyQuizActive = false
    @State private var isSetHabitsActive = false
    @State private var isAvatarScreenActive = false
    @State private var isNightfallFlavorActive = false
    @State private var isDangersOfNightfallActive = false
    @State private var isSherpaFullMoonIDActive = false
    @State private var isBreathingExerciseViewActive = false


    var body: some View {
        NavigationView {
            if let user = viewModel.currentUser {
                List {
                    Section {
                        HStack {
                            Text(user.initials)
                                .font(.title)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 72, height: 72)
                                .background(Color.init(hex: user.color))
                            //.background(Color(.systemGray3))
                                .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                            
                            VStack (alignment: .leading, spacing: 4) {
                                Text(user.fullname)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .padding(.top, 4)
                                Text(user.location)
                                    .font(.footnote)
                                    .foregroundColor(.black)
                                
                                Text(user.email)
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                    }
                    
                    Section("General") {
                        HStack {
                            SettingsRowView(imageName: "gear", title: "Version", tintColor: Color(.systemGray))
                            
                            Spacer()
                            
                            Text("1.0.0")
                        }
                        
                    }
                    
                    Section("Account") {
                        
                        Button {
                            viewModel.signOut()
                        } label: {
                            SettingsRowView(imageName: "arrow.left.circle.fill", title: "Sign Out", tintColor: .red)
                        }
                        
                        Button {
                            viewModel.deleteAccount()
                        } label: {
                            SettingsRowView(imageName: "xmark.circle.fill", title: "Delete Account", tintColor: .red)
                        }
                        
                    }
                    
                    Section(header: Text("Rahul")) {
                        
                        Button {
                            print(isModule1Active)
                            isModule1Active.toggle()
                            print(isModule1Active)
                        } label : {
                            NavigationLink(destination: Module1(), isActive: $isModule1Active) {
                                Text("Module 1")
                            }
                        }
                        Button {
                            isModule2Active.toggle()
                        } label : {
                            NavigationLink(destination: Module2View(), isActive: $isModule2Active) {
                                Text("Module 2")
                            }
                        }
                        Button {
                            isModule3Active.toggle()
                        } label : {
                            NavigationLink(destination: Module3View(selectedItem: .boots), isActive: $isModule3Active) {
                                Text("Module 3")
                            }
                        }
                    }
                    
                    Section(header: Text("Raj")) {
                        
                        Button {
                            print(isTentPurchaseActive)
                            isTentPurchaseActive.toggle()
                            print(isModule1Active)
                        } label : {
                            NavigationLink(destination: TentPurchase(), isActive: $isTentPurchaseActive) {
                                Text("Tent Purchase")
                            }
                        }
                        Button {
                            isStoreViewActive.toggle()
                        } label : {
                            NavigationLink(destination: StoreView(), isActive: $isStoreViewActive) {
                                Text("Store")
                            }
                        }
                        Button {
                            isAnxietyQuizActive.toggle()
                        } label : {
                            NavigationLink(destination: AnxietyQuiz(), isActive: $isAnxietyQuizActive) {
                                Text("Anxiety Quiz")
                            }
                        }
                        Button {
                            isSetHabitsActive.toggle()
                        } label : {
                            NavigationLink(destination: SetHabits(), isActive: $isSetHabitsActive) {
                                Text("Set Habits")
                            }
                        }

                    }
                    
                    Section(header: Text("Mikey")) {
                        
                        Button {
                            print(isAvatarScreenActive)
                            isAvatarScreenActive.toggle()
                            print(isAvatarScreenActive)
                        } label : {
                            NavigationLink(destination: AvatarScreen(), isActive: $isAvatarScreenActive) {
                                Text("Avatar Screen")
                            }
                        }
                        Button {
                            isNightfallFlavorActive.toggle()
                        } label : {
                            NavigationLink(destination: NightfallFlavorView(), isActive: $isNightfallFlavorActive) {
                                Text("Nightfall Flavor")
                            }
                        }
                        Button {
                            isDangersOfNightfallActive.toggle()
                        } label : {
                            NavigationLink(destination: DangersOfNightfallView(), isActive: $isDangersOfNightfallActive) {
                                Text("Dangers of Nightfall")
                            }
                        }
                        
                        Button {
                            isSherpaFullMoonIDActive.toggle()
                        } label : {
                            NavigationLink(destination: SherpaFullMoonView(), isActive: $isSherpaFullMoonIDActive) {
                                Text("Sherpa Full Moon")
                            }
                        }

                    }
                    Section(header: Text("James")) {
                        
                        Button {
                            isBreathingExerciseViewActive.toggle()
                        } label : {
                            NavigationLink(destination: BreathingExerciseView(), isActive: $isBreathingExerciseViewActive) {
                                Text("Breathing Exercises")
                            }
                        }
                    }
                    
                }
                //.navigationTitle("Profile")
                .environment(\.colorScheme, .light)
                
            }
        }
    }
}
