//
//  EmbassyInfoView.swift
//  Expat App
//
//  Created by Dominik Baki on 12.05.25.
//

import SwiftUI

struct EmbassyInfoView: View {
    @StateObject private var viewModel = EmbassyInfoViewModel()
    @State private var selectedRepresentationForDetails: Embassy?
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppStyles.backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 15) {
                    Text("Deutsche Auslandsvertretungen")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(AppStyles.primaryTextColor)
                        .padding(.top, 20)
                    
                    if viewModel.isLoadingCountries {
                        HStack {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: AppStyles.primaryTextColor))
                            Text("Lade Länderliste...")
                                .foregroundColor(AppStyles.secondaryTextColor)
                        }
                        .padding()
                    } else if let countryListError = viewModel.countryListErrorMessage {
                        VStack {
                            Text(countryListError)
                                .foregroundColor(AppStyles.destructiveColor)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            Button("Erneut versuchen") {
                                Task {
                                    await viewModel.loadAllCountryNames()
                                }
                            }
                            .primaryButtonStyle()
                            .padding(.top)
                        }
                        .padding(.horizontal)
                    } else if viewModel.allCountryNames.isEmpty {
                        Text("keine Länder verfügbar. Bitte versuche es später erneut.")
                            .foregroundColor(AppStyles.secondaryTextColor)
                            .padding()
                    } else {
                        Picker("Land auswählen", selection: $viewModel.selectedCountryName) {
                            ForEach(viewModel.allCountryNames, id: \.self) { name in
                                Text(name)
                                    .tag(name)
                                    .foregroundColor(AppStyles.primaryTextColor)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding(EdgeInsets(top: 12, leading: 15, bottom: 12, trailing: 15))
                        .background(AppStyles.primaryTextColor.opacity(0.12))
                        .accentColor(AppStyles.primaryTextColor)
                        .foregroundColor(AppStyles.primaryTextColor)
                        .cornerRadius(AppStyles.buttonCornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppStyles.buttonCornerRadius)
                                .stroke(AppStyles.secondaryTextColor.opacity(0.4), lineWidth: 1)
                        )
                        .padding(.horizontal)
                        .disabled(viewModel.isLoading || viewModel.isLoadingAllRepresentations)
                    }
                    
                    HStack(spacing: 10) {
                        Button("Haupt-Botschaft") {
                            Task {
                                await viewModel.fetchMainEmbassyForSelectedCountry()
                            }
                        }
                        .primaryButtonStyle()
                        .disabled(viewModel.isLoadingCountries || viewModel.selectedCountryName.isEmpty || viewModel.isLoadingAllRepresentations)
                        
                        Button("Alle Vertretungen") {
                            Task {
                                await viewModel.fetchAllRepresentationsForSelectedCountry()
                            }
                        }
                        .primaryButtonStyle()
                        .disabled(viewModel.isLoadingCountries || viewModel.selectedCountryName.isEmpty || viewModel.isLoading || viewModel.isLoadingAllRepresentations)
                    }
                    .padding(.horizontal)
                    
                    Group {
                        if viewModel.isLoading || viewModel.isLoadingAllRepresentations {
                            Spacer()
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: AppStyles.primaryTextColor))
                                .scaleEffect(1.5)
                            Spacer()
                        } else {
                            if let errorMessage = viewModel.errorMessage ?? viewModel.allRepresentationsErrorMessage {
                                Spacer()
                                Text(errorMessage)
                                    .foregroundColor(AppStyles.destructiveColor)
                                    .multilineTextAlignment(.center)
                                    .padding()
                                Spacer()
                            } else {
                                switch viewModel.displayContent {
                                case .singleEmbassy:
                                    if let embassy = viewModel.embassy {
                                        EmbassyDetailView(embassy: embassy)
                                    } else {
                                        ContentUnavailableView("Keine Haupt-Botschaft",
                                                               systemImage: "building.columns.slash",
                                                               description: Text("Für '\(viewModel.selectedCountryName)' wurde keine Haupt-Botschaft gefunden."))
                                        .foregroundColor(AppStyles.secondaryTextColor)
                                    }
                                case .allRepresentationsInCountry:
                                    if !viewModel.allRepresentationsForCountry.isEmpty {
                                        List {
                                            ForEach(viewModel.allRepresentationsForCountry) { representation in
                                                NavigationLink(value: representation) {
                                                    RepresentationRowView(representation: representation)
                                                }
                                                .listRowBackground(Color.clear)
                                                .listRowSeparatorTint(AppStyles.secondaryTextColor.opacity(0.3))
                                            }
                                        }
                                        .listStyle(.plain)
                                        .background(Color.clear)
                                    } else {
                                        ContentUnavailableView("Keine Vertretungen",
                                                               systemImage: "doc.text.magnifyingglass",
                                                               description: Text("Für '\(viewModel.selectedCountryName)' wurden keine Vertretungen gefunden."))
                                        .foregroundColor(AppStyles.secondaryTextColor)
                                    }
                                case .none:
                                    if !viewModel.allCountryNames.isEmpty {
                                        Spacer()
                                        Text("Wähle eine Suchoption Haupt-Botschaft oder Alle Vertretungen.)")
                                            .foregroundColor(AppStyles.secondaryTextColor)
                                            .multilineTextAlignment(.center)
                                            .padding()
                                        Spacer()
                                    } else if viewModel.allCountryNames.isEmpty {
                                        Spacer()
                                        Text("Bitte wähle zuerst ein Land aus der Liste.")
                                            .foregroundColor(AppStyles.secondaryTextColor)
                                            .multilineTextAlignment(.center)
                                            .padding()
                                        Spacer()
                                    } else if viewModel.allCountryNames.isEmpty && viewModel.isLoadingCountries && viewModel.countryListErrorMessage == nil {
                                        Spacer()
                                        Text("Länderliste ist leer. Bitte versuche, die Liste neu zu laden.")
                                            .foregroundColor(AppStyles.secondaryTextColor)
                                            .multilineTextAlignment(.center)
                                            .padding()
                                        Spacer()
                                    }
                                    else {
                                        Spacer()
                                        Text("Länderliste wird geladen oder ist nicht verfügbar.")
                                            .foregroundColor(AppStyles.secondaryTextColor)
                                            .multilineTextAlignment(.center)
                                            .padding()
                                        Spacer()
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .padding(.bottom)
                .navigationTitle(viewModel.selectedCountryName.isEmpty ? "Auslandsvertretungen" : viewModel.selectedCountryName)
                .navigationBarTitleDisplayMode(.inline)
            }
            .navigationDestination(for: Embassy.self) { embassyDetail in
                EmbassyDetailView(embassy: embassyDetail)
                    .navigationTitle(embassyDetail.city ?? embassyDetail.type ?? "Detailansicht")
                    .background(AppStyles.backgroundGradient.ignoresSafeArea())
            }
            .alert("Fehler Haupt-Botschaft", isPresented: Binding(
                get: { viewModel.errorMessage != nil && viewModel.displayContent != .allRepresentationsInCountry },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) { Button("OK") {}} message: { Text(viewModel.errorMessage ?? "") }
            
                .alert("Fehler Alle Vertretungen", isPresented: Binding(
                    get: { viewModel.allRepresentationsErrorMessage != nil && viewModel.displayContent != .singleEmbassy },
                    set: { if !$0 { viewModel.allRepresentationsErrorMessage = nil } }
                )) { Button("OK") {}} message: { Text(viewModel.allRepresentationsErrorMessage ?? "") }
            
                .onAppear {
                    if viewModel.allCountryNames.isEmpty && !viewModel.isLoadingCountries {
                        Task {
                            await viewModel.loadAllCountryNames()
                        }
                    }
                }
        }
    }
}

#Preview {
    EmbassyInfoView()
}
