//
//  PrenotazioneView.swift
//  Ristooorante
//
//  Created by Emanuele Pisano on 26/06/2026.
//

import SwiftUI
import Supabase

struct PrenotazioneView: View {
    let ristorante: Ristorante
    @Environment(\.dismiss) private var dismiss

    @State private var nome = ""
    @State private var email = ""
    @State private var telefono = ""
    @State private var dataMinima = Calendar.current.startOfDay(for: Date())
    @State private var data = Calendar.current.startOfDay(for: Date())
    @State private var ora = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var coperti = 2
    @State private var note = ""

    @State private var isLoading = false
    @State private var mostraConferma = false
    @State private var mostraErrore = false
    @State private var messaggioErrore = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("I tuoi dati") {
                    TextField("Nome e cognome", text: $nome)
                        .textContentType(.name)
                        .autocorrectionDisabled()
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    TextField("Telefono (opzionale)", text: $telefono)
                        .textContentType(.telephoneNumber)
                        .keyboardType(.phonePad)
                }

                Section("Prenotazione") {
                    DatePicker("Data", selection: $data, in: dataMinima..., displayedComponents: .date)
                        .accentColor(Color("Bordeaux"))
                    DatePicker("Ora", selection: $ora, displayedComponents: .hourAndMinute)
                        .accentColor(Color("Bordeaux"))
                    Stepper("Coperti: \(coperti)", value: $coperti, in: 1...20)
                }

                Section("Note") {
                    TextField("Allergie, richieste speciali…", text: $note, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section {
                    Button {
                        Task { await invia() }
                    } label: {
                        HStack {
                            Spacer()
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Prenota")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                            }
                            Spacer()
                        }
                    }
                    .listRowBackground(formValido ? Color("Bordeaux") : Color.gray)
                    .disabled(!formValido || isLoading)
                }
            }
            .navigationTitle(ristorante.nome)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Chiudi") { dismiss() }
                        .foregroundStyle(Color("Bordeaux"))
                }
            }
            .alert("Prenotazione inviata", isPresented: $mostraConferma) {
                Button("OK") { dismiss() }
            } message: {
                Text("La tua richiesta è stata inviata. Riceverai una email di conferma dal ristorante.")
            }
            .alert("Errore", isPresented: $mostraErrore) {
                Button("OK") { }
            } message: {
                Text(messaggioErrore)
            }
        }
    }

    var formValido: Bool {
        !nome.trimmingCharacters(in: .whitespaces).isEmpty &&
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        email.contains("@")
    }

    func invia() async {
            isLoading = true
            do {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                let dataStringa = formatter.string(from: data)

                let formatterOra = DateFormatter()
                formatterOra.dateFormat = "HH:mm:ss"
                let oraStringa = formatterOra.string(from: ora)

                struct NuovaPrenotazione: Encodable {
                    let ristorante_id: String
                    let nome_cliente: String
                    let email_cliente: String
                    let telefono_cliente: String
                    let data: String
                    let ora: String
                    let coperti: Int
                    let stato: String
                    let note: String
                }

                let payload = NuovaPrenotazione(
                    ristorante_id: ristorante.id.uuidString,
                    nome_cliente: nome.trimmingCharacters(in: .whitespaces),
                    email_cliente: email.trimmingCharacters(in: .whitespaces),
                    telefono_cliente: telefono.trimmingCharacters(in: .whitespaces),
                    data: dataStringa,
                    ora: oraStringa,
                    coperti: coperti,
                    stato: "in_attesa",
                    note: note.trimmingCharacters(in: .whitespaces)
                )

                try await supabase
                    .from("prenotazioni")
                    .insert(payload)
                    .execute()
                mostraConferma = true
            } catch {
                messaggioErrore = error.localizedDescription
                mostraErrore = true
            }
            isLoading = false
        }
}
