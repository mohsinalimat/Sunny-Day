//
//  LocationData.swift
//  YJWeather
//
//  Created by 최영준 on 2018. 5. 14..
//  Copyright © 2018년 최영준. All rights reserved.
//

import UIKit
import CoreData

class LocationData {
    var location: String?   // 위치명
    var latitude: Double?   // 위도
    var longitude: Double?  // 경도
    var regdate: Date?    // 생성날짜
    var objectID: NSManagedObjectID?    // 원본 LocationMO 객체를 참조하기 위한 속성
}
/// LocationData와 LocationMO 사이에 접근을 처리하는 클래스
class LocationDAO {
    // 영구 저장소에 접근하는 context 지연 변수
    private lazy var context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()
    /// 저장된 데이터를 불러오는 메서드
    func fetch() -> [LocationData] {
        var locations = [LocationData]()
        // 요청 객체 생성
        let fetchRequest: NSFetchRequest<LocationMO> = LocationMO.fetchRequest()
        // 등록순으로 정렬하도록 정렬 객체 생성
        let regdateAsc = NSSortDescriptor(key: "regdate", ascending: true)
        fetchRequest.sortDescriptors = [regdateAsc]
        do {
            let result = try context.fetch(fetchRequest)
            // 읽어온 결과 배열 순회하면서 LocationData 타입으로 변환한다.
            for object in result {
                // LocationData 객체를 생성
                let data = LocationData()
                // LocationMO 프로퍼티 값을 LocationData의 프로퍼티로 복사한다.
                data.location = object.location
                data.latitude = object.latitude
                data.longitude = object.longitude
                data.regdate = object.regdate
                data.objectID = object.objectID
                // LocationData 객체를 locations 배열에 추가한다.
                locations.append(data)
            }
        } catch {
            print(error.localizedDescription)
        }
        return locations
    }
    /// 새로운 위치 데이터를 추가하는 메서드
    func insert(_ data: LocationData) {
        // 관리 객체 인스턴스 생성
        guard let object = NSEntityDescription.insertNewObject(forEntityName: "Location", into: context) as? LocationMO else {
            return
        }
        // LocationData로부터 값을 복사한다.
        object.location = data.location
        if let latitude = data.latitude, let longitude = data.longitude {
            object.latitude = latitude
            object.longitude = longitude
        }
        object.regdate = data.regdate
        // 영구 저장소에 변경사항을 반영한다.
        do {
            try context.save()
        } catch {
            context.rollback()
            print(error.localizedDescription)
        }
    }
    /// 저장된 위치 데이터를 삭제하는 메서드
    @discardableResult func delete(_ data: LocationData) -> Bool {
        // 삭제할 객체를 찾아 컨텍스트에서 제거한다.
        if let objectID = data.objectID {
            let object = context.object(with: objectID)
            context.delete(object)
        }
        // 영구 저장소에 변경사항을 반영한다.
        do {
            try context.save()
            return true
        } catch {
            context.rollback()
            print(error.localizedDescription)
            return false
        }
    }
    /// 수정된 데이터를 반영하는 메서드
    func update(_ data: LocationData) {
        // objectID 값으로 수정할 관리 객체를 컨텍스트에서 찾는다.
        guard let object = context.object(with: data.objectID!) as? LocationMO else {
            return
        }
        // 수정된 값을 복사한다.
        object.location = data.location
        if let latitude = data.latitude, let longitude = data.longitude {
            object.latitude = latitude
            object.longitude = longitude
        }
        // 영구 저장소에 변경사항을 반영한다.
        do {
            try context.save()
        } catch {
            context.rollback()
            print(error.localizedDescription)
        }
    }
}

