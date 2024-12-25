//
//  Tools.swift
//  peakmind-mvp
//
//  Created by Raj Jagirdar on 12/23/24.
//

import Foundation
import SwiftUI

// MARK: - Personalized Tools Section
struct PersonalizedToolsSection: View {
    @EnvironmentObject var toolsViewModel: ToolsViewModel
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var showingToolSettings = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Personalized Tools")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    showingToolSettings = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "pencil")
                        Text("Edit")
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.5, green: 0.3, blue: 0.9),
                                Color(red: 0.4, green: 0.2, blue: 0.8)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 2)
                }
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(toolsViewModel.getOrderedTools()) { tool in
                        NavigationLink(destination: tool.destination) {
                            VStack(spacing: 12) {
                                Image(systemName: tool.systemIcon)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 32, height: 32)
                                    .foregroundColor(.white)
                                
                                Text(tool.name)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            .frame(width: 140, height: 120)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.5, green: 0.3, blue: 0.9),
                                        Color(red: 0.4, green: 0.2, blue: 0.8)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                        }
                        .environmentObject(authViewModel)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
        }
        .padding(.vertical)
        .sheet(isPresented: $showingToolSettings) {
            ModifiedToolsSettingsView(toolsViewModel: toolsViewModel)
        }
    }
}


struct ModifiedToolsSettingsView: View {
    @ObservedObject var toolsViewModel: ToolsViewModel
    @State private var tempSelectedTools: [String] = []
    @State private var tempToolOrder: [String] = []
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Selected Tools")) {
                    ForEach(tempToolOrder.compactMap { toolId in
                        toolsViewModel.availableTools.first { $0.id == toolId }
                    }, id: \.id) { tool in
                        HStack {
                            Image(systemName: "line.3.horizontal")
                                .foregroundColor(.gray)
                                .padding(.trailing, 8)
                            
                            Image(systemName: tool.systemIcon)
                                .foregroundColor(.purple)
                                .frame(width: 24, height: 24)
                            
                            Text(tool.name)
                                .font(.system(size: 16, weight: .medium))
                            
                            Spacer()
                            
                            Button(action: {
                                toggleTool(tool.id)
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .onMove(perform: moveItem)
                }
                
                Section(header: Text("Available Tools")) {
                    ForEach(toolsViewModel.availableTools.filter { !tempSelectedTools.contains($0.id) }) { tool in
                        HStack {
                            Image(systemName: tool.systemIcon)
                                .foregroundColor(.gray)
                                .frame(width: 24, height: 24)
                            
                            Text(tool.name)
                                .font(.system(size: 16, weight: .medium))
                            
                            Spacer()
                            
                            Button(action: {
                                toggleTool(tool.id)
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Customize Tools")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    toolsViewModel.updateSelectedTools(tempSelectedTools)
                    toolsViewModel.updateToolOrder(tempToolOrder)
                    dismiss()
                }
                .foregroundColor(.purple)
            )
            .onAppear {
                tempSelectedTools = toolsViewModel.selectedTools
                tempToolOrder = toolsViewModel.toolOrder
            }
        }
    }
    
    private func toggleTool(_ toolId: String) {
        if let index = tempSelectedTools.firstIndex(of: toolId) {
            tempSelectedTools.remove(at: index)
            tempToolOrder.removeAll { $0 == toolId }
        } else {
            tempSelectedTools.append(toolId)
            tempToolOrder.append(toolId)
        }
    }
    
    private func moveItem(from source: IndexSet, to destination: Int) {
        tempToolOrder.move(fromOffsets: source, toOffset: destination)
    }
}
