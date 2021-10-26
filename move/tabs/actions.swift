//
//  actions.swift
//  move
//
//  Created by Emmanuel Zambrano Quitian on 10/23/21.
//

import SwiftUI
import AVFoundation
import CoreMotion
struct actions: View {
    let motion = CMMotionManager()
    let sf:Double = 1/60
    let timer = Timer.publish(every: 1/60, on: .main, in: .common).autoconnect()
    let defaults = UserDefaults.standard
    @State var to:CGFloat = 0
    @State var start:Bool = false
    @State var myStrings: [String]
    @State var Xarry:[Double] = []
    @State var Yarry:[Double] = []
    @State var Zarry:[Double] = []
    @State var XYZ:[[Double]] = [[],[],[]]
    @State var time:(Double) = 5
    var body: some View {
        VStack{
            timerDis(to: $to,time: $time).padding().onReceive(timer) { input in
                if (start){
                    withAnimation(.default){
                        to += sf
                    }
                    if (to>=time){
                        withAnimation(.default){
                            to = 0
                            start = false
                            motion.stopAccelerometerUpdates()
                            makepredictions(myStrings:myStrings)
                            //tomar deicicion
                            XYZ[0] = []
                            XYZ[1] = []
                            XYZ[2] = []
                        }
                    }
                }
            }
            Button(action: {
                withAnimation(.default){
                    start.toggle()
                }
                if (start){
                    talk(words: "Start")
                    //collect data
                    motion.accelerometerUpdateInterval = sf
                    motion.startAccelerometerUpdates(to: .main) {
                            (data, error) in
                            guard let data = data, error == nil else {
                                return
                            }
                        let x = data.acceleration.x*10
                        let y = data.acceleration.y*10
                        let z = data.acceleration.z*10
                        XYZ[0].append(x)
                        XYZ[1].append(y)
                        XYZ[2].append(z)
                    }
                }
            }, label: {
                buttonPP(start: $start)
            })
        }
    }
}
func makepredictions(myStrings: [String]){

    let randomInt = Int.random(in: 0..<myStrings.count)
    let defaults = UserDefaults.standard
    let sentcurrent = defaults.object(forKey:"SavedArray") as? [String] ?? myStrings
    print("\(myStrings[randomInt]) word \(sentcurrent[randomInt])")
    talk(words: "\(myStrings[randomInt]) word \(sentcurrent[randomInt])")

}

func talk(words: String){
    let utterance = AVSpeechUtterance(string: words)
    utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
    utterance.rate = 0.4

    let synthesizer = AVSpeechSynthesizer()
    synthesizer.speak(utterance)
    return
}

struct actions_Previews: PreviewProvider {
    static var previews: some View {
        actions(myStrings:[""])
    }
}

struct timerDis: View {
    @Binding var to:CGFloat
    @Binding var time:Double
    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: 1)
                .stroke(Color.gray.opacity(0.25),style: StrokeStyle(lineWidth: 35, lineCap: .round)).frame(width: 250, height: 250).rotationEffect(.init(degrees: Double(0)))
            Circle()
                .trim(from: 0, to: to/time)
                .stroke(Color.blue,style: StrokeStyle(lineWidth: 26, lineCap: .round))
                .frame(width: 250, height: 250).rotationEffect(.init(degrees: -90))
            VStack{
                Text("\(Int(to))").font(.system(size: 65)).fontWeight(.bold)
            }
        }
    }
}

struct buttonPP: View {
    @Binding var start:Bool
    var body: some View {
        Capsule().fill(Color("WB")).frame(width: 120, height: 50).overlay(
            HStack{
                Image(systemName: start ? "pause.fill":"play.fill").foregroundColor(Color.white)
                Text(start ? "Pause":"Start").foregroundColor(.white)
            }
        )
    }
}
