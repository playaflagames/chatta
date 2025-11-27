//
//  TelemetryEntity+CoreDataClass.swift
//
//
//  Created by Jake Bordens on 12/26/24.
//
//

import Foundation
import CoreData

// Manual implementation of the TelemetryEntry object for CoreData.
//   Using computed properties to handle optional scalar types.
//   CoreData is based on Objective-C, which doesn't have optional scalars.
//   These computed properties handle the conversion to optional scalars.

@objc(TelemetryEntity)
public class TelemetryEntity: NSManagedObject, Identifiable {

	public var airUtilTx: Float? {
		get { (primitiveValue(forKey: "airUtilTx") as? NSNumber)?.floatValue }
		set { setPrimitiveValue(newValue.map { NSNumber(value: $0) }, forKey: "airUtilTx") }
	}

	public var barometricPressure: Float? {
		get { (primitiveValue(forKey: "barometricPressure") as? NSNumber)?.floatValue }
		set { setPrimitiveValue(newValue.map { NSNumber(value: $0) }, forKey: "barometricPressure") }
	}

	public var batteryLevel: Int32? {
		get { (primitiveValue(forKey: "batteryLevel") as? NSNumber)?.int32Value }
		set { setPrimitiveValue(newValue.map { NSNumber(value: $0) }, forKey: "batteryLevel") }
	}

	public var channelUtilization: Float? {
		get { (primitiveValue(forKey: "channelUtilization") as? NSNumber)?.floatValue }
		set { setPrimitiveValue(newValue.map { NSNumber(value: $0) }, forKey: "channelUtilization") }
	}

	public var current: Float? {
		get { (primitiveValue(forKey: "current") as? NSNumber)?.floatValue }
		set { setPrimitiveValue(newValue.map { NSNumber(value: $0) }, forKey: "current") }
	}

	public var distance: Float? {
		get { (primitiveValue(forKey: "distance") as? NSNumber)?.floatValue }
		set { setPrimitiveValue(newValue.map { NSNumber(value: $0) }, forKey: "distance") }
	}

	public var gasResistance: Float? {
		get { (primitiveValue(forKey: "gasResistance") as? NSNumber)?.floatValue }
		set { setPrimitiveValue(newValue.map { NSNumber(value: $0) }, forKey: "gasResistance") }
	}

	public var iaq: Int32? {
		get { (primitiveValue(forKey: "iaq") as? NSNumber)?.int32Value }
		set { setPrimitiveValue(newValue.map { NSNumber(value: $0) }, forKey: "iaq") }
	}

	var powerCh1Current: Float? {
		get { (primitiveValue(forKey: "powerCh1Current") as? NSNumber)?.floatValue }
		set { setPrimitiveValue(newValue.map { NSNumber(value: $0) }, forKey: "powerCh1Current") }
	}

	var powerCh1Voltage: Float? {
		get { (primitiveValue(forKey: "powerCh1Voltage") as? NSNumber)?.floatValue }
		set { setPrimitiveValue(newValue.map { NSNumber(value: $0) }, forKey: "powerCh1Voltage") }
	}

	var powerCh2Current: Float? {
		get { (primitiveValue(forKey: "powerCh2Current") as? NSNumber)?.floatValue }
		set { setPrimitiveValue(newValue.map { NSNumber(value: $0) }, forKey: "powerCh2Current") }
	}

	var powerCh2Voltage: Float? {
		get { (primitiveValue(forKey: "powerCh2Voltage") as? NSNumber)?.floatValue }
		set { setPrimitiveValue(newValue.map { NSNumber(value: $0) }, forKey: "powerCh2Voltage") }
	}

	var powerCh3Current: Float? {
		get { (primitiveValue(forKey: "powerCh3Current") as? NSNumber)?.floatValue }
		set { setPrimitiveValue(newValue.map { NSNumber(value: $0) }, forKey: "powerCh3Current") }
	}

	var powerCh3Voltage: Float? {
		get { (primitiveValue(forKey: "powerCh3Voltage") as? NSNumber)?.floatValue }
		set { setPrimitiveValue(newValue.map { NSNumber(value: $0) }, forKey: "powerCh3Voltage") }
	}

	public var relativeHumidity: Float? {
		get { (primitiveValue(forKey: "relativeHumidity") as? NSNumber)?.floatValue }
		set { setPrimitiveValue(newValue.map { NSNumber(value: $0) }, forKey: "relativeHumidity") }
	}

