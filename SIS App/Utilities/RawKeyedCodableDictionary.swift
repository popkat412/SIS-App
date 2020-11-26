//
//  RawKeyedCodableDictionary.swift
//  SIS App
//
//  Created by Wang Yunze on 7/11/20.
//
//  Stolen from https://gist.github.com/jarrodldavis/8c9e7e6e487991279c2df2d452baaf16

import Foundation

@propertyWrapper
struct RawKeyedCodableDictionary<Key, Value>: Codable where Key: Hashable & RawRepresentable, Key.RawValue: Codable & Hashable, Value: Codable {
    var wrappedValue: [Key: Value]

    init() {
        wrappedValue = [:]
    }

    init(wrappedValue: [Key: Value]) {
        self.wrappedValue = wrappedValue
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawKeyedDictionary = try container.decode([Key.RawValue: Value].self)

        wrappedValue = [:]
        for (rawKey, value) in rawKeyedDictionary {
            guard let key = Key(rawValue: rawKey) else {
                throw DecodingError.dataCorruptedError(
                    in: container, debugDescription: "Invalid key: cannot initalize \(Key.self) from invalid \(Key.RawValue.self) value \(rawKey)"
                )
            }
            wrappedValue[key] = value
        }
    }

    func toDictionary() -> [Key: Value] {
        Dictionary(uniqueKeysWithValues: wrappedValue.map { ($0, $1) })
    }

    func encode(to encoder: Encoder) throws {
        let rawKeyedDictionary = Dictionary(uniqueKeysWithValues: wrappedValue.map { ($0.rawValue, $1) })
        var container = encoder.singleValueContainer()
        try container.encode(rawKeyedDictionary)
    }
}
