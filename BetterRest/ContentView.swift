//
//  ContentView.swift
//  BetterRest
//
//  Created by Николай Никитин on 13.08.2022.
//

import CoreML
import SwiftUI

struct ContentView: View {
  @State private var wakeUp = defaultWakeTime
  @State private var sleepAmount = 8.0
  @State private var coffeeAmount = 1

  @State private var alertTitle = ""
  @State private var alertMessage = ""
  @State private var showingAlert = false

  static var defaultWakeTime: Date {
    var components = DateComponents()
    components.hour = 7
    components.minute = 0
    return Calendar.current.date(from: components) ?? Date.now
  }

  var body: some View {
    NavigationView {
      Form {
        Section {
          DatePicker("Please enter time", selection: $wakeUp, displayedComponents: .hourAndMinute)
            .labelsHidden()
        } header: {
          Text("When do you want to wake up?")
            .font(.headline)
        }

        Section{
          Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
        } header: {
          Text("Desired amount of sleep")
            .font(.headline)
        }

        Section {
          Picker("Number of cups", selection: $coffeeAmount) {
            ForEach(0..<20) {
              Text($0 > 1 ? "\($0) cups" : "\($0) cup")
            }
          }
          .pickerStyle(WheelPickerStyle())
        } header: {
          Text("Number of cups")
            .font(.headline)
        }

        Section {
          Button {
            calculateBedTime()
          } label: {
            HStack {
              Image(systemName: "function")
                .font(.title)
              Text("Calculate")
                .fontWeight(.semibold)
                .font(.title)
            }
          }
          .frame(minWidth: 0, maxWidth: .infinity)
          .padding()
          .foregroundColor(.white)
          .background(LinearGradient(gradient: Gradient(colors: [Color.red, Color.blue]), startPoint: .leading, endPoint: .trailing))
          .cornerRadius(40)
        }
      }
      .navigationTitle("BetterRest")
      .toolbar {
        Text(alertMessage != "" ? "Your ideal bedtime is \(alertMessage)" : "")
          .fontWeight(.bold)
          .font(.title3)
          .foregroundColor(.red)
      }
      .alert(alertTitle, isPresented: $showingAlert) {
        Button("OK") { }
      } message: {
        Text(alertMessage)
      }
    }
  }

  //MARK: - Methods
  func calculateBedTime() {
    do {
      let config = MLModelConfiguration()
      let model = try SleepCalculator(configuration: config)
      let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
      let hour = (components.hour ?? 0) * 60 * 60
      let minute = (components.minute ?? 0) * 60
      let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
      let sleepTime = wakeUp - prediction.actualSleep
      alertTitle = "Your ideal bedtime is..."
      alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
    } catch {
      alertTitle = "Error"
      alertMessage = "Sorry, there was a problem calculating your bedtime."
    }
    showingAlert = true
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
