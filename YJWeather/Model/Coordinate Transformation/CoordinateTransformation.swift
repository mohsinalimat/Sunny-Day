//
//  CoordinateTransformation.swift
//  YJWeather
//
//  Created by 최영준 on 2018. 5. 14..
//  Copyright © 2018년 최영준. All rights reserved.
//

import Foundation

/*
 세계측지계 변환에 필요한 투영식
 (타원체면상의 경위도 좌표를 평면직각좌표로 변환,
 평면직각좌표를 타원체면상의 경위도 좌표로 변환)
 출처: 국토지리정보원
 */
let PI = Double.pi
// 장반경a
let SEMI_MINOR_AXIS_A: Double = 6377397.155
// 편평률f
let FLATTENING_F: Double = 0.00334277318217481
// 단반경b
let SEMI_MINOR_AXIS_B: Double = SEMI_MINOR_AXIS_A * (1 - FLATTENING_F)
// 원점축척계수ko
let ORIGIN_SCALE_FACTOR_KO: Double = 1
// 원점가산값X(N), if 제주도 = 550000
let ORIGIN_ADDITION_VALUE_X: Double = 500000
// 원점가산값Y(E)
let ORIGIN_ADDITION_VALUE_Y: Double = 200000
// 원점위도
let ORIGIN_LATITUDE: Double = 38
// 원점경도
let ORIGIN_LONGITUDE: Double = 127
// 제1이심률e^2
let FIRST_ECCENTRICTY: Double = (pow(SEMI_MINOR_AXIS_A, 2) - pow(SEMI_MINOR_AXIS_B, 2)) / pow(SEMI_MINOR_AXIS_A, 2)
// 제2이심률e'^2
let SECOND_ECCENTRICITY: Double = (pow(SEMI_MINOR_AXIS_A, 2) - pow(SEMI_MINOR_AXIS_B, 2)) / pow(SEMI_MINOR_AXIS_B, 2)
// 원점위도 라디안
let ORIGIN_LATITUDE_RADIAN: Double = ORIGIN_LATITUDE / 180 * PI
// 원점경도 라디안
let ORIGIN_LONGITUDE_RADIAN: Double = ORIGIN_LONGITUDE / 180 * PI
// 원점자오선호장MO
let ORIGIN_MERIDIAN_MO: Double = SEMI_MINOR_AXIS_A * ((1 - FIRST_ECCENTRICTY / 4 - 3 * pow(FIRST_ECCENTRICTY, 2) / 64 - 5 * pow(FIRST_ECCENTRICTY, 3) / 256) * ORIGIN_LATITUDE_RADIAN - (3 * FIRST_ECCENTRICTY / 8 + 3 * pow(FIRST_ECCENTRICTY, 2) / 32 + 45 * pow(FIRST_ECCENTRICTY, 3) / 1024) * sin(2 * ORIGIN_LATITUDE_RADIAN) + (15 * pow(FIRST_ECCENTRICTY, 2) / 256 + 45 * pow(FIRST_ECCENTRICTY, 3) / 1024) * sin(4 * ORIGIN_LATITUDE_RADIAN) - (35 * pow(FIRST_ECCENTRICTY, 3) / 2072) * sin(6 * ORIGIN_LATITUDE_RADIAN))
// 원점자오선호장e1
let ORIGIN_MERIDIAN_E1: Double = (1 - sqrt(1 - FIRST_ECCENTRICTY)) / (1 + sqrt(1 - FIRST_ECCENTRICTY))
// 10.405초 보정
let CORRECTION_10_405_SECONDS: Double = 0

/*
 동네예보 지점 좌표(X, Y)위치와 위경도 간의 변환
 출처: 기상청
 */
let DEGRAD: Double = PI / 180.0
let RADDEG: Double = 180.0 / PI

let GRID: Double = 5.0                  // 사용할 지구반경  [ km ]
let RE: Double = 6371.00877 / GRID      // 사용할 지구반경  [ km ]
let SLAT1: Double = 30.0 * DEGRAD       // 표준위도       [degree]
let SLAT2: Double = 60.0 * DEGRAD       // 표준위도       [degree]
let OLON: Double = 126.0 * DEGRAD       // 기준점의 경도   [degree]
let OLAT: Double = 38.0 * DEGRAD        // 기준점의 위도   [degree]
let XO: Double = 42.0                   // 기준점의 X좌표  [격자거리] // 210.0 / grid
let YO: Double = 135.0                  // 기준점의 Y좌표  [격자거리] // 675.0 / grid

