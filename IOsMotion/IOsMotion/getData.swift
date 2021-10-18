//
//  ContentView.swift
//  IOsMotion
//
//  Created by Emmanuel Zambrano Quitian on 10/17/21.
//

import SwiftUI
import CoreMotion

struct getData: View {
    let motion = CMMotionManager()
    @State var x:Double = 0
    @State var y:Double = 0
    @State var z:Double = 0
    @State var Xarry:[Double] = []
    @State var Yarry:[Double] = []
    @State var Zarry:[Double] = []
    @State var time:Double = 3.0
    @State var stop:Bool = false //stop and start collecting data
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()//set sub timer, match sf
    let sf = 0.1//sample frequency
    var body: some View {
        VStack{
            if (motion.isDeviceMotionAvailable){// acelerometer aveilable
                    VStack{
                        Text("Available")
                        Text("x: \(x)")
                        Text("y: \(y)")
                        Text("z: \(z)")
                        Button(action: {
                            stop.toggle()
                            Xarry = []
                            Yarry = []
                            Zarry = []
                            if (stop){
                                motion.accelerometerUpdateInterval = sf// set sample frequency for  sensores
                                motion.startAccelerometerUpdates(to: .main) {
                                        (data, error) in
                                        guard let data = data, error == nil else {
                                            return
                                        }
                                    x = data.acceleration.x*10
                                    y = data.acceleration.y*10
                                    z = data.acceleration.z*10
                                    Xarry.append(x)
                                    Yarry.append(y)
                                    Zarry.append(z)
                                    
                                }
                            }else{
                                motion.stopAccelerometerUpdates()
                                
                            }
                        }, label: {
                            Text(stop ? "stop":"start")
                        })
                    }
                
                
               
                
            }else{
                Text("not Available")
            }
            
        }.onReceive(timer){ input in
            let n = Int(time/sf)
            if (Xarry.count==n){
                stop = false
                motion.stopAccelerometerUpdates()
            }
            
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        getData()
    }
}
