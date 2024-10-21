//
//  AudioProcessor.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 21.10.2024.
//

import AVFoundation

class AudioProcessor {
    
    var asset: AVAsset
    var silenceThreshold: Float = -40.0
    
    var assetWriter: AVAssetWriter!
    var assetWriterInput: AVAssetWriterInput!
    
    init(outputURL: URL, asset: AVAsset) {
        self.asset = asset
        do {
            assetWriter = try AVAssetWriter(outputURL: outputURL, fileType: .m4a)

            let audioSettings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVEncoderBitRateKey: 128000,
                AVNumberOfChannelsKey: 2,
                AVSampleRateKey: 44100.0
            ]
            
            assetWriterInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioSettings)
            assetWriterInput.expectsMediaDataInRealTime = true
            assetWriter.add(assetWriterInput)
        } catch {
            print("AssetWriter oluşturulurken hata: \(error)")
        }
    }
    
    func processAudio(skipSilence: Bool, completion: @escaping (URL?) -> Void) {
        guard let audioTrack = asset.tracks(withMediaType: .audio).first else {
            print("Ses dosyası bulunamadı")
            completion(nil)
            return
        }
        
        do {
            let assetReader = try AVAssetReader(asset: asset)
            let outputSettings: [String: Any] = [
                AVFormatIDKey: kAudioFormatLinearPCM,
                AVLinearPCMIsBigEndianKey: false,
                AVLinearPCMIsFloatKey: false,
                AVLinearPCMBitDepthKey: 16
            ]
            
            let readerOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: outputSettings)
            assetReader.add(readerOutput)
            assetReader.startReading()
            
            let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("processed_audio.m4a")
            let writer = try AVAssetWriter(outputURL: outputURL, fileType: .m4a)

            // writerInput için ayarları belirtin
            let audioSettings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVEncoderBitRateKey: 128000,
                AVNumberOfChannelsKey: 2,
                AVSampleRateKey: 44100.0
            ]

            let writerInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioSettings)
            writer.add(writerInput)
            
            writer.startWriting()
            writer.startSession(atSourceTime: .zero)
            
            while assetReader.status == .reading {
                if let sampleBuffer = readerOutput.copyNextSampleBuffer(), let blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer) {
                    let bufferLength = CMBlockBufferGetDataLength(blockBuffer)
                    var data = Data(count: bufferLength)
                    data.withUnsafeMutableBytes { rawBufferPointer in
                        CMBlockBufferCopyDataBytes(blockBuffer, atOffset: 0, dataLength: bufferLength, destination: rawBufferPointer.bindMemory(to: UInt8.self).baseAddress!)
                    }
                    
                    if skipSilence {
                        let audioLevel = self.getAudioLevel(from: data)
                        if audioLevel > self.silenceThreshold {
                            writerInput.append(sampleBuffer)
                        }
                    } else {
                        writerInput.append(sampleBuffer)
                    }
                }
            }
            
            writer.finishWriting {
                if writer.status == .completed {
                    completion(outputURL)
                } else {
                    completion(nil)
                }
            }
            
        } catch {
            print("Ses işleme hatası: \(error)")
            completion(nil)
        }
    }
    
    private func getAudioLevel(from data: Data) -> Float {
        let samples = data.withUnsafeBytes { rawBufferPointer in
            rawBufferPointer.bindMemory(to: Int16.self)
        }
        
        var sum: Int = 0
        for sample in samples {
            sum += abs(Int(sample))
        }
        
        let average = Float(sum) / Float(samples.count)
        let db = 20 * log10(average)
        return db
    }
}
