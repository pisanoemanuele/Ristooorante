//
//  ContentView.swift
//  Ristooorante
//
//  Created by Emanuele Pisano on 26/06/2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = RistoranteViewModel()

    var body: some View {
        NavigationStack {
            List(viewModel.ristoranti) { ristorante in
                VStack(alignment: .leading) {
                    Text(ristorante.nome)
                        .font(.headline)
                    Text(ristorante.indirizzo ?? "")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Ristooorante")
            .task {
                await viewModel.caricaRistoranti()
            }
        }
    }
}

#Preview {
    ContentView()
}
