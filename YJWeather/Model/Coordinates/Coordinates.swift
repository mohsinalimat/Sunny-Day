//
//  Coordinates.swift
//  YJWeather
//
//  Created by 최영준 on 2018. 9. 28..
//  Copyright © 2018년 최영준. All rights reserved.
//

import Foundation

class Coordinates {
    // MARK: - Properties
    // MARK: -
    // 세계측지계 변환에 필요한 투영식
    // (타원체면상의 경위도 좌표를 평면직각좌표로 변환,
    // 평면직각좌표를 타원체면상의 경위도 좌표로 변환)
    // 출처: 국토지리정보원
    private let pi = Double.pi
    private let semiMinorAxisA = 6377397.155          // 장반경a
    private let flatteningF = 0.00334277318217481     // 편평률f
    private let semiMinorAxisB: Double                // 단반경b
    private let originScaleFactorKo = 1.0             // 원점축척계수ko
    private let originAdditionValueX = 500000.0       // 원점가산값X(N), if 제주도 = 550000
    private let originAdditionValueY = 200000.0       // 원점가산값Y(E)
    private let originLatitude = 38.0                 // 원점위도
    private let originLongitude = 127.0               // 원점경도
    private let firstEccentricty: Double              // 제1이심률e^2
    private let secondEccentricty: Double             // 제2이심률e'^2
    private let originLatitudeRadian: Double          // 원점위도 라디안
    private let originLongitudeRadian: Double         // 원점경도 라디안
    private let originMeridianMo: Double              // 원점자오선호장MO
    private let originMeridianE1: Double              // 원점자오선호장e1
    private let correction10405Seconds = 0.0          // 10.405초 보정
    // 동네예보 지점 좌표(X, Y)위치와 위경도 간의 변환
    // 출처: 기상청
    private let degrad = Double.pi / 180.0
    private let raddeg = 180.0 / Double.pi
    private let grid = 5.0          // 사용할 지구반경  [ km ]
    private let re: Double          // 사용할 지구반경  [ km ]
    private let slat1: Double       // 표준위도       [degree]
    private let slat2: Double       // 표준위도       [degree]
    private let olon: Double        // 기준점의 경도   [degree]
    private let olat: Double        // 기준점의 위도   [degree]
    private let xo = 42.0           // 기준점의 X좌표  [격자거리] // 210.0 / grid
    private let yo = 135.0          // 기준점의 Y좌표  [격자거리] // 675.0 / grid
    private let sn: Double
    private let sf: Double
    private let ro: Double
    
    // MARK: - Initializer
    // MARK: -
    init() {
        semiMinorAxisB = semiMinorAxisA * (1 - flatteningF)
        firstEccentricty = (pow(semiMinorAxisA, 2) - pow(semiMinorAxisB, 2)) / pow(semiMinorAxisA, 2)
        secondEccentricty = (pow(semiMinorAxisA, 2) - pow(semiMinorAxisB, 2)) / pow(semiMinorAxisB, 2)
        originLatitudeRadian = originLatitude / 180 * pi
        originLongitudeRadian = originLongitude / 180 * pi
        originMeridianMo = semiMinorAxisA * ((1 - firstEccentricty / 4 - 3 * pow(firstEccentricty, 2) / 64 - 5 * pow(firstEccentricty, 3) / 256) * originLatitudeRadian - (3 * firstEccentricty / 8 + 3 * pow(firstEccentricty, 2) / 32 + 45 * pow(firstEccentricty, 3) / 1024) * sin(2 * originLatitudeRadian) + (15 * pow(firstEccentricty, 2) / 256 + 45 * pow(firstEccentricty, 3) / 1024) * sin(4 * originLatitudeRadian) - (35 * pow(firstEccentricty, 3) / 2072) * sin(6 * originLatitudeRadian))
        originMeridianE1 = (1 - sqrt(1 - firstEccentricty)) / (1 + sqrt(1 - firstEccentricty))
        re = 6371.00877 / grid
        slat1 = 30.0 * degrad
        slat2 = 60.0 * degrad
        olon = 126.0 * degrad
        olat = 38.0 * degrad
        sn = log(cos(slat1) / cos(slat2)) / log(tan(pi * 0.25 + slat2 * 0.5) / tan(pi * 0.25 + slat1 * 0.5))
        sf = pow(tan(pi * 0.25 + slat1 * 0.5), sn) * cos(slat1) / sn
        ro = re * sf / pow(tan(pi * 0.25 + olat * 0.5), sn)
    }
    
