//
//  ViewController.swift
//  SearchGitHub
//
//  Created by InKwon on 2018. 9. 18..
//  Copyright © 2018년 Leibniz. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!
  
  let searchController = UISearchController(searchResultsController: nil)
  var searchBar: UISearchBar {
    return searchController.searchBar
  }
  
  var viewModel = ViewModel()
  let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    configureSearchController()
    bind()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  func configureSearchController(){
    searchController.obscuresBackgroundDuringPresentation = false
    searchBar.showsCancelButton = true
    searchBar.text = ""
    searchBar.placeholder = "Enter GitHub ID"
    tableView.tableHeaderView = searchController.searchBar
    definesPresentationContext = true
  }
  
  func bind(){
    // ViewModel -> View
    // viewModel의 data와 tableView 간의 binding
    viewModel
      .data
      .drive(tableView.rx.items(cellIdentifier: "Cell")) {_, repository, cell in
        cell.textLabel?.text = repository.repoName
        cell.detailTextLabel?.text = repository.repoURL
      }
      .disposed(by: disposeBag)
    
    // View -> ViewModel
    // searchBar의 의 text와 viewModel의 seachText 간의 binding
    searchBar
      .rx
      .text
      .orEmpty
      .bind(to: viewModel.searchText)
      .disposed(by: disposeBag)
    
    // ViewModel -> View
    // viewModel의 data와 navigationItem 간의 binding
    viewModel
      .data
      .asDriver()
      .map{"\($0.count) Repositories"}
      .drive(navigationItem.rx.title)
      .disposed(by: disposeBag)
  }
}

