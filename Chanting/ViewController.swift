//
//  ViewController.swift
//  Chanting
//
//  Created by Wesley Coleman on 4/29/18.
//  Copyright © 2018 Wesley Coleman. All rights reserved.
//

import UIKit
import AudioKit
import AudioKitUI
    
    class ViewController: UIViewController, AKMIDIListener{


        //declarations for view
        var multitapDelayOutput = AKNode()
        let sequencer = Sequencer()
        var micRecorder: AKNodeRecorder!
        var mainMixer: AKMixer!
        var micBooster: AKBooster!
        let microphone = AKMicrophone()
        let midi = AudioKit.midi
        var audioSample = try! AKAudioFile()
        let samplePlayer = AKSamplePlayer()
        var sequencerBPM = 120.0
        var sixteenthNote : Double!
        var costelloReverb = AKCostelloReverb()
        var delays = Delays()
        
        //IB functions and variables
        @IBOutlet var bpmSlider: UISlider!
        @IBAction func bpmSlider(_ sender: Any) {
            sequencerBPM = Double(bpmSlider.value)
            sequencer.bpm = Double(bpmSlider.value)
            sequencer.audioKitSequencer.setTempo(Double(bpmSlider.value))
            print("direct Slider Value:\(bpmSlider.value)")
            print(sequencerBPM)
            print(sequencer.bpm!)
            print(sequencer.audioKitSequencer.tempo)
            
            //delays not syncing IDK why
            delays.sixteenthNote = (60.0/Double(bpmSlider.value))/16.0
            delays.setupDelayTimes()
            
        }
        
        @IBOutlet weak var reverbSlider: UISlider!
        @IBAction func reverbSliderAction(_ sender: Any) {
            costelloReverb.feedback = Double(reverbSlider.value)
        }
        
        @IBAction func startSequenceButton(_ sender: Any) {
            sequencer.generateSequence()
            receivedMIDINoteOn(noteNumber: 60, velocity: 1, channel: 1)
            //receivedMIDINoteOff(noteNumber: 60, velocity: 0, channel: 1)
            sequencer.playSequence()
            
        }
        @IBAction func stopSequeneButton(_ sender: Any) {
            sequencer.stopSequence()
        }
        
        @IBOutlet weak var sequenceCollectionView: UICollectionView!
        
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
        
        override func viewDidLoad() {
            
            
            //try? player = AKAudioPlayer(file: audioSample)
            
            super.viewDidLoad()
            microphone.start()
            
            print("Audio format is: \(AKSettings.audioFormat.settings)")
            
            sequenceCollectionView.delegate = sequencer
            sequenceCollectionView.dataSource = sequencer
            sequenceCollectionView.allowsMultipleSelection = true
            sequencer.setupSequence()
            
            do {
                try AKSettings.setSession(category: .playAndRecord, with: .allowBluetoothA2DP)
            } catch {
                print("could not set session category")
            }
            
            micBooster = AKBooster(microphone)
            micBooster.gain = 1
            AKSettings.bufferLength = .medium
            AKSettings.defaultToSpeaker = true
            micRecorder = try! AKNodeRecorder(node: micBooster)
            
            
            delays.inputNode = samplePlayer
            sixteenthNote = (60.0/Double(bpmSlider.value))/16.0
            delays.sixteenthNote = sixteenthNote
            delays.gains = [1.0,1.0,1.0,1.0]
            //delays.setupDelayTimes()
            

            sequencer.bpm = Double(bpmSlider.value)
            sixteenthNote = (60/Double(bpmSlider.value))/16
            multitapDelayOutput = delays.multitapDelayOutput
            let delayMixer = AKMixer(samplePlayer,multitapDelayOutput)
            costelloReverb = AKCostelloReverb(delayMixer, feedback: Double(reverbSlider.value), cutoffFrequency: 4000.00)
            mainMixer = AKMixer(costelloReverb, multitapDelayOutput)
            
            
            //set the view that creates our midi ports as the midi client
            midi.client = sequencer.midi.client
            midi.addListener(self)
            AudioKit.output = mainMixer
            
            do{ try AudioKit.start()
            }catch{
                print("cant start audio system")
                AKLog("cant start audio system")
            }
            
            if AudioKit.engine.isRunning{
                print("engine is running")
            }
            else{
                print("engine is not running")
            }
        }
        
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////


        @IBAction func recordSound(_ sender: Any) {
            do{ try micRecorder.reset()
            }catch{
                print("could not reset microphone audio")
            }
            do{ try micRecorder.record()
            }catch{
                print("trouble recording mic input")
            }
            if micRecorder.isRecording{
                print("mic is recording")
            }
        }

//////////////////////////////////////////////////////////////////////////////////
        @IBAction func stopRecording(_ sender: Any) {
            
            audioSample = micRecorder.audioFile!
            micRecorder.stop()
            samplePlayer.load(file: audioSample)
            if micRecorder.isRecording == false{
                print("mic has stopped recording")
            }
        }
//////////////////////////////////////////////////////////////////////////////////
        @IBAction func playRecording(_ sender: Any) {
            if samplePlayer.isStarted{
                print("sample player is started")
            }
            samplePlayer.play()
        }
//////////////////////////////////////////////////////////////////////////////////
        @IBAction func stopPlaying(_ sender: Any) {
            samplePlayer.stop()
            if samplePlayer.isStarted == false{
                print("sample player is started")
            }
            print("audio sample stopped")
        }
        func receivedMIDINoteOn(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
            samplePlayer.play()
            print("note:\(noteNumber) "+"velocity:\(velocity)")
        }
//        func receivedMIDINoteOff(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
//            samplePlayer.stop()
//            print("note:\(noteNumber) "+"velocity:\(velocity)")
//        }
    
}

