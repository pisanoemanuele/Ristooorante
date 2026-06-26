//
//  ImpostazioniView.swift
//  Ristooorante
//
//  Created by Emanuele Pisano on 26/06/2026.
//

import SwiftUI

struct ImpostazioniView: View {
    @AppStorage("raggioVicinanze") var raggioVicinanze: Double = 5.0
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Raggio nelle vicinanze")
                            Spacer()
                            Text("\(Int(raggioVicinanze)) km")
                                .foregroundStyle(Color("Bordeaux"))
                                .bold()
                        }
                        Slider(value: $raggioVicinanze, in: 1...50, step: 1)
                            .tint(Color("Bordeaux"))
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Ricerca")
                }
            }
            .navigationTitle("Impostazioni")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Chiudi") {
                        dismiss()
                    }
                    .foregroundStyle(Color("Bordeaux"))
                }
            }
        }
    }
}

#Preview {
    ImpostazioniView()
}