	public var rssi: Int32? {
		get { (primitiveValue(forKey: "rssi") as? NSNumber)?.int32Value }
		set { setPrimitiveValue(newValue.map { NSNumber(value: $0) }, forKey: "rssi") }
	}

	public var snr: Float? {
		get { (primitiveValue(forKey: "snr") as? NSNumber)?.floatValue }
		set { setPrimitiveValue(newValue.map { NSNumber(value: $0) }, forKey: "snr") }
	}

	public var temperature: Float? {
		get { (primitiveValue(forKey: "temperature") as? NSNumber)?.floatValue }
		set { setPrimitiveValue(newValue.map { NSNumber(value: $0) }, forKey: "temperature") }
	}

	public var uptimeSeconds: Int32? {
		get { (primitiveValue(forKey: "uptimeSeconds") as? NSNumber)?.int32Value }
		set { setPrimitiveValue(newValue.map { NSNumber(value: $0) }, forKey: "uptimeSeconds") }
	}

	public var voltage: Float? {
		get { (primitiveValue(forKey: "voltage") as? NSNumber)?.floatValue }
		set { setPrimitiveValue(newValue.map { NSNumber(value: $0) }, forKey: "voltage") }
	}

	public var weight: Float? {
		get { (primitiveValue(forKey: "weight") as? NSNumber)?.floatValue }
		set { setPrimitiveValue(newValue.map { NSNumber(value: $0) }, forKey: "weight") }
	}

	public var windDirection: Int32? {
		get { (primitiveValue(forKey: "windDirection") as? NSNumber)?.int32Value }
		set { setPrimitiveValue(newValue.map { NSNumber(value: $0) }, forKey: "windDirection") }
	}

	public var windGust: Float? {
		get { (primitiveValue(forKey: "windGust") as? NSNumber)?.floatValue }
		set { setPrimitiveValue(newValue.map { NSNumber(value: $0) }, forKey: "windGust") }
	}

	public var windLull: Float? {
		get { (primitiveValue(forKey: "windLull") as? NSNumber)?.floatValue }
		set { setPrimitiveValue(newValue.map { NSNumber(value: $0) }, forKey: "windLull") }
	}

	public var windSpeed: Float? {
		get { (primitiveValue(forKey: "windSpeed") as? NSNumber)?.floatValue }
		set { setPrimitiveValue(newValue.map { NSNumber(value: $0) }, forKey: "windSpeed") }
	}

	public var irLux: Float? {
		get { (primitiveValue(forKey: "irLux") as? NSNumber)?.floatValue }
		set { setPrimitiveValue(newValue.map { NSNumber(value: $0) }, forKey: "irLux") }
	}

	public var lux: Float? {
		get { (primitiveValue(forKey: "lux") as? NSNumber)?.floatValue }
		set { setPrimitiveValue(newValue.map { NSNumber(value: $0) }, forKey: "lux") }
	}

	public var uvLux: Float? {
		get { (primitiveValue(forKey: "uvLux") as? NSNumber)?.floatValue }
		set { setPrimitiveValue(newValue.map { NSNumber(value: $0) }, forKey: "uvLux") }
	}

	public var whiteLux: Float? {
		get { (primitiveValue(forKey: "whiteLux") as? NSNumber)?.floatValue }
		set { setPrimitiveValue(newValue.map { NSNumber(value: $0) }, forKey: "whiteLux") }
	}

	public var radiation: Float? {
		get { (primitiveValue(forKey: "radiation") as? NSNumber)?.floatValue }
		set { setPrimitiveValue(newValue.map { NSNumber(value: $0) }, forKey: "radiation") }
	}

	public var rainfall1H: Float? {
		get { (primitiveValue(forKey: "rainfall1H") as? NSNumber)?.floatValue }
		set { setPrimitiveValue(newValue.map { NSNumber(value: $0) }, forKey: "rainfall1H") }
	}

	public var rainfall24H: Float? {
		get { (primitiveValue(forKey: "rainfall24H") as? NSNumber)?.floatValue }
		set { setPrimitiveValue(newValue.map { NSNumber(value: $0) }, forKey: "rainfall24H") }
	}

	public var soilTemperature: Float? {
		get { (primitiveValue(forKey: "soilTemperature") as? NSNumber)?.floatValue }
		set { setPrimitiveValue(newValue.map { NSNumber(value: $0) }, forKey: "soilTemperature") }
	}

	public var soilMoisture: UInt32? {
		get { (primitiveValue(forKey: "soilMoisture") as? NSNumber)?.uint32Value }
		set { setPrimitiveValue(newValue.map { NSNumber(value: $0) }, forKey: "soilMoisture") }
	}

}