    // MARK: - Custom methods
    // MARK: -
    /// 경위도 좌표 -> TM 좌표로 변환
    func convertToPlaneRect(latitude: Double, longitude: Double) -> (Double, Double) {
        // Φ, PHI
        let phi = latitude / 180 * pi
        // λ, LAMDA
        let lamda = (longitude - correction10405Seconds) / 180 * pi
        // T
        let t = pow(tan(phi), 2)
        // C
        let c = (firstEccentricty / (1 - firstEccentricty)) * pow(cos(phi), 2)
        // A
        let a = (lamda - (originLongitude / 180 * pi)) * cos(phi)
        // N
        let n = semiMinorAxisA / sqrt(1 - firstEccentricty * pow(sin(phi), 2))
        // M
        let m = semiMinorAxisA * ((1 - firstEccentricty / 4 - 3 * pow(firstEccentricty, 2) / 64 - 5 * pow(firstEccentricty, 3) / 256) * phi - (3 * firstEccentricty / 8 + 3 * pow(firstEccentricty, 2) / 32 + 45 * pow(firstEccentricty, 3) / 1024) * sin(2 * phi) + (15 * pow(firstEccentricty, 2) / 256 + 45 * pow(firstEccentricty, 3) / 1024) * sin(4 * phi) - 35 * pow(firstEccentricty, 3) / 3072 * sin(6 * phi))
        // X, TM X(N)
        let x = originAdditionValueY + originScaleFactorKo * n * (a + pow(a, 3) / 6 * (1 - t + c) + pow(a, 5) / 120 * (5 - 18 * t + pow(t, 2) + 72 * c - 58 * secondEccentricty))
        // Y, TM Y(E)
        let y = originAdditionValueX + originScaleFactorKo * (m - originMeridianMo + n * tan(phi) * (pow(a, 2) / 2 + pow(a, 4) / 24 * (5 - t + 9 * c + 4 * pow(c, 2)) + pow(a, 6) / 720 * (61 - 58 * t + pow(t, 2) + 600 * c - 330 * secondEccentricty)))
        return (x, y)
    }
    /// TM 좌표 -> 경위도 좌표로 변환
    func convertToLatitudeLongitude(tmX: Double, tmY: Double) -> (Double, Double) {
        // M
        let m = originMeridianMo + ((tmY - originAdditionValueX) / originScaleFactorKo)
        // μ1, MU1
        let mu1 = m / (semiMinorAxisA * (1 - firstEccentricty / 4 - 3 * pow(firstEccentricty, 2) / 64 - 5 * pow(firstEccentricty, 3) / 256))
        // Φ1, PHI1
        let phi1 = mu1 + (3 * originMeridianE1 / 2 - 27 * pow(originMeridianE1, 3) / 32) * sin(2 * mu1) + (21 * pow(originMeridianE1, 2) / 16 - 55 * pow(originMeridianE1, 4) / 32) * sin(4 * mu1) + (151 * pow(originMeridianE1, 3) / 96) * sin(6 * mu1) + (1097 * pow(originMeridianE1, 4) / 512) * sin(8 * mu1)
        // R1 위도 Φ1에서 자오선의 곡률반경
        let r1 = (semiMinorAxisA * (1 - firstEccentricty)) / (pow((1 - firstEccentricty * pow(sin(phi1), 2)), (3 / 2)))
        // C1
        let c1 = secondEccentricty * pow(cos(phi1), 2)
        // T1
        let t1 = pow(tan(phi1), 2)
        // N1, 위도 Φ1에서 묘유선의 곡률반경
        let n1 = semiMinorAxisA / sqrt(1 - firstEccentricty * pow(sin(phi1), 2))
        // D
        let d = (tmX - originAdditionValueY) / (n1 * originScaleFactorKo)
        // PHI, 위도
        let phi = (phi1 - (n1 * tan(phi1) / r1) * (pow(d, 2) / 2 - pow(d, 4) / 24 * ( 5 + 3 * t1 + 10 * c1 - 4 * pow(c1, 2) - 9 * secondEccentricty) + pow(d, 6) / 720 * (61 + 90 * t1 + 298 * c1 + 45 * pow(t1, 2) - 252 * secondEccentricty - 3 * pow(c1, 2)))) * 180 / pi // Φ, PHI
        // LAMDA, 경도
        let lamda = originLongitude + ((1 / cos(phi1)) * (d - (pow(d, 3) / 6) * (1 + 2 * t1 + c1) + (pow(d, 5) / 120) * (5 - 2 * c1 + 28 * t1 - 3 * pow(c1, 2) + 8 * secondEccentricty + 24 * pow(t1, 2)))) * 180 / pi + correction10405Seconds
        // λ, LAMDA
        return (phi, lamda)
    }
    /// 경위도 좌표 -> 격자 nx, ny 좌표 변환
    func convertToGrid(latitude: Double, longitude: Double) -> (Int, Int) {
        let ra = re * sf / pow(tan(pi * 0.25 + latitude * degrad * 0.5), sn)
        var theta = longitude * degrad - olon
        if theta > pi {
            theta -= 2.0 * pi
        }
        if theta < -pi {
            theta += 2.0 * pi
        }
        theta *= sn
        let x = ra * sin(theta) + xo
        let y = ro - ra * cos(theta) + yo
        return (Int(x + 1.5), Int(y + 1.5))
    }
    /// 격자 nx, ny 좌표 -> 경위도 좌표 변환
    func convertToLatitudeLongitude(nx: Int, ny: Int) -> (Double, Double) {
        let x = Double(nx) - 1.0
        let y = Double(ny) - 1.0
        let xn = x - xo
        let yn = ro - y + yo
        var ra = sqrt(xn * xn + yn * yn)
        if sn < 0.0 {
            ra = -ra
        }
        let alat = 2.0 * atan(pow(re * sf / ra, 1.0 / sn)) - pi * 0.5
        var theta = 0.0
        if fabs(xn) <= 0.0 {
            theta = 0.0
        } else {
            if fabs(yn) <= 0.0 {
                theta = pi * 0.5
                if xn < 0.0 {
                    theta = -theta
                }
            } else {
                theta = atan2(xn, yn)
            }
        }
        let alon = theta / sn + olon
        let lat = alat * raddeg
        let lon = alon * raddeg
        return (lat, lon)
    }
}
