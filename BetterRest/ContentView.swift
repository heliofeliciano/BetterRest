import CoreML
import SwiftUI

struct ContentView: View {
    
    @State private var alertTile = ""
    @State private var alertMessage = ""
    @State private var alertShowing = false
     
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    @State private var title: String = ""
    @State private var message: String = ""
    
    init() {
        calculateBedtime2()
    }
    
    var body: some View {
                
        NavigationView {
            Form {
                Section {
                    Text("When do you want to wake up?")
                        .font(.headline)
                    DatePicker("Please enter a time",
                               selection: $wakeUp,
                               displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .onChange(of: wakeUp) { _ in
                        calculateBedtime2()
                    }
                }
                
                Section {
                    Text("Desired amount of sleep")
                        .font(.headline)
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                        .onChange(of: sleepAmount) { _ in
                            calculateBedtime2()
                        }
                }
    
                Section {
                    Text("Daily coffee intake")
                        .font(.headline)
                    let coffeeAmountFormatted = coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups"
                    Stepper(coffeeAmountFormatted, value: $coffeeAmount, in: 1...20)
                        .onChange(of: coffeeAmount) { _ in
                            calculateBedtime2()
                        }
                }
                
                Section {
                    Picker("Number of cups", selection: $coffeeAmount) {
                        ForEach(1...20, id: \.self) { index in
                            let coffeeAmountFormatted = index == 1 ? "1 cup" : "\(index) cups"
                            Text(coffeeAmountFormatted)
                        }
                    }
                }
                
                VStack {
                    Text(message)
                }
            }
            .navigationTitle("BetterRest")
            .toolbar {
                Button("Calculate", action: calculateBedtime)
            }
            .alert(alertTile, isPresented: $alertShowing) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    func calculateBedtime() {
        
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute),
                                                  estimatedSleep: sleepAmount,
                                                  coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            alertTile = "Your ideal bedtime is ..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
            
        } catch {
            
            alertTile = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
        }
        
        alertShowing = true
    }
    
    func calculateBedtime2() {
        
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute),
                                                  estimatedSleep: sleepAmount,
                                                  coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            title = "Your ideal bedtime is ..."
            message = sleepTime.formatted(date: .omitted, time: .shortened)
            
        } catch {
            
            title = "Error"
            message = "Sorry, there was a problem calculating your bedtime."
        }
    }
    
    func componentDate() -> Date {
        
        var components = DateComponents()
        components.hour = 8
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    func getHoursAndMinutes(from date: Date) -> String {
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        
        return "\(hour):\(minute)"
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
