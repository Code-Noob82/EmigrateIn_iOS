//
//  EmbassyInfoView.swift
//  Expat App
//
//  Created by Dominik Baki on 12.05.25.
//

import SwiftUI

struct EmbassyInfoView: View {
    @StateObject private var viewModel = EmbassyInfoViewModel()
    @State private var countryToSearch: String = ""
    
    var body: some View {
        ZStack {
            AppStyles.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 15) {
                Text("Deutsche Auslandsvertretungen")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(AppStyles.primaryTextColor)
                    .padding(.top, 20)
                
                HStack(spacing: 0) {
                    TextField("", text: $countryToSearch, prompt: Text("Land eingeben"))
                        .foregroundColor(AppStyles.secondaryTextColor.opacity(0.6))
                        .padding(12)
                        .foregroundColor(AppStyles.primaryTextColor)
                        .background(AppStyles.primaryTextColor.opacity(0.12))
                        .cornerRadius(AppStyles.buttonCornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppStyles.buttonCornerRadius)
                                .stroke(AppStyles.secondaryTextColor.opacity(0.4), lineWidth: 1)
                        )
                        .accentColor(AppStyles.secondaryTextColor)
                    
                    if !countryToSearch.isEmpty {
                        Button {
                            countryToSearch = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(AppStyles.secondaryTextColor.opacity(0.7))
                                .padding(.trailing, 8)
                        }
                        .padding(.leading, -30)
                        .transition(.opacity.combined(with: .scale(scale: 0.8)))
                    }
                }
                .padding(.horizontal)
                .animation(.easeInOut(duration: 0.2), value: countryToSearch.isEmpty)
                
                Button("Suchen") {
                    dismissKeyboard()
                    Task {
                        await viewModel.fetchEmbassyInfo(forCountryName: countryToSearch.trimmingCharacters(in: .whitespacesAndNewlines))
                    }
                }
                .primaryButtonStyle()
                .disabled(countryToSearch.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isLoading)
                .padding(.horizontal)
                
                Group {
                    if viewModel.isLoading {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: AppStyles.primaryTextColor))
                            .scaleEffect(1.5)
                        Spacer()
                    } else if let embassy = viewModel.embassy {
                        EmbassyDetailView(embassy: embassy)
                    } else if viewModel.errorMessage != nil {
                        Spacer()
                        Text("Ein Fehler ist aufgetreten. Details siehe Meldung.")
                            .foregroundColor(AppStyles.secondaryTextColor)
                            .multilineTextAlignment(.center)
                            .padding()
                        Spacer()
                    } else if !countryToSearch.isEmpty && viewModel.embassy == nil && !viewModel.isLoading {
                        Spacer()
                        Text("Für '\(countryToSearch)' wurde keine deutsche Auslandsvertretung gefunden.")
                            .foregroundColor(AppStyles.secondaryTextColor)
                            .multilineTextAlignment(.center)
                        
                            .padding()
                        Spacer()
                    } else {
                        Spacer()
                        Text("Gib oben den Namen eines Landes ein, um die Daten der deutschen Auslandsvertretung zu finden.")
                            .foregroundColor(AppStyles.secondaryTextColor)
                            .multilineTextAlignment(.center)
                            .padding()
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(.bottom)
        }
        .alert("Fehler", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil }}
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "Unbekannter Fehler ist aufgetreten")
        }
    }
    
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    EmbassyInfoView()
}
