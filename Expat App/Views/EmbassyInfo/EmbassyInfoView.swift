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
                        Picker(
                            viewModel.selectedCountryName, selection: $viewModel.selectedCountryName
                        ) {
                            Text(viewModel.placeholderCountryName)
                                .tag(viewModel.placeholderCountryName)
                                .italic()
                                .foregroundColor(AppStyles.secondaryTextColor.opacity(0.7))
                                .lineLimit(1)
                            
                            ForEach(viewModel.allCountryNames, id : \.self) { countryNameInLoop in
                                Text(countryNameInLoop)
                                    .tag(countryNameInLoop)
                                    .foregroundColor(AppStyles.primaryTextColor)
                                    .lineLimit(1)
                            }
                        }
                        .pickerStyle(.inline)
                        .foregroundColor(viewModel.selectedCountryName ==
                                         viewModel.placeholderCountryName ?
                                         AppStyles.secondaryTextColor.opacity(0.7) : AppStyles.primaryTextColor
                        )
                        .lineLimit(1)
                        .padding(EdgeInsets(top: 12, leading: 15, bottom: 12, trailing: 15))
                        .background(AppStyles.cellBackgroundColor.opacity(0.5))
                        .accentColor(AppStyles.primaryTextColor)
                        .cornerRadius(AppStyles.buttonCornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppStyles.buttonCornerRadius)
                                .stroke(AppStyles.secondaryTextColor.opacity(0.4), lineWidth: 1)
                        )
                        .padding(.horizontal)
                        .disabled(viewModel.isLoading ||
                                  viewModel.isLoadingAllRepresentations ||
                                  viewModel.isLoadingCountries
                        )
                    }
                    if !viewModel.isLoadingCountries &&
                        viewModel.countryListErrorMessage == nil &&
                        !viewModel.allCountryNames.isEmpty && (
                            viewModel.selectedCountryName !=
                            viewModel.placeholderCountryName &&
                            !viewModel.selectedCountryName.isEmpty) {
                        HStack(spacing: 10) {
                            Button("Haupt-Botschaft") {
                                Task {
                                    await viewModel.fetchMainEmbassyForSelectedCountry()
                                }
                            }
                            .primaryButtonStyle()
                            .disabled(viewModel.isLoading ||
                                      viewModel.isLoadingAllRepresentations)
                            
                            Button("Alle Vertretungen") {
                                Task {
                                    await viewModel.fetchAllRepresentationsForSelectedCountry()
                                }
                            }
                            .primaryButtonStyle()
                            .disabled(viewModel.isLoading ||
                                      viewModel.isLoadingAllRepresentations)
                        }
                        .padding(.horizontal)
                        // Optionale Animation für Ein-/Ausblenden
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        // Animieren, wenn sich die Auswahl ändert
                        .animation(.easeInOut(duration: 0.2), value: viewModel.selectedCountryName)
                    }
                    Group {
                        if viewModel.isLoading ||
                            viewModel.isLoadingAllRepresentations {
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
                                    Spacer()
                                    if viewModel.selectedCountryName == viewModel.placeholderCountryName {
                                        Text("Wähle ein Land aus der Liste, \num fortzufahren.")
                                            .foregroundColor(AppStyles.secondaryTextColor)
                                            .multilineTextAlignment(.center)
                                            .padding()
                                    } else {
                                        Text("Wähle eine Suchoption: \nHaupt-Botschaft oder Alle Vertretungen.")
                                            .foregroundColor(AppStyles.secondaryTextColor)
                                            .multilineTextAlignment(.center)
                                            .padding()
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
        .environmentObject(EmbassyInfoViewModel())
}
