//
//  ViewController.swift
//  CareemChallenge
//
//  Created by SSaad Ullah on 10/16/17.
//  Copyright © 2017 SSaad Ullah. All rights reserved.
//

import UIKit
import SearchTextField
import Kingfisher


class ViewController: UIViewController , UITableViewDelegate , UITableViewDataSource{

    @IBOutlet weak var searchField: SearchTextField!
    
    @IBOutlet weak var myTableView: UITableView!
    
    @IBOutlet weak var nextOutlet: UIButton!
    @IBOutlet weak var previousOutlet: UIButton!
    
    
    var searchHistory = [String]()
    
    var movieCount = 0
    var moveieModel : [Results]!
    
    var pagesCount = 0
    var currentSelectedPage = 1
    
    //Activity Indicator
    let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
    var color = UIColor(red: 233 / 255, green: 46 / 255, blue: 100 / 255, alpha: 1.0)
    var colorGreen = UIColor(red: 0 / 255, green: 128 / 255, blue: 0 / 255, alpha: 1.0)

   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = colorGreen
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.sizeToFit()
        
        //Acitivty Indicator
        showActivityIndicatory()
        
        //Configure Field
        configureSimpleSearchTextField()
        
        //Setting Search Field
        textFieldSetup()
        
        //Keyboard Done Action TO perform the Search
        self.searchField.addDoneOnKeyboardWithTarget(self, action: #selector(self.doneAction))
        
        myTableView.separatorStyle = .none
        
        //Tap Gesture
        let field = UITapGestureRecognizer(target: self, action:  #selector(self.showSearchistroy (_:)))
        self.searchField.isUserInteractionEnabled = true
        self.searchField.addGestureRecognizer(field)
        
        //Disable the button
        previousOutlet.isEnabled = false
        
    }
    
    func textFieldSetup(){
        //Left Image
        let image = UIImage(named: "search_icon")
        let outerView = UIView(frame: CGRect(x: 0, y: 0, width: (image?.size.width)!+10, height: (image?.size.height)!) )
        let iconView  = UIImageView(frame: CGRect(x: 5, y: 0, width: (image?.size.width)! , height: (image?.size.width)!))
        iconView.image = image
        iconView.contentMode = .scaleAspectFit
        outerView.addSubview(iconView)
        
        searchField.leftViewMode = UITextFieldViewMode.always
        searchField.leftView = outerView
        
        
        //textfield.placeholder = "Search"
        searchField.attributedPlaceholder = NSAttributedString(string: "Search",
                                                               attributes: [NSForegroundColorAttributeName: UIColor.white])
    }
    
    func showSearchistroy(_ sender:UITapGestureRecognizer){
      
        let countries = self.localCountries(flag: true)
        self.searchField.filterStrings(countries)
    }
    
    func doneAction(){
        if !((searchField.text?.isEmpty)!){
            
            apiCallForSearchQuery()
            
            //Regisn Repsonder For Search Text Field
            self.searchField.resignFirstResponder()
            
        }
    }
    
    @IBAction func DoneTickButton(_ sender: Any) {
    
    }
    
    
    
    //Mark: - Table View Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return movieCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell") as! CustomCell
       
        cell.movieName.text = moveieModel[indexPath.row].title!
        
        if moveieModel[indexPath.row].posterPath != nil{
            cell.posterImage.kf.setImage(with: URL(string: (BASE_URL_IMAGE + moveieModel[indexPath.row].posterPath!)))
        }
        cell.overView.text = moveieModel[indexPath.row].overview!
        cell.releaseDate.text = "Release  Date: \(moveieModel[indexPath.row].releaseDate!)"
        
        let rating = (moveieModel[indexPath.row].voteAverage! / 10) * 5
        cell.rating.rating = Double(rating)
        cell.rating.settings.updateOnTouch = false
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        
    } 
    
    // 1 - Configure a simple search text view
    fileprivate func configureSimpleSearchTextField() {
        // Start visible even without user's interaction as soon as created - Default: false
        searchField.startVisible = true
        
        // Set data source
        let countries = localCountries(flag: false)
        searchField.filterStrings(countries)
    }

    
    fileprivate func localCountries(flag : Bool) -> [String] {
        
        var movieNames = [String]()
        
        if (moveieModel != nil) {
            
            if flag{
                for i in 0...searchHistory.count-1 {
                    movieNames.append(searchHistory[i])
                }
                
                return movieNames
                
            }else{
                for i in 0...moveieModel.count-1 {
                    movieNames.append(moveieModel[i].title!)
                }
                
                return movieNames
            }
        }
        
        return []
        
        
    }
    
    
    func apiCallForSearchQuery(){
        actInd.startAnimating()
        let authReq = AuthHandler()
        authReq.getMovies(queryString: searchField.text!, selectedPage: currentSelectedPage,
                          success: {(_ response: [Results]) -> Void in
                            
                            self.actInd.stopAnimating()
                            print("Reponse SUCCESS")
                           
                            if response.count > 0 {
                                self.movieCount = response.count
                                self.moveieModel = response
                                self.pagesCount = totalPages
                                self.currentSelectedPage = currentPage
                                self.myTableView.reloadData()
                                
                                let countries = self.localCountries(flag: false)
                                self.searchField.filterStrings(countries)
                                
                                //Search History
                                self.searchHistory.append(self.searchField.text!)
                                
                                //Regisn Repsonder For Search Text Field
                                self.searchField.resignFirstResponder()
                            }else if totalPages == 1 && (response.isEmpty){
                                
                                let alert = UIAlertController(title: NSLocalizedString("ERROR", comment: ""), message: "No Result Found!", preferredStyle: UIAlertControllerStyle.alert)
                                
                                alert.addAction(UIAlertAction(title: NSLocalizedString("DONE", comment: ""), style: UIAlertActionStyle.default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                            
                            
        },
                          fail: {(_ error: [String], _ isUnAuthorizedRequestError: Bool) -> Void in
                            
                            self.actInd.stopAnimating()
                            
                            print("CityList ERROR : \(error)")
                            let alert = UIAlertController(title: NSLocalizedString("ERROR", comment: ""), message: error[0], preferredStyle: UIAlertControllerStyle.alert)
                            
                            alert.addAction(UIAlertAction(title: NSLocalizedString("DONE", comment: ""), style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
        })

    }
    
    
    @IBAction func previousAction(_ sender: Any) {
        
        if currentSelectedPage > 1{
            currentSelectedPage -= 1
            apiCallForSearchQuery()
        }
    }
    
    @IBAction func nextAction(_ sender: Any) {
        previousOutlet.isEnabled = true
        
        if currentSelectedPage != totalPages{
            currentSelectedPage += 1
            apiCallForSearchQuery()
        }
    }

    func showActivityIndicatory() {
        
        actInd.frame = CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0);
        actInd.center = self.view.center
        actInd.hidesWhenStopped = true
        actInd.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.whiteLarge
        actInd.color = colorGreen
        view.addSubview(actInd)
    }


}