let SN: Double = log(cos(SLAT1) / cos(SLAT2)) / log(tan(PI * 0.25 + SLAT2 * 0.5) / tan(PI * 0.25 + SLAT1 * 0.5))
let SF: Double = pow(tan(PI * 0.25 + SLAT1 * 0.5), SN) * cos(SLAT1) / SN
let RO: Double = RE * SF / pow(tan(PI * 0.25 + OLAT * 0.5), SN)

class CoordinateTransformation {
    
    //MARK: 경위도 좌표 -> TM 좌표로 변환
    static func convertLatLonToPlaneRect(latitude: Double, longitude: Double) -> (Double, Double) {
        // Φ, PHI
        let phi: Double = latitude / 180 * PI
        // λ, LAMDA
        let lamda: Double = (longitude - CORRECTION_10_405_SECONDS) / 180 * PI
        // T
        let t: Double = pow(tan(phi), 2)
        // C
        let c: Double = (FIRST_ECCENTRICTY / (1 - FIRST_ECCENTRICTY)) * pow(cos(phi), 2)
        // A
        let a: Double = (lamda - (ORIGIN_LONGITUDE / 180 * PI)) * cos(phi)
        // N
        let n: Double =  SEMI_MINOR_AXIS_A / sqrt(1 - FIRST_ECCENTRICTY * pow(sin(phi), 2))
        // M
        let m: Double = SEMI_MINOR_AXIS_A * ((1 - FIRST_ECCENTRICTY / 4 - 3 * pow(FIRST_ECCENTRICTY, 2) / 64 - 5 * pow(FIRST_ECCENTRICTY, 3) / 256) * phi - (3 * FIRST_ECCENTRICTY / 8 + 3 * pow(FIRST_ECCENTRICTY, 2) / 32 + 45 * pow(FIRST_ECCENTRICTY, 3) / 1024) * sin(2 * phi) + (15 * pow(FIRST_ECCENTRICTY, 2) / 256 + 45 * pow(FIRST_ECCENTRICTY, 3) / 1024) * sin(4 * phi) - 35 * pow(FIRST_ECCENTRICTY, 3) / 3072 * sin(6 * phi))
        // X, TM X(N)
        let x: Double = ORIGIN_ADDITION_VALUE_Y + ORIGIN_SCALE_FACTOR_KO * n * (a + pow(a, 3) / 6 * (1 - t + c) + pow(a, 5) / 120 * (5 - 18 * t + pow(t, 2) + 72 * c - 58 * SECOND_ECCENTRICITY))
        // Y, TM Y(E)
        let y: Double = ORIGIN_ADDITION_VALUE_X + ORIGIN_SCALE_FACTOR_KO * (m - ORIGIN_MERIDIAN_MO + n * tan(phi) * (pow(a, 2) / 2 + pow(a, 4) / 24 * (5 - t + 9 * c + 4 * pow(c, 2)) + pow(a, 6) / 720 * (61 - 58 * t + pow(t, 2) + 600 * c - 330 * SECOND_ECCENTRICITY)))
        return (x, y)
    }
    
