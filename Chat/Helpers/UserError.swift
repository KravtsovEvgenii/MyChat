//
//  UserError.swift
//  Chat
//
//  Created by User on 22.12.2020.
//

import Foundation


enum UserError {
    case notFilled
    case photoNotExist
    case cannotGetUserInfo
    case cannotCastToChatUser
}

extension UserError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .notFilled:
            return NSLocalizedString("Заполните все поля", comment: "")
        case .photoNotExist:
            return NSLocalizedString("Пользователь не выбрал фотографию", comment: "")
        case .cannotGetUserInfo:
            return NSLocalizedString("Пользователь  не заполнил все поля о себе", comment: "")
        case .cannotCastToChatUser:
            return NSLocalizedString("Не удалось сконвертировать тип до Chat User", comment: "")
        }
    }
}
