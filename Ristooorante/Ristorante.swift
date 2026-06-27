//
//  Ristorante.swift
//  Ristooorante
//
//  Created by Emanuele Pisano on 26/06/2026.
//

import Foundation

struct Ristorante: Codable, Identifiable {
    let id: UUID
    let nome: String
    let indirizzo: String?
    let lat: Double?
    let lng: Double?
    let telefono: String?
    let sito_web: String?
    let url_menu: String?
    let citta_id: UUID?
    let approvato: Bool
    let modalita_conferma: String
        let orari: [String: OrariGiorno]?
    }

    struct FasciaOraria: Codable {
        let apertura: String
        let chiusura: String
    }

    struct OrariGiorno: Codable {
        let chiuso: Bool?
        let pranzo: FasciaOraria?
        let cena: FasciaOraria?
    }
