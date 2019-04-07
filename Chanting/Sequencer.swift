//
//  Sequencer.swift
//  Chanting
//
//  Created by Wesley Coleman on 4/30/18.
//  Copyright © 2018 Wesley Coleman. All rights reserved.
//

import UIKit
import AudioKit
import AudioKitUI

class Sequencer: UIView {

    
   
    var indexNum: Int = 0
    var beats = 16.0
    let audioKitSequencer = AKSequencer()
    var sequenceDuration: AKDuration?
    var sequenceArray : [Int] = []
    var midi = AudioKit.midi
    var track = AKMusicTrack()
    var bpm : Double?
    

    func setupSequence(){
//        midi.createVirtualInputPort()
        midi.createVirtualPorts()
        sequenceArray = Array(repeating: 0, count: Int(beats))
        //audioKitSequencer.setGlobalMIDIOutput(midi.virtualInput)
        track = audioKitSequencer.newTrack()!
        track.setMIDIOutput(midi.virtualInput)
        
        
    }
    
    func playSequence(){
        audioKitSequencer.setLength(AKDuration(beats: 4))
        sequenceDuration = AKDuration(beats: beats, tempo: bpm!)
        audioKitSequencer.setLength(sequenceDuration!)
        audioKitSequencer.enableLooping()
        audioKitSequencer.play()
        print("sequencer started")
    }
    func stopSequence(){
        audioKitSequencer.stop()
        print("sequencer was stopped")
    }
    func generateSequence() {
        track.clear()
        let numOfSteps = Int(beats)
        for i in 0..<numOfSteps {
            track.add(noteNumber: 60, velocity: UInt8(sequenceArray[i]), position: AKDuration(beats: Double(i)), duration: AKDuration(beats: 1))
           
        }
    }
}

extension Sequencer: UICollectionViewDataSource, UICollectionViewDelegate{
    // because it asked for it
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    // cells already made in main.storyboard and I dont want it to make new ones. reusable identifiers are set individually in main.storyboard to "cell \(cellNum)"
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell \(indexPath.item+1)", for: indexPath)
        return cell
    }
    //change member of sequenceArray from note off to note on
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        if indexPath.section == 0{
            sequenceArray[indexPath.item] =  1
            indexNum = indexPath.item
            print(indexNum)
        }
        else if indexPath.section == 1{
            sequenceArray[(indexPath.item)+4] =  1
            indexNum = indexPath.item+4
            print(indexNum)
        }
        else if indexPath.section == 2{
            sequenceArray[(indexPath.item)+8] =  1
            indexNum = indexPath.item+8
            print(indexNum)
        }
        else if indexPath.section == 3{
            sequenceArray[(indexPath.item)+12] =  1
            indexNum = indexPath.item+12
            print(indexNum)
        }
        else{
            print("congratulations... you've some how exceded the bounds of this sequencer")
        }
        collectionView.cellForItem(at: indexPath)?.backgroundColor = UIColor.green
        generateSequence()
    }
    //change member of sequenceArray from note on to note off
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if indexPath.section == 0{
            sequenceArray[indexPath.item] =  0
        }
        else if indexPath.section == 1{
            sequenceArray[(indexPath.item)+4] =  0
        }
        else if indexPath.section == 2{
            sequenceArray[(indexPath.item)+8] =  0
        }
        else if indexPath.section == 3{
            sequenceArray[(indexPath.item)+12] =  0
        }
        else{
            print("congratulations... you've some how exceded the bounds of this sequencer")
        }
        collectionView.cellForItem(at: indexPath)?.backgroundColor = UIColor.blue
        generateSequence()
    }
}

