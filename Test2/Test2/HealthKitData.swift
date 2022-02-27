//
//  HealthKitData.swift
//  Test2
//
//  Created by Damien Gee on 27/2/22.
//

import Foundation
import HealthKit
import HealthKitUI
import SwiftUICharts
import SwiftUI


class HealthKitData {
    internal init(global_data: [[Float]] = []) {
        self.global_data = global_data
        self.authorizeHealthKit()
    }
    
    let healthStore = HKHealthStore()
    var global_data:[[Float]] = []
    func authorizeHealthKit(){
        let read = Set([HKObjectType.quantityType(forIdentifier: .respiratoryRate)!])
        let share = Set([HKObjectType.quantityType(forIdentifier: .respiratoryRate)!])
        healthStore.requestAuthorization(toShare: share, read: read){
            (chk,error)in
            if(chk){
                print("permission granted")
                self.latestRespiratoryRate()
            }
        }
    }
    
    func latestRespiratoryRate(){
        guard let sampleType = HKObjectType.quantityType(forIdentifier: .respiratoryRate) else{
            return
        }
        let startDate=Calendar.current.date(byAdding: .month,value: -10,to: Date())
        let predicate=HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictEndDate)
        let sortDescriptor=NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescriptor]) { (sample, result, error) in guard error==nil else{
                return
            }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let hourFormatter = DateFormatter()
            hourFormatter.dateFormat = "hh"
            var dates: [String] = []
            var data: [[Float]] = []
            var startDate: String
            var prevDate: String = ""
            var startHour: String
            var prevHr: String = ""
            var cur: [Float] = []
            var hrBreath:Float = 0.0
            var countHr: Int = 0
            for x in result as? [HKSample] ?? []{
                var y = x as! HKQuantitySample
                startDate = dateFormatter.string(from: y.startDate)
                startHour = hourFormatter.string(from: y.startDate)
                if prevDate==""{
                    prevDate = startDate
                    prevHr = startHour
                    dates.append(startDate)
                    hrBreath += Float(y.quantity.doubleValue(for: HKUnit(from: "count/min")))
                    countHr += 1
                }else if !(prevDate==startDate){
                    cur.append(hrBreath/Float(countHr))
                    hrBreath = Float(y.quantity.doubleValue(for: HKUnit(from: "count/min")))
                    countHr = 1
                    prevHr = startHour
                    data.append(cur)
                    cur = []
                    prevDate = startDate
                    dates.append(prevDate)
                }else if startHour==prevHr{
                    hrBreath+=Float(y.quantity.doubleValue(for: HKUnit(from: "count/min")))
                    countHr+=1
                }else if !(startHour==prevHr){
                    cur.append(hrBreath/Float(countHr))
                    hrBreath = Float(y.quantity.doubleValue(for: HKUnit(from: "count/min")))
                    countHr = 1
                    prevHr = startHour
                }

                }
            self.global_data = data
            self.scenario1(data: data)
            self.scenario2(data: data)
            
            
            
            
        }
        healthStore.execute(query)
    }
    
    func scenario1(data: [[Float]]){
        var i:Int=0
        for (index, x) in data.enumerated(){
            if x.count>=8{
                i = index
                break
            }
        }
        let latest = data[i]
        let len = Float(latest.count)
        
        var lessThan12 = Float(0.0)
        var moreThan20 = Float(0.0)
        for x in latest{
            if x<12{
                lessThan12+=1
            }else if x>20{
                moreThan20+=1
            }
        }
        
        if lessThan12>len/2{
            print("Low breathing rate")
        }else if moreThan20>len/2{
            print("High breathing rate")
        }else{
            print("Normal")
        }
        print(latest)
        
    }
    
    func scenario2(data:[[Float]]){
        var daily:[Float] = []
        for x in data{
            daily.append(x.reduce(0,+)/Float(x.count))
        }
        print(daily)
        var first30 = Array(daily[...29])
        print(first30)
        var second30 = Array(daily[30...59])
        print(second30)
        
        let upperbound = second30.reduce(second30[0], {max($0, $1)})
        let lowerbound = second30.reduce(second30[0], {min($0,$1)})
        
        first30.reverse()
        var index = 0
        while index<26{
            if first30[index]>upperbound{
                var count = 1
                while count<5{
                    if first30[index+count]>upperbound{
                        count+=1
                    }else{
                        count=0
                        break
                    }
                }
                if count==5{
                    print("Break in upper bound")
                }
            }
            if daily[index]<lowerbound{
                var count = 1
                while count<5{
                    if first30[index+count]<lowerbound{
                        count+=1
                    }else{
                        count=0
                        break
                    }
                }
                if count==5{
                    print("Break in lower bound")
                }
            }
            index+=1
        }
        
        print("All normal")
        
        
    }
    
    func returnData()->[DataPoint]{
        
        let legend = Legend(color: .blue, label:"Rate", order:1)
        var points : [DataPoint] = []
    
        var daily:[Float] = []
        for x in global_data{
            daily.append(x.reduce(0,+)/Float(x.count))
        }
        
        daily.reverse()
        var i:Int = 0
        for x in daily{
            var label = String(i)
            var key = LocalizedStringKey(label)
            var point = DataPoint(value: Double(x), label: key, legend: legend)
            points.append(point)
            i+=1
        }
        
        return points
        }
    
}