    //MARK: TM 좌표 -> 경위도 좌표로 변환
    static func convertPlaneRectToLatLon(tmX: Double, tmY: Double) -> (Double, Double) {
        // M
        let m: Double = ORIGIN_MERIDIAN_MO + ((tmY - ORIGIN_ADDITION_VALUE_X) / ORIGIN_SCALE_FACTOR_KO)
        // μ1, MU1
        let mu1: Double = m / (SEMI_MINOR_AXIS_A * (1 - FIRST_ECCENTRICTY / 4 - 3 * pow(FIRST_ECCENTRICTY, 2) / 64 - 5 * pow(FIRST_ECCENTRICTY, 3) / 256))
        // Φ1, PHI1
        let phi1: Double = mu1 + (3 * ORIGIN_MERIDIAN_E1 / 2 - 27 * pow(ORIGIN_MERIDIAN_E1, 3) / 32) * sin(2 * mu1) + (21 * pow(ORIGIN_MERIDIAN_E1, 2) / 16 - 55 * pow(ORIGIN_MERIDIAN_E1, 4) / 32) * sin(4 * mu1) + (151 * pow(ORIGIN_MERIDIAN_E1, 3) / 96) * sin(6 * mu1) + (1097 * pow(ORIGIN_MERIDIAN_E1, 4) / 512) * sin(8 * mu1)
        // R1 위도 Φ1에서 자오선의 곡률반경
        let r1: Double = (SEMI_MINOR_AXIS_A * (1 - FIRST_ECCENTRICTY)) / (pow((1 - FIRST_ECCENTRICTY * pow(sin(phi1), 2)), (3 / 2)))
        // C1
        let c1: Double = SECOND_ECCENTRICITY * pow(cos(phi1), 2)
        // T1
        let t1: Double = pow(tan(phi1), 2)
        // N1, 위도 Φ1에서 묘유선의 곡률반경
        let n1: Double = SEMI_MINOR_AXIS_A / sqrt(1 - FIRST_ECCENTRICTY * pow(sin(phi1), 2))
        // D
        let d: Double = (tmX - ORIGIN_ADDITION_VALUE_Y) / (n1 * ORIGIN_SCALE_FACTOR_KO)
        // PHI, 위도
        let phi: Double = (phi1 - (n1 * tan(phi1) / r1) * (pow(d, 2) / 2 - pow(d, 4) / 24 * ( 5 + 3 * t1 + 10 * c1 - 4 * pow(c1, 2) - 9 * SECOND_ECCENTRICITY) + pow(d, 6) / 720 * (61 + 90 * t1 + 298 * c1 + 45 * pow(t1, 2) - 252 * SECOND_ECCENTRICITY - 3 * pow(c1, 2)))) * 180 / PI // Φ, PHI
        // LAMDA, 경도
        let lamda: Double = ORIGIN_LONGITUDE + ((1 / cos(phi1)) * (d - (pow(d, 3) / 6) * (1 + 2 * t1 + c1) + (pow(d, 5) / 120) * (5 - 2 * c1 + 28 * t1 - 3 * pow(c1, 2) + 8 * SECOND_ECCENTRICITY + 24 * pow(t1, 2)))) * 180 / PI + CORRECTION_10_405_SECONDS // λ, LAMDA
        
        return (phi, lamda)
    }
    
    //MARK: 경위도 좌표 -> 격자 X, Y 좌표 변환
    static func convertLatLonToGrid(latitude: Double, longitude: Double) -> (Int, Int) {
        let ra: Double = RE * SF / pow(tan(PI * 0.25 + latitude * DEGRAD * 0.5), SN)
        var theta: Double = longitude * DEGRAD - OLON
        if theta > PI {
            theta -= 2.0 * PI
        }
        if theta < -PI {
            theta += 2.0 * PI
        }
        theta *= SN
        
        let x: Double = ra * sin(theta) + XO
        let y: Double = RO - ra * cos(theta) + YO
        
        return (Int(x + 1.5), Int(y + 1.5))
    }
    
    //MARK: 격자 X, Y 좌표 -> 경위도 좌표 변환
    static func convertGridToLatLon(x: Int, y: Int) -> (Double, Double) {
        let x: Double = Double(x) - 1.0
        let y: Double = Double(y) - 1.0
        
        let xn = x - XO
        let yn = RO - y + YO
        var ra = sqrt(xn * xn + yn * yn)
        if SN < 0.0 {
            ra = -ra
        }
        let alat = 2.0 * atan(pow(RE * SF / ra, 1.0 / SN)) - PI * 0.5
        var theta = 0.0
        if fabs(xn) <= 0.0 {
            theta = 0.0
        } else {
            if fabs(yn) <= 0.0 {
                theta = PI * 0.5
                if xn < 0.0 {
                    theta = -theta
                }
            } else {
                theta = atan2(xn, yn)
            }
        }
        let alon = theta / SN + OLON
        let lat = alat * RADDEG
        let lon = alon * RADDEG
        
        return (lat, lon)
    }
}

