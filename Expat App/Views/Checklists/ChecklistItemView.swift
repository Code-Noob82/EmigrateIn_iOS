//
//  ChecklistItemView.swift
//  Expat App
//
//  Created by Dominik Baki on 21.05.25.
//

import SwiftUI

struct ChecklistItemView: View {
    // binding, da die ChecklistItemsListView den Status des Items verändern soll
    // und das ChecklistViewModel dann die Änderung in Firestore speichert.
    @ObservedObject var viewModel: ChecklistViewModel // Muss das ViewModel sein, das den Status verwaltet
    let item: ChecklistItem // Das anzuzeigende Item
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            // Checkbox Icon
            Image(systemName: viewModel.isItemCompleted(item) ? "checkmark.circle.fill" : "circle")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(viewModel.isItemCompleted(item) ? .green : AppStyles.secondaryTextColor) // Grün bei erledigt
                .onTapGesture {
                    Task {
                        await viewModel.toggleItemCompletion(item: item)
                    }
                }
                .disabled(viewModel.isLoading) // Checkbox während des Speicherns deaktivieren

            VStack(alignment: .leading, spacing: 4) {
                Text(item.text)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(AppStyles.primaryTextColor)
                    // Optional: Durchgestrichen, wenn erledigt
                    .strikethrough(viewModel.isItemCompleted(item), color: AppStyles.secondaryTextColor)
                
                if let details = item.details, !details.isEmpty {
                    Text(details)
                        .font(.caption)
                        .foregroundColor(AppStyles.secondaryTextColor)
                }
            }
            Spacer() // Schiebt den Inhalt nach links und rechts
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 5) // Kleines Padding innerhalb des Listeneintrags
    }
}

// MARK: - Preview für ChecklistItemView
#Preview("ChecklistItemView") {
    let dummyItem = ChecklistItem(id: "dummy_item_1", categoryId: "dummy_category", text: "Registrierung beim Einwohnermeldeamt", details: "Wichtig innerhalb der ersten 14 Tage nach Ankunft.", order: 1)
    let dummyItemCompleted = ChecklistItem(id: "dummy_item_2", categoryId: "dummy_category", text: "Bankkonto eröffnen", details: nil, order: 2)
    
    let mockViewModel = ChecklistViewModel(categoryId: "dummy_category")
    // Mock den Status für den Preview
    mockViewModel.completedItemsState = ["dummy_item_1": true]
    
    return VStack(spacing: 20) {
        ChecklistItemView(viewModel: mockViewModel, item: dummyItem)
        ChecklistItemView(viewModel: mockViewModel, item: dummyItemCompleted)
    }
    .padding()
    .background(AppStyles.backgroundGradient.ignoresSafeArea()) // Preview Hintergrund
    .environmentObject(AuthenticationViewModel()) // Für EnvironmentObject
}
