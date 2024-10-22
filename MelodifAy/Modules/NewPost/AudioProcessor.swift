//
//  AudioProcessor.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 21.10.2024.
//

import AVFoundation

import AVFoundation

class AudioProcessor {
    var asset: AVAsset
    var silenceThreshold: Float = -45.0
    var minimumSilenceDuration: Double = 0.3
    
    init(outputURL: URL, asset: AVAsset) {
        self.asset = asset
    }
    
    func processAudio(skipSilence: Bool, completion: @escaping (URL?) -> Void) {
        guard let audioTrack = asset.tracks(withMediaType: .audio).first else {
            print("Ses dosyası bulunamadı")
            completion(nil)
            return
        }
        
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("m4a")
        
        do {
            let assetReader = try AVAssetReader(asset: asset)
            let readerSettings: [String: Any] = [
                AVFormatIDKey: kAudioFormatLinearPCM,
                AVLinearPCMIsBigEndianKey: false,
                AVLinearPCMIsFloatKey: true,
                AVLinearPCMBitDepthKey: 32,
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 2
            ]
            let readerOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: readerSettings)
            
            let assetWriter = try AVAssetWriter(outputURL: outputURL, fileType: .m4a)
            let writerSettings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVEncoderBitRateKey: 128000,
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 2
            ]
            let writerInput = AVAssetWriterInput(mediaType: .audio, outputSettings: writerSettings)
            writerInput.expectsMediaDataInRealTime = false
            
            guard assetReader.canAdd(readerOutput) else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Cannot add reader output"])
            }
            assetReader.add(readerOutput)
            
            guard assetWriter.canAdd(writerInput) else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Cannot add writer input"])
            }
            assetWriter.add(writerInput)
            
            guard assetReader.startReading() else {
                throw assetReader.error ?? NSError(domain: "", code: -1, userInfo: nil)
            }
            assetWriter.startWriting()
            assetWriter.startSession(atSourceTime: .zero)
            
            let audioProcessingQueue = DispatchQueue(label: "com.audioprocessing.queue")
            var currentTime = CMTime.zero
            var silenceStartTime: CMTime?
            var isInSilence = false
            
            let processingGroup = DispatchGroup()
            processingGroup.enter()
            
            writerInput.requestMediaDataWhenReady(on: audioProcessingQueue) {
                while writerInput.isReadyForMoreMediaData {
                    autoreleasepool {
                        guard let sampleBuffer = readerOutput.copyNextSampleBuffer() else {
                            writerInput.markAsFinished()
                            processingGroup.leave()
                            return
                        }
                        
                        if skipSilence {
                            let audioLevel = self.getAudioLevel(from: sampleBuffer)
                            let bufferDuration = CMSampleBufferGetDuration(sampleBuffer)
                            currentTime = CMTimeAdd(currentTime, bufferDuration)
                            
                            if audioLevel < self.silenceThreshold {
                                if !isInSilence {
                                    isInSilence = true
                                    silenceStartTime = currentTime
                                }
                            } else {
                                if isInSilence {
                                    isInSilence = false
                                    if let startTime = silenceStartTime {
                                        let silenceDuration = CMTimeGetSeconds(CMTimeSubtract(currentTime, startTime))
                                        if silenceDuration < self.minimumSilenceDuration {
                                            writerInput.append(sampleBuffer)
                                        }
                                    }
                                    silenceStartTime = nil
                                } else {
                                    writerInput.append(sampleBuffer)
                                }
                            }
                        } else {
                            writerInput.append(sampleBuffer)
                        }
                    }
                }
            }
            
            processingGroup.wait()
            
            assetWriter.finishWriting {
                if assetWriter.status == .completed {
                    DispatchQueue.main.async {
                        completion(outputURL)
                    }
                } else {
                    print("Yazma hatası: \(assetWriter.error?.localizedDescription ?? "Bilinmeyen hata")")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }
            
        } catch {
            print("Ses işleme hatası: \(error.localizedDescription)")
            completion(nil)
        }
    }
    
    private func getAudioLevel(from sampleBuffer: CMSampleBuffer) -> Float {
        guard let channelData = getPCMBufferFrom(sampleBuffer: sampleBuffer) else {
            return -160.0
        }
        
        var rms: Float = 0.0
        let len = Int(channelData.count)
        
        for i in 0..<len {
            rms += channelData[i] * channelData[i]
        }
        
        rms = sqrtf(rms / Float(len))
        
        if rms > 0 {
            return 20 * log10f(rms)
        } else {
            return -160.0
        }
    }
    
    private func getPCMBufferFrom(sampleBuffer: CMSampleBuffer) -> [Float]? {
        var audioBufferList = AudioBufferList()
        var blockBuffer: CMBlockBuffer?
        
        let status = CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(
            sampleBuffer,
            bufferListSizeNeededOut: nil,
            bufferListOut: &audioBufferList,
            bufferListSize: MemoryLayout<AudioBufferList>.size,
            blockBufferAllocator: nil,
            blockBufferMemoryAllocator: nil,
            flags: kCMSampleBufferFlag_AudioBufferList_Assure16ByteAlignment,
            blockBufferOut: &blockBuffer
        )
        
        guard status == noErr else { return nil }
        
        let buffer = audioBufferList.mBuffers
        let frameLength = Int(buffer.mDataByteSize) / MemoryLayout<Float>.size
        let channelsPerFrame = Int(buffer.mNumberChannels)
        
        guard let data = buffer.mData else { return nil }
        
        let samples = UnsafeBufferPointer<Float>(
            start: data.assumingMemoryBound(to: Float.self),
            count: frameLength
        )
        
        var result = [Float](repeating: 0, count: frameLength)
        for i in 0..<frameLength {
            result[i] = abs(samples[i]) / Float(channelsPerFrame)
        }
        
        return result
    }
}
