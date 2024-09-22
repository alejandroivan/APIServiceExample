//
//  ViewController.swift
//  APIServiceExample
//
//  Created by Alejandro Melo Domínguez on 20-09-24.
//

import APIService
import UIKit

class ViewController: UIViewController {

//    let apiService: APIService = API(
//        sslPinning: .disabled,
//        validStatusCodes: [200],
//        baseHeaders: [
//            "hello": "world"
//        ]
//    )

//    // With valid public key hashes
//    let apiService: APIService = API(
//        sslPinning: .enabledWithKeyHashes([ // These hashes match with pokeapi.co
//            "m6ncyOFW/CPikpd2JnrAb6FFKEoYu2wO0csJr7Njc20=",
//            "F3jGgttHVtSma2SMH+G1E4HzvVvvdIj2ntUG79K0hX0=",
//            "T2tSOvwzOpDlD0swkfKp91HsepNcVu9v5ORLv8e0yzY="
//        ]),
//        validStatusCodes: [200],
//        baseHeaders: [
//            "hello": "world"
//        ]
//    )

    // With valid DER certificate
    let apiService: APIService = {
        let certificateName = "ValidCertificate-PokeApi"
        guard let certificateURL = Bundle.main.url(forResource: certificateName, withExtension: "der") else {
            fatalError("Cannot load certificate.")
        }
        return API(
            sslPinning: .enabledWithCertificateURLs([
                certificateURL
            ]),
            validStatusCodes: [200],
            baseHeaders: [
                "hello": "world"
            ]
        )
    }()

//    // With invalid DER certificate (from Google)
//    let apiService: APIService = {
//        let certificateName = "InvalidCertificate-Google"
//        guard let certificateURL = Bundle.main.url(forResource: certificateName, withExtension: "der") else {
//            fatalError("Cannot load certificate.")
//        }
//        return API(
//            sslPinning: .enabledWithCertificateURLs([
//                certificateURL
//            ]),
//            validStatusCodes: [200],
//            baseHeaders: [
//                "hello": "world"
//            ]
//        )
//    }()

//    // With wrong public key hashes
//    let apiService: APIService = API(
//        sslPinning: .enabledWithKeyHashes([
//            "wrong hash, this will fail"
//        ]),
//        validStatusCodes: [200],
//        baseHeaders: [
//            "hello": "world"
//        ]
//    )

//    // Without public key hashes
//    let apiService: APIService = API(
//        sslPinning: .enabledWithKeyHashes([]),
//        validStatusCodes: [200],
//        baseHeaders: [
//            "hello": "world"
//        ]
//    )

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemPink

        let url = URL(string: "https://pokeapi.co/api/v2/pokemon/ditto")!

        Task {

            // MARK: - SSL Pinning
            printSpacer()

            do {
                let pokemon: Pokemon = try await apiService.get(url, headers: ["bye": "universe!"])
                print("[APIService] Response: \(pokemon)")
            } catch {
                print("[APIService] Error: \(error)")

                if let error = error as? APIError, let body = error.responseBody {
                    print("[APIService] Error body: \(body)")
                }
            }

            // MARK: - SSL Pinning Enabled - Custom Request
            printSpacer()

            let request = Request(baseURL: url, method: .get, parameters: ["hello": "world"])

            do {
                let (data, httpURLRequest) = try await apiService.perform(
                    request,
                    validatesStatusCode: false
                )

                guard [200, 204].contains(httpURLRequest.statusCode) else {
                    print("[APIService - Custom Request] Invalid status code: \(httpURLRequest.statusCode)")
                    return
                }

                let pokemon: Pokemon = try JSONDecoder().decode(Pokemon.self, from: data)
                print("[APIService - Custom Request] Response: \(pokemon)")
            } catch {
                print("[APIService - Custom Request] Error: \(error)")

                if let error = error as? APIError, let body = error.responseBody {
                    print("[APIService - Custom Request] Error body: \(body)")
                }
            }
        }
    }

    private func printSpacer() {
        print("\n\n\n")
    }
}
