//
//  ViewModel.swift
//  SearchGitHub
//
//  Created by InKwon on 2018. 9. 18..
//  Copyright © 2018년 Leibniz. All rights reserved.
//

import RxSwift
import RxCocoa

class ViewModel {
  // View -> ViewModel
  let searchText = Variable("")
  
  // ViewModel -> View
  lazy var data: Driver<[Repository]> = {
    return self.searchText
    .asObservable()
    .throttle(0.3, scheduler: MainScheduler.instance) // Observable이기 때문에 MainScheduler 지정
    .distinctUntilChanged()
    .flatMapLatest(ViewModel.repositoriesBy)
    .asDriver(onErrorJustReturn: []) // driver로 변환
  }()
  
  // ViewModel -> Model
  static func repositoriesBy(_ githubID: String) -> Observable<[Repository]> {
    guard !githubID.isEmpty,
    let url = URL(string: "https://api.github.com/users/\(githubID)/repos") else {
      return Observable.just([])
    }
    
    return URLSession.shared.rx.json(url: url)
    .retry(3)
    .catchErrorJustReturn([])
    .map(parse)
  }
  
  // Model -> ViewModel
  static func parse(json:Any) -> [Repository] {
    guard let items = json as? [[String:Any]] else {
      return []
    }
    
    var repositories = [Repository]()
    
    items.forEach {
      guard let repoName = $0["name"] as? String,
        let repoURL = $0["html_url"] as? String else {
          return
      }
      repositories.append(Repository(repoName: repoName, repoURL: repoURL))
    }
    
    return repositories
  }
}
