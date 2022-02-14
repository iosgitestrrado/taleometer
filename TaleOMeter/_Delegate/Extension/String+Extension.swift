//
//  String+Extension.swift
//  TaleOMeter
//
//  Created by Durgesh on 14/02/22.
//

import Foundation

extension String {
    //Country Flag
    static func flag(for code: String) -> String? {
        func isLowercaseASCIIScalar(_ scalar: Unicode.Scalar) -> Bool {
            return scalar.value >= 0x61 && scalar.value <= 0x7A
        }
        
        func regionalIndicatorSymbol(for scalar: Unicode.Scalar) -> Unicode.Scalar {
            precondition(isLowercaseASCIIScalar(scalar))
            return Unicode.Scalar(scalar.value + (0x1F1E6 - 0x61))!
        }
        
        let lowercaseCode = code.lowercased()
        guard lowercaseCode.count == 2 else { return nil }
        guard lowercaseCode.unicodeScalars.reduce(true, { partialResult, scalar in
            isLowercaseASCIIScalar(scalar)
        }) else { return nil }
        
        let indicatorSymbols = lowercaseCode.unicodeScalars.map { regionalIndicatorSymbol(for: $0)}
        return String(indicatorSymbols.map({ Character($0) }))
    }
    
    //To check text field or String is blank or not
    var isBlank: Bool {
        get {
            let trimmed = trimmingCharacters(in: .whitespaces)
            return trimmed.isEmpty
        }
    }

    //Validate Email
    var isEmail: Bool {
        do {
            let regex = try NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}", options: .caseInsensitive)
            return regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count)) != nil
        } catch {
            return false
        }
    }

    var isAlphanumeric: Bool {
        return !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }
    
    var isNumber: Bool {
        return !isEmpty && range(of: "[^0-9]", options: .regularExpression) == nil
    }
    
    var isPhoneNumber: Bool {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            let matches = detector.matches(in: self, options: [], range: NSMakeRange(0, self.utf8.count))
            if let res = matches.first {
                return res.resultType == .phoneNumber && res.range.location == 0 && res.range.length == self.utf8.count
            } else {
                return false
            }
        } catch {
            return false
        }
    }
}
