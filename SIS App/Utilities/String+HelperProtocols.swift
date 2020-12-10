//
//  String+HelperProtocols.swift
//  SIS App
//
//  Created by Wang Yunze on 3/12/20.
//

import Foundation

extension String: Identifiable { public var id: String { self }}

extension String: LocalizedError {
    public var errorDescription: String? { self }
}
