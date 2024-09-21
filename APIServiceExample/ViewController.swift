//
//  ViewController.swift
//  APIServiceExample
//
//  Created by Alejandro Melo Domínguez on 20-09-24.
//

import APIService
import UIKit

class ViewController: UIViewController {

    let apiService: APIService = API(sslPinning: .disabled)

    let apiServicePinnedWithKeyHashes: APIService = API(
        sslPinning: .enabledWithKeyHashes([
            "m6ncyOFW/CPikpd2JnrAb6FFKEoYu2wO0csJr7Njc20=",
            "F3jGgttHVtSma2SMH+G1E4HzvVvvdIj2ntUG79K0hX0=",
            "T2tSOvwzOpDlD0swkfKp91HsepNcVu9v5ORLv8e0yzY="
        ])
    )

    let apiServicePinnedWithValidDERCertificate: APIService = {
        guard let certificateURL = Bundle.main.url(forResource: "ValidCertificate-PokeApi", withExtension: "der") else {
            fatalError("Cannot load certificate.")
        }
        return API(
            sslPinning: .enabledWithCertificateURLs([
                certificateURL
            ])
        )
    }()

    let apiServicePinnedWithInvalidDERCertificate: APIService = {
        guard let certificateURL = Bundle.main.url(forResource: "InvalidCertificate-Google", withExtension: "der") else {
            fatalError("Cannot load certificate.")
        }
        return API(
            sslPinning: .enabledWithCertificateURLs([
                certificateURL
            ])
        )
    }()

    let apiServicePinnedWithWrongHashes: APIService = API(
        sslPinning: .enabledWithKeyHashes([
            "wrong hash, this will fail"
        ])
    )

    let apiServicePinnedWithoutHashes: APIService = API(
        sslPinning: .enabledWithKeyHashes([])
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemPink

        let url = URL(string: "https://pokeapi.co/api/v2/pokemon/ditto")!

        Task {
            do {
                let pokemon: Pokemon = try await apiService.get(url)
                print("[SSL Disabled] Pokémon: \(pokemon)")
            } catch {
                print("[SSL Disabled] Error: \(error)")
            }
        }

        Task {
            do {
                let pokemon: Pokemon = try await apiServicePinnedWithKeyHashes.get(url)
                print("[SSL Enabled - Valid Hashes] Pokémon: \(pokemon)")
            } catch {
                print("[SSL Enabled - Valid Hashes] Error: \(error)")
            }
        }

        Task {
            do {
                let pokemon: Pokemon = try await apiServicePinnedWithValidDERCertificate.get(url)
                print("[SSL Enabled - Valid Certificate: PokeApi] Pokémon: \(pokemon)")
            } catch {
                print("[SSL Enabled - Valid Certificate: PokeApi] Error: \(error)")
            }
        }

        Task {
            do {
                let pokemon: Pokemon = try await apiServicePinnedWithInvalidDERCertificate.get(url)
                print("[SSL Enabled - Invalid Certificate: Google] Pokémon: \(pokemon)")
            } catch {
                print("[SSL Enabled - Invalid Certificate: Google] Error: \(error)")
            }
        }

        Task {
            do {
                let pokemon: Pokemon = try await apiServicePinnedWithWrongHashes.get(url)
                print("[SSL Enabled - Wrong Hashes] Pokémon: \(pokemon)")
            } catch {
                print("[SSL Enabled - Wrong Hashes] Error: \(error)")
            }
        }

        Task {
            do {
                let pokemon: Pokemon = try await apiServicePinnedWithoutHashes.get(url)
                print("[SSL Enabled - No Hashes] Pokémon: \(pokemon)")
            } catch {
                print("[SSL Enabled - No Hashes] Error: \(error)")
            }
        }
    }


}

