//
//  MovieDetailsViewController.swift
//  movie-core-data
//
//  Created by Thet Htun on 9/18/19.
//  Copyright © 2019 padc. All rights reserved.
//

import UIKit
import CoreData

class MovieDetailsViewController: UIViewController {

    let scrollViewPrimary : UIScrollView = {
        let ui = UIScrollView()
        ui.translatesAutoresizingMaskIntoConstraints = false
        return ui
    }()
    
    let stackViewTemp : UIStackView = {
        let ui = UIStackView()
        ui.translatesAutoresizingMaskIntoConstraints = false
        ui.axis = .vertical
        ui.spacing = 5
        return ui
    }()
    
    let activityIndicator : UIActivityIndicatorView = {
        let ui = UIActivityIndicatorView()
        ui.translatesAutoresizingMaskIntoConstraints = false
        ui.color = UIColor.red
        ui.startAnimating()
        return ui
    }()
    
    var movieId : Int = 0
    
    let bookMarkButton = UIButton()
    var isBookMarkSelected: Bool =  false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initBookMarkIcon()
        initView()
        if NetworkUtils.checkReachable() == false {
            Dialog.showAlert(viewController: self, title: "Error", message: "No Internet Connection!")
            if let data = MovieVO.getMovieById(movieId: movieId) {
                self.bindData(data: data)
            }
            return
        }
        
        MovieModel.shared.fetchMovieDetails(movieId: movieId) { movieDetails in
            
            let fetchRequest : NSFetchRequest<MovieVO> = MovieVO.fetchRequest()
            let predicate = NSPredicate(format: "id == %d", self.movieId)
            fetchRequest.predicate = predicate
            if let movies = try? CoreDataStack.shared.viewContext.fetch(fetchRequest), !movies.isEmpty {
                MovieInfoResponse.updateMovieEntity(existingData: movies[0], newData: movieDetails, context: CoreDataStack.shared.viewContext)
                DispatchQueue.main.async { [weak self] in
                    self?.bindData(data: movies[0])
                }
            } else {
                let movieVO = MovieInfoResponse.convertToMovieVO(data: movieDetails, context: CoreDataStack.shared.viewContext)
                
                DispatchQueue.main.async { [weak self] in
                    self?.bindData(data: movieVO)
                }
            }
            
        }
        
    }
    
    fileprivate func initView() {
        self.view.addSubview(scrollViewPrimary)
        scrollViewPrimary.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        scrollViewPrimary.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        scrollViewPrimary.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        scrollViewPrimary.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        
        scrollViewPrimary.backgroundColor = Theme.background
        
        scrollViewPrimary.addSubview(stackViewTemp)
        stackViewTemp.leadingAnchor.constraint(equalTo: self.scrollViewPrimary.leadingAnchor, constant: 20).isActive = true
        stackViewTemp.trailingAnchor.constraint(equalTo: self.scrollViewPrimary.trailingAnchor, constant: -20).isActive = true
        stackViewTemp.topAnchor.constraint(equalTo: self.scrollViewPrimary.topAnchor, constant: 20).isActive = true
        stackViewTemp.bottomAnchor.constraint(equalTo: self.scrollViewPrimary.bottomAnchor, constant: 20).isActive = true
        stackViewTemp.centerXAnchor.constraint(equalTo: self.scrollViewPrimary.centerXAnchor).isActive = true
        
        scrollViewPrimary.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: scrollViewPrimary.centerXAnchor, constant: 0).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: scrollViewPrimary.centerYAnchor, constant: -100).isActive = true
        activityIndicator.startAnimating()
        
        bookMarkButton.setImage(#imageLiteral(resourceName: "bookmark_nonselect") ,for: .normal)
        bookMarkButton.setImage(#imageLiteral(resourceName: "bookmark_select") ,for: .selected)
        bookMarkButton.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        bookMarkButton.addTarget(self, action: #selector(selectBookMarksButtonAction), for: .touchUpInside)
        let barButtonItem = UIBarButtonItem.init(customView: bookMarkButton)
        self.navigationItem.rightBarButtonItem = barButtonItem
    }
    
    @objc func selectBookMarksButtonAction(){
        if isBookMarkSelected {
            bookMarkButton.isSelected = false
            isBookMarkSelected = false
            BookMarkVO.deleteBookMarkEntity(movieId: movieId,context: CoreDataStack.shared.viewContext)
        }else{
            bookMarkButton.isSelected = true
            isBookMarkSelected = true
            BookMarkVO.saveBookMarkEntity(movieId: movieId, context: CoreDataStack.shared.viewContext)
        }
    }
    
    fileprivate func initBookMarkIcon(){
        isBookMarkSelected = BookMarkVO.isBookMarkMovie(movieId: movieId)
        bookMarkButton.isSelected = isBookMarkSelected
    }
    
    
    fileprivate func bindData(data : MovieVO) {
        activityIndicator.stopAnimating()
        
        let overviewTitle = WidgetGenerator.getUILabelTitle("Overview")
        stackViewTemp.addArrangedSubview(overviewTitle)
        let movieOverview = data.overview ?? "No overview"
        stackViewTemp.addArrangedSubview(WidgetGenerator.getUILabelMovieInfo(movieOverview))
        
        stackViewTemp.addArrangedSubview(WidgetGenerator.getUILabelMovieInfo(" ")) //Add some spacing
        
        let releaseTitle = WidgetGenerator.getUILabelTitle("Release Date")
        stackViewTemp.addArrangedSubview(releaseTitle)
        let releasedDate = data.release_date ?? "No release date"
        stackViewTemp.addArrangedSubview(WidgetGenerator.getUILabelMovieInfo(releasedDate))
        
        stackViewTemp.addArrangedSubview(WidgetGenerator.getUILabelMovieInfo(" ")) //Add some spacing
        
        let genreTitle = WidgetGenerator.getUILabelTitle("Genres")
        stackViewTemp.addArrangedSubview(genreTitle)
        if let genres = data.genres, genres.count > 0 {
            genres.allObjects.forEach{ data in
                if let genre = data as? MovieGenreVO {
                    stackViewTemp.addArrangedSubview(WidgetGenerator.getUILabelMovieInfo(genre.name ?? "undefined"))
                }
            }
        }
        
        
        stackViewTemp.addArrangedSubview(WidgetGenerator.getUILabelMovieInfo(" ")) //Add some spacing
        
        let ratinTitle = WidgetGenerator.getUILabelTitle("Rating")
        stackViewTemp.addArrangedSubview(ratinTitle)
        stackViewTemp.addArrangedSubview(WidgetGenerator.getUILabelMovieInfo("\(data.vote_average)"))
        
        
        
    }
    
}
