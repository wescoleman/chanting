//
//  Processor.swift
//  Chanting
//
//  Created by Wesley Coleman on 5/7/18.
//  Copyright © 2018 Wesley Coleman. All rights reserved.
//

import UIKit
import AudioKit

class Delays: UIView{
    //variables needed for delay processor
 
    var filters = [AKThreePoleLowpassFilter]()
    var delays = [AKDelay]()
    var lfos = [AKOscillator]()
    let sineWave = AKTable(.sine, phase: 0.0, count: 4096)
    var inputNode = AKNode()
    var sixteenthNote : Double = 0.0
    var delayTimes: [Double] = []
    var gains: [Double] = []
    func setupDelayTimes() {
        delayTimes = [sixteenthNote*4.0,sixteenthNote*8.0,sixteenthNote*12.0,sixteenthNote*16.0]
        print(sixteenthNote)
        print(delayTimes)

    }

    
    func multitapDelay() -> AKMixer {
        let mix = AKMixer(inputNode)
        var counter = 0
        zip(delayTimes, gains).forEach { (time, gain) -> Void in
            delays.append(AKDelay(inputNode, time: time))
            delays[counter].dryWetMix = 1.0
            
            lfos.append(AKOscillator(waveform: sineWave))
            lfos[counter].amplitude = gain
            lfos[counter].frequency = 0.125
            
            filters.append(AKThreePoleLowpassFilter())
            filters[counter].cutoffFrequency = (lfos[counter].amplitude*200)+800
            
            if delays[counter].isStarted{
                print("delays started")
            }else{
                print("delays not started")
            }
            print("gain: \(gain)")
            print("time: \(time)")
            print("input: \(inputNode.description)")
            
            let booster = AKBooster(delays[counter], gain: gain)
            
            mix.connect(booster)
            print("delay closure called")
            
            counter += 1
            
        }
        return mix
    }
    lazy var multitapDelayOutput = multitapDelay()
}
