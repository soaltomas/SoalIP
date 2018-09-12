import Foundation

class IPManager {
    static let manager = IPManager()
    
    //Целочисленный адрес без точек в строку в 2 или 10 СИ
    func uintAddressToString(_ address: UInt32, radix: UInt8) -> String {
        
        var octets: [UInt8] = Array()
        var _address = address
        
        for _ in 0 ..< MemoryLayout<UInt32>.size {
            octets.insert(UInt8(_address & 0xFF), at: 0)
            _address >>= 8
        }
        var addressString = ""
        switch radix {
        case 2:
            for octet in octets {
                var octetString = String(octet, radix: 2)
                if octetString.count < 8 {
                    octetString = String(repeating: "0", count: 8 - octetString.count) + "\(octetString)"
                }
                addressString += "\(octetString)."
            }
        case 10:
            for octet in octets {
                addressString += "\(octet)."
            }
        default:
            return ""
        }
        return String(addressString.dropLast())
    }
    
    //Строка в массив целых чисел
    func stringAddressToArray(_ address: String) -> [UInt8] {
        
        var octets: [UInt8] = Array()
        
        let stringsOctet = address.components(separatedBy: ".")
        
        for stringOctet in stringsOctet {
            guard
                let octet = UInt8(stringOctet)
                else {
                    return []
            }
            octets.append(octet)
        }
        
        return octets
    }
    
    //Строка в целочисленный адрес без точек
    func stringAddressToUInt(_ address: String) -> UInt32 {
        
        var uintAddress: UInt32 = 0
        
        let octets = stringAddressToArray(address)
        
        if octets.count != 4 {
            return 0
        }
        for i in 0..<MemoryLayout<UInt32>.size - 1 {
            uintAddress |= UInt32(octets[i])
            uintAddress <<= 8
        }
        uintAddress |= UInt32(octets[octets.count - 1])
        
        return uintAddress
    }
    
    func prefixToMask(_ prefix: UInt8) -> String {
        var mask: UInt32 = UINT32_MAX
        
        mask >>= 32 - prefix
        mask <<= 32 - prefix
        
        return uintAddressToString(mask, radix: 10)
    }
    
    func validationIP(ip: String) -> Bool {
        let stringOctets = ip.components(separatedBy: ".")
        let numberOctets = stringOctets.compactMap { Int($0) }
        return stringOctets.count == 4 && numberOctets.count == 4 && numberOctets.filter { $0 >= 0 && $0 < 256 }.count == 4
    }
    
    func validationMask(mask: String) -> Bool {
        let octetVariations = [128, 192, 224, 240, 248, 252, 254]
        let stringOctets = mask.components(separatedBy: ".")
        
        let numberOctets = stringOctets.compactMap { Int($0) }
        if numberOctets.count != 4 {
            return false
        }
        
        var count = 0
        for octet in numberOctets {
            if octetVariations.contains(octet) {
                count += 1
            } else if octet != 0 && octet != 255 {
                return false
            }
        }
        
        let etalonOctets = numberOctets.sorted { $0 > $1 }
        
        if numberOctets != etalonOctets || count > 1 {
            return false
        }
        return true
    }
}
