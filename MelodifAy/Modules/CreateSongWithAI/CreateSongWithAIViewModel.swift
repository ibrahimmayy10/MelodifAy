//
//  NewPostViewModel.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 4.10.2024.
//

import Foundation
import GoogleGenerativeAI

protocol CreateSongWithAIViewModelProtocol {
    func generateSong(theme: String, mood: String, genre: String, tempo: String, instrument: String, songLength: String, mainMessage: String, completion: @escaping (String) -> Void)
}

final class CreateSongWithAIViewModel: CreateSongWithAIViewModelProtocol {
    func generateSong(theme: String, mood: String, genre: String, tempo: String, instrument: String, songLength: String, mainMessage: String, completion: @escaping (String) -> Void) {
        let model = GenerativeModel(name: "gemini-2.0-flash", apiKey: "AIzaSyCto_9Z6CZz_w52aYOqttQ4x3CZYXuKYKM")
        let textInput = """
        Bir şarkı bestele ve söz yaz. Şarkının özellikleri şunlardır:

        Ana tema: \(theme)
        Ruh hali: \(mood)
        Müzik türü: \(genre)
        Tempo: \(tempo)
        Ana enstrüman: \(instrument)
        Şarkı yapısı: \(songLength)
        Ana mesaj: \(mainMessage)

        Lütfen aşağıdaki formatta cevap ver:
        Şarkı Adı (Şarkı adı burada yazmalı, ancak "Şarkı Adı" şeklinde bir ibare olmamalıdır.)
        Şarkı sözleri (Şarkı sözleri buraya yazılmalı, ancak "Şarkı Sözleri" başlığı olmamalıdır.)
        Enstrüman notaları (Burada enstrümana göre notalar olmalıdır, ancak "Enstrüman notaları" başlığı olmamalıdır.)
        Cevap verirken cevaplarına başlık koyma ve senden istediklerim dışında hiçbir şey yazma.

        Şarkı sözleri özgün ve anlamlı olmalı, \(mainMessage) mesajını iletmeli. Şarkı yapısı \(songLength) olarak belirtilmiş şekilde olmalı.
        Sadece yukarıdaki formatı uygula.
        """
        var aiResponse = ""
        
        Task {
            do {
                let response = try await model.generateContent(textInput)
                guard let text = response.text else { return }
                
                aiResponse = text
                completion(aiResponse)
            } catch {
                completion("Hata oluştu.")
            }
        }
    }
}
