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

            // MARK: - SSL Pinning Disabled

            do {
                let pokemon: Pokemon = try await apiService.get(url)
                print("[SSL Pinning Disabled] Pokémon: \(pokemon)")
            } catch {
                print("[SSL Pinning Disabled] Error: \(error)")
            }

            // MARK: - SSL Pinning Enabled - Custom Request

            let request = Request(baseURL: url, method: .get, parameters: ["hello": "world"])
            // Output: https://pokeapi.co/api/v2/pokemon/ditto?hello=world
            print("[SSL Pinning Enabled - Custom Request] Final URL: \(request.finalURL)")

            do {
                let (data, httpURLRequest) = try await apiServicePinnedWithKeyHashes.perform(
                    request,
                    validatesStatusCode: false
                )

                guard [200, 204].contains(httpURLRequest.statusCode) else {
                    print("[SSL Pinning Enabled - Custom Request] Invalid status code: \(httpURLRequest.statusCode)")
                    return
                }

                let pokemon: Pokemon = try JSONDecoder().decode(Pokemon.self, from: data)
                print("[SSL Pinning Enabled - Custom Request] Pokémon: \(pokemon)")
            } catch {
                print("[SSL Pinning Enabled - Custom Request] Error: \(error)")
            }

            // MARK: - SSL Pinning Enabled - Valid Certificate: PokeApi

            do {
                let pokemon: Pokemon = try await apiServicePinnedWithValidDERCertificate.get(url)
                print("[SSL Pinning Enabled - Valid Certificate: PokeApi] Pokémon: \(pokemon)")
            } catch {
                print("[SSL Pinning Enabled - Valid Certificate: PokeApi] Error: \(error)")
            }

            // MARK: - SSL Pinning Enabled - Invalid Certificate: Google

            do {
                let pokemon: Pokemon = try await apiServicePinnedWithInvalidDERCertificate.get(url)
                print("[SSL Pinning Enabled - Invalid Certificate: Google] Pokémon: \(pokemon)")
            } catch {
                print("[SSL Pinning Enabled - Invalid Certificate: Google] Error: \(error)")
            }

            // MARK: - SSL Pinning Enabled - Valid Hashes

            do {
                let pokemon: Pokemon = try await apiServicePinnedWithKeyHashes.get(url)
                print("[SSL Pinning Enabled - Valid Hashes] Pokémon: \(pokemon)")
            } catch {
                print("[SSL Pinning Enabled - Valid Hashes] Error: \(error)")
            }

            // MARK: - SSL Pinning Enabled - Wrong Hashes

            do {
                let pokemon: Pokemon = try await apiServicePinnedWithWrongHashes.get(url)
                print("[SSL Pinning Enabled - Wrong Hashes] Pokémon: \(pokemon)")
            } catch {
                print("[SSL Pinning Enabled - Wrong Hashes] Error: \(error)")
            }

            // MARK: - SSL Pinning Enabled - No Hashes

            do {
                let pokemon: Pokemon = try await apiServicePinnedWithoutHashes.get(url)
                print("[SSL Pinning Enabled - No Hashes] Pokémon: \(pokemon)")
            } catch {
                print("[SSL Pinning Enabled - No Hashes] Error: \(error)")
            }
        }
    }
}
