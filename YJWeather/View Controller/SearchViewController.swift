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
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var searchResultLabel: UILabel!
    let dao = LocationDAO()
    
    var umds = (UIApplication.shared.delegate as! AppDelegate).umds
    var filteredUmdData = [UmdData]()   // 검색
    
    @IBOutlet weak var coverView: UIView!
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        searchBar.placeholder = "읍면동을 입력하세요."
        tableView.delegate = self
        tableView.dataSource = self
        backButton.addTarget(self, action: #selector(goBack(_:)), for: .touchUpInside)
        
        view.bringSubview(toFront: coverView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 뷰 로드시 키보드, 검색 바로 시작
        searchBar.becomeFirstResponder()
    }
    
    // MARK: - Custom Methods
    func isFiltering() -> Bool {
        return (searchBar.text?.isEmpty)! ? false : true
    }
    
    func filterContentForSearchText(_ searchText: String) {
        filteredUmdData = umds.filter({ (umdData) -> Bool in
            if isFiltering() {
                return umdData.name.contains(searchText)
            } else {
                return true
            }
        })
        if filteredUmdData.count == 0 {
            searchResultLabel.text = "검색 결과가 없습니다."
        } else {
            searchResultLabel.text = "\(filteredUmdData.count)개의 결과가 있습니다."
        }
        tableView.reloadData()
    }
    
    @objc func goBack(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - UITableView Delegate, DataSoruce
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isFiltering() {
            return filteredUmdData.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.font = UIFont(name: "NanumSquareRoundOTFB", size: 16)
        if isFiltering() {
            let umdData = filteredUmdData[indexPath.row]
            cell.textLabel?.text = umdData.name
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if isFiltering() {
            let umdData = filteredUmdData[indexPath.row]
            
            let (latitude, longitude) = CoordinateTransformation.convertPlaneRectToLatLon(tmX: umdData.tmX, tmY: umdData.tmY)
            
            let locationData = LocationData()
            locationData.location = umdData.name
            locationData.latitude = latitude
            locationData.longitude = longitude
            locationData.regdate = Date()
            
            dao.insert(locationData)
            MainViewController.dataAddCompletion = true
            dismiss(animated: false)
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            coverView.isHidden = false
        } else {
            coverView.isHidden = true
            filterContentForSearchText(searchText)
        }
    }
}
