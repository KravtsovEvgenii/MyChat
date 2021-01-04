//  Protocols.swift
//  Chat
//  Created by User on 07.12.2020.

import Foundation

protocol SelfConfiguringCell {
    static var reuseId: String { get }
    func configure<U: Hashable>(with value: U)
}
