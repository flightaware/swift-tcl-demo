//
//  main.swift
//  tcl-swift-play
//
//  Created by Karl Lehenbauer on 4/6/16.
//  Copyright © 2016 FlightAware. All rights reserved.
//

import Foundation
import Tcl8_6
import SwiftTcl

print("Hello, World!")
print("Starting tests")

let interp = TclInterp()

    if let result: String = try? interp.eval(code: "puts {Hey stinky}; return hijinks") {
        print("interpreter returned '\(result)'")
    } else {
        print("interpreter failed")
    }

print(interp.result)
    
    if let result: Int = try? interp.eval(code: "expr 1 + 4") {
        print("interpreter returned '\(result)'")
    } else {
        print("interpreter failed")
    }

    var xo = interp.newObject(5)
    let xy = interp.newObject("hi mom")
    print(try xy.get() as String)
    xy.set("hi dad")
    print(try xy.get() as String)
    let xz = interp.newObject(5.5)
    if let xz2: Int = try? xz.get() {
        print(xz2)
    }
    let x5 = interp.newObject(5)
    try print(x5.get() as Double)
    
    var stooges = interp.newObject("Larry Curly Moe")
    for stooge in stooges {
        if let name = stooge.stringValue {
            print(name)
        }
    }
    
    var brothers = interp.newObject(["Groucho", "Harpo", "Chico"])
    try brothers.lappend("Karl")
    if let julius:String = brothers[0] {
        print("Julius is \(julius)")
    }
    
    // List eval test
    try interp.rawEval(list: ["set", "a", "{illegal {string"])
    try interp.rawEval(code: "puts [list a = $a]")
    
    func foo (interp: TclInterp, objv: [TclObj]) -> String {
        print("foo baby foo baby foo baby foo")
        return ""
    }
    
    func avg (interp: TclInterp, objv: [TclObj]) -> Double {
        var sum = 0.0
        var num = 0
        for obj in objv[1...objv.count-1] {
            guard let val: Double = try? obj.get() else {continue}
            sum += val
            num += 1
        }
        return(sum / Double(num))
    }
    
    interp.createCommand(named: "foo", using: foo)
    
    do {
        try interp.rawEval(code: "foo")
    }
    
    interp.createCommand(named: "avg", using: avg)
    do {
        try interp.rawEval(code: "puts \"the average is [avg 1 2 3 4 5 6 7 8 9 10 77]\"")
    }
    
    try interp.rawEval(code: "puts \"the average is [avg 1 2 3 4 5 foo 7 8 9 10 77]\"")
    
    let EARTH_RADIUS_MILES = 3963.0
    
    func fa_degrees_radians (_ degrees: Double) -> Double {
        return (degrees * Double.pi / 180);
    }

    func fa_latlongs_to_distance (_ lat1: Double, lon1: Double, lat2: Double, lon2:Double) -> Double {
        let dLat = fa_degrees_radians (lat2 - lat1)
        let dLon = fa_degrees_radians (lon2 - lon1)

        
        let lat1 = fa_degrees_radians (lat1)
        let lat2 = fa_degrees_radians (lat2)
        
        let sin2 = sin (dLat / 2) * sin (dLat / 2)
        let a = sin2 + sin (dLon / 2) * sin (dLon / 2) * cos (lat1) * cos (lat2)
        let c = 2 * atan2 (sqrt (a), sqrt (1 - a))
        var distance = EARTH_RADIUS_MILES * c
        
        // if result was not a number
        if (distance.isNaN) {
            distance = 0
        }
        
        return distance
    }
    
    func fa_latlongs_to_distance_cmd (interp: TclInterp, objv: [TclObj]) throws -> Double {
        if (objv.count != 5) {
            throw TclError.wrongNumArgs(nLeadingArguments: 0, message: "lat0 lon0 lat1 lon1")
        }

        let lat1: Double = try objv[1].getAsArg(named: "lat1")
        let lon1: Double = try objv[2].getAsArg(named: "lon1")
        let lat2: Double = try objv[3].getAsArg(named: "lat2")
        let lon2: Double = try objv[4].getAsArg(named: "lon2")
            
        let distance = fa_latlongs_to_distance(lat1, lon1: lon1, lat2: lat2, lon2: lon2)
        return distance
    }
    
    interp.createCommand(named: "fa_latlongs_to_distance", using: fa_latlongs_to_distance_cmd)

    
    do {
        try interp.rawEval(code: "puts \"distance from KIAH to KSEA is [fa_latlongs_to_distance  29.9844444 -95.3414444 47.4498889 -122.3117778]\"")
    }
    
    print("importing a swift array")
    var ints: [Int] = [0, 1, 2, 3, 4, 5, 6, 7, 9, 8, 10]
    var intListObj = interp.newObject(ints)
    print(ints)
    print(try intListObj.get() as String)
    print("")

    let sarray = ["zero","one","two","three","four"]
    print("Testing ranges and indexes on \(sarray)")
    let xarray = interp.newObject(sarray)
    print(" xarray.lrange(1...3) = \(String(describing: try xarray.lrange(1...3) as [String]))")
    print(" xarray.lrange(-3 ... -1) = \(String(describing: try xarray.lrange(-3 ... -1) as [String]))")
    print(" xarray.lindex(1) = \(try xarray.lindex(1) as String)")
    print(" xarray.lindex(-1) = \(try xarray.lindex(-1) as String)")
    print("Testing subscripts")
    print(" xarray[0] = \(xarray[0] as String?)")
    print(" xarray[0...2] = \(xarray[0...2] as [String]?)")
    print(" xarray as String = \(try xarray.get() as String)")
    try xarray.linsert(5, list: ["five"])
    print(" after insert at end: xarray as String = \(try xarray.get() as String)")
    try xarray.lreplace(0...2, list: ["0", "uno", "II"])
    print(" after replace at beginning: xarray as String = \(try xarray.get() as String)")
    xarray[0...2] = ["ZERO", "ONE", "TWO"]
    xarray[3] = "(3)"
    print(" after subscript assignment: xarray as String = \(try xarray.get() as String)")
    xarray[4...4] = ["4", "four", "IV", "[d]"]
    print(" after subscript assignment changing length: xarray as String = \(try xarray.get() as String)")
    xarray[5...7] = [] as [String]
    print(" after subscript assignment deleting elements: xarray as String = \(try xarray.get() as String)")
    xarray[0] = false
    xarray[1...4] = [1, 2, 3, 4]
    xarray[5] = 5.0
    print(" after subscript assignment of typed values: xarray as String = \(try xarray.get() as String)")
    print("\nTesting generator")
    var list = ""
    var sum = 0.0
    var count = 0
    for obj in xarray {
        if let v: Double = try? obj.get() {
            if list == "" {
                list = "{" + String(v)
            } else {
                list = list + ", " + String(v)
            }
            sum += v
            count += 1
        }
    }
    list += "}"
    print("sum of \(list) is \(sum), average is \(sum / Double(count))")

    print("Testing variable access")
    try interp.rawEval(code: "set fred 1");
    if let value: String = interp.get(variable: "fred") {
        print("   Value of 'fred' is \(value)");
    }
    if let value: String = interp.get(variable: "barney") {
        print("   Value of 'barney' is \(value)");
    } else {
        print("    There is no 'barney'");
    }

    let testdict = ["name": "Nick", "age": "32", "role": "hustler"]
    print("\nTesting array type on \(testdict)")
    if let character = try? interp.newArray("character", dict: testdict) {
        print("character[\"name\"] as String = \(character["name"] as String?)")
        print("character.names() = \(try character.names())")
        print("character.get() = \(try character.get() as [String: String])")

        print("\nModifying character")
        character["name"] = "Nick Wilde"
        character["animal"] = "fox"
        character["role"] = "cop"
        character["movie"] = "Zootopia"
        print("character[\"name\"] as String = \(character["name"] as String?)")
        print("character.names() = \(try character.names())")
        print("character.get() = \(try character.get() as [String: String])")

        print("\nsubst test")
        print(try interp.subst("character(name) = $character(name)"))
        
        print("\ngenerator test")
        for (key, value) in character {
            try print("character[\"\(key)\"] = \(value.get() as String)")
        }
    } else {
        print("Could not initialize array from dictionary.")
    }

    print("\ndigging variables out of the Tcl interpreter")
    var autoPath: String = try! interp.get(variable: "auto_path")
    print("auto_path is '\(autoPath)'")

    let tclVersion: Double = try! interp.get(variable: "tcl_version")
    print("Tcl version is \(tclVersion)")
    print("")

    print("sticking something extra into the tcl_platform array")
    try! interp.set(variable: "tcl_platform", element: "swift", value: "enabled")

    do {try interp.rawEval(code: "array get tcl_platform")}
    var dict: [String:String] = try! interp.resultObj.get()
    print(dict)
    var version = dict["osVersion"]!
    print("Your OS is \(dict["os"]!), running version \(version)")

    var machine: String = interp.get(variable: "tcl_platform", element: "machine")!
    var byteOrder: String = interp.get(variable: "tcl_platform", element: "byteOrder")!
    print("Your machine is \(machine) and your byte order is \(byteOrder)")
    print("")

    print("intentionally calling a swift extension with a bad argument")
    let _ = try? interp.rawEval(code: "puts \"distance from KIAH to KSEA is [fa_latlongs_to_distance  29.9844444 -95.3414444 crash -122.3117778]\"")
    let _ = try? interp.rawEval(code: "puts \"distance from KIAH to KSEA is [fa_latlongs_to_distance  29.9844444 -95.3414444]\"")
    
    // Comparing speed of operations.
    var a: [String] = []
    for i in 1...100000 {
        a += [String(i)]
    }
    
    let timer = stopwatch()
    var i = 0
    var s: String = ""
    for e in a {
        s = e
        i += 1
    }
    print("Took \(timer.mark())s final \(i)\(s)")
    
    timer.reset()
    a.forEach {
        s = $0
        i += 1
    }
    print("Took \(timer.mark())s final \(i)\(s)")
    
    timer.reset()
    for e in a {
        s = e
        i += 1
    }
    print("Took \(timer.mark())s final \(i)\(s)")

    
    // Testing generated Tcl code
    print("")
    print("Testing generated Swift wrapper")
    impork(interp)
