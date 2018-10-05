//
//  SearchViewController.swift
//  YJWeather
//
//  Created by 최영준 on 2018. 5. 14..
//  Copyright © 2018년 최영준. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    // MARK: - Properties
    // MARK: -
    let locationDAO = LocationDAO()
    let umds = (UIApplication.shared.delegate as! AppDelegate).umds
    var filteredUmdData = [UmdData]()
    @IBOutlet var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
            searchBar.placeholder = "읍면동을 입력하세요."
        }
    }
    @IBOutlet var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    @IBOutlet var backButton: UIButton!
    @IBOutlet var searchResultLabel: UILabel!
    @IBOutlet var coverView: UIView!
    
    // MARK: - View lifecycle
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.addTarget(self, action: #selector(goBack(_:)), for: .touchUpInside)
        view.bringSubview(toFront: coverView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 뷰 로드시 키보드, 검색 바로 시작
        searchBar.becomeFirstResponder()
    }
    
    // MARK: - Custom methods
    // MARK: -
    /// searchBar.text 존재 유무
    private func isFiltering() -> Bool {
        return (searchBar.text?.isEmpty)! ? false : true
    }
    /// searchText가 포함된 umdData를
    private func filterContentForSearchText(_ searchText: String) {
        // searchBar.text가 존재할 경우 umds에서 searchText가 포함된 배열을 반환한다
        filteredUmdData = umds.filter { (umdData) -> Bool in
            return isFiltering() ? umdData.name.contains(searchText) : true
        }
        // 위 결과에 따라 searchResultLabel.text 를 변경 후 tableView를 리로드한다
        searchResultLabel.text = (filteredUmdData.count == 0) ? "검색 결과가 없습니다." : "\(filteredUmdData.count)개의 결과가 있습니다."
        tableView.reloadData()
    }
    /// MainViewController로 되돌아간다
    @objc private func goBack(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - UITableViewDelegate, UITableViewDataSoruce
    // MARK: -
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFiltering() ? filteredUmdData.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.font = UIFont(name: "NanumSquareRoundOTFB", size: 16)
        // searchBar.text가 존재한다면 검색된 umdData.name을 cell에 전달
        if isFiltering() {
            let umdData = filteredUmdData[indexPath.row]
            cell.textLabel?.text = umdData.name
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isFiltering() {
            // 검색된 umdData로 LocationData를 생성한다
            let umdData = filteredUmdData[indexPath.row]
            let (latitude, longitude) = Coordinates().convertToLatitudeLongitude(tmX: umdData.tmX, tmY: umdData.tmY)
            var locationData = LocationData()
            // 위치명은 지역이름 뒤에서 두 개만 가져온다(ex: 서울특별시 서초구 서초동 -> 서초구 서초동)
            var locationNames = umdData.name.split(separator: " ")
            var location = ""
            for i in 0 ..< 2 {
                var locationName = String(locationNames.removeLast())
                if i == 0 {
                    locationName = " " + locationName
                }
                location = locationName + location
            }
            locationData.location = location
            locationData.latitude = latitude
            locationData.longitude = longitude
            locationData.regdate = Date()
            // 생성한 locationData를 영구 저장소에 삽입한다
            locationDAO.insert(locationData)
            // MainViewController에 데이터가 추가되었음을 알리고 dismiss
            MainViewController.dataAddCompletion = true
            dismiss(animated: false)
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    // MARK: - UISearchBarDelegate
    // MARK: -
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            coverView.isHidden = false
            return
        }
        coverView.isHidden = true
        filterContentForSearchText(searchText)
    }
}
