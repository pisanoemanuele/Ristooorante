//
//  RistoranteViewModel.swift
//  Ristooorante
//
//  Created by Emanuele Pisano on 26/06/2026.
//

import Foundation
import Combine
import Supabase

@MainActor
class RistoranteViewModel: ObservableObject {
    @Published var ristoranti: [Ristorante] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func caricaRistoranti() async {
        isLoading = true
        do {
            ristoranti = try await supabase
                .from("ristoranti")
                .select()
                .eq("approvato", value: true)
                .execute()
                .value
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
