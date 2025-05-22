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
        .onTapGesture {
            Task {
                await viewModel.toggleItemCompletion(item: item)
            }
        }
        .disabled(viewModel.isLoading) // Deaktiviert die gesamte Zeile während des Ladevorgangs
        // Animation, damit der Übergang des Checkbox-Status sanfter ist
        .animation(.default, value: viewModel.isItemCompleted(item))
    }
}

// MARK: - Preview für ChecklistItemView
#Preview("ChecklistItemView") {
    
    let emptyViewModel = ChecklistViewModel(categoryId: "preview_dummy_category")
    let emptyItem = ChecklistItem(id: "preview_dummy_item", categoryId: "preview_dummy_category", text: "Vorschau Item", details: nil, isDoneDefault: false, order: 0)
    ChecklistItemView(viewModel: emptyViewModel, item: emptyItem)
        .environmentObject(AuthenticationViewModel()) // Für EnvironmentObject
}
