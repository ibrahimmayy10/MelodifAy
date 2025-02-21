//
//  NewPostViewModel.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 4.10.2024.
//

import Foundation
//import GoogleGenerativeAI

protocol CreateSongWithAIViewModelProtocol {
    func generateSong(theme: String, mood: String, genre: String, tempo: String, instrument: String, songLength: Int, mainMessage: String, completion: @escaping (String) -> Void)
}

final class CreateSongWithAIViewModel: CreateSongWithAIViewModelProtocol {
    func generateSong(theme: String, mood: String, genre: String, tempo: String, instrument: String, songLength: Int, mainMessage: String, completion: @escaping (String) -> Void) {
//        let model = GenerativeModel(name: "gemini-pro", apiKey: "AIzaSyCjN0gdHqtXq_9Bcu0oy19LXlC9cjukTTo")
//        let textInput = "Lütfen \(songLength) tane kelime uzunluğunda, \(mood) ruh haline sahip bir \(genre) şarkı oluşturun. Şarkının ana teması \(theme) olacak ve temposu \(tempo) olmalıdır. Şarkıda ağırlıklı olarak \(instrument) enstrümanı kullanılacak. Şarkının ana mesajı şu şekilde olmalı: \(mainMessage). Bu bilgilere göre şarkı sözü ve nota oluşturur musun?"
//        var aiResponse = ""
//        
//        Task {
//            do {
//                let response = try await model.generateContent(textInput)
//                guard let text = response.text else { return }
//                
//                aiResponse = text
//                completion(aiResponse)
//            } catch {
//                completion("Hata oluştu.")
//            }
//        }
    }
}
