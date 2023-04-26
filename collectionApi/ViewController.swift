//
//  ViewController.swift
//  collectionApi
//
//  Created by Mohan K on 21/01/23.
//

import UIKit

struct Hero: Decodable {
    let localized_name: String
    let img: String
    
}
class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionJSON: UICollectionView!
    
    
    var heroes = [Hero]()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        collectionJSON.delegate = self
        collectionJSON.dataSource = self
        
        
        let url = URL(string:  "https://api.opendota.com/api/heroStats")
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error == nil {
                do {
                    self.heroes = try JSONDecoder().decode([Hero].self, from: data!)
                }catch {
                    print("Parse Error")
                }
                
                DispatchQueue.main.async {
                    self.collectionJSON.reloadData()
                    print(self.heroes.count)
                }
            }
                
        }.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return heroes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionJSON.dequeueReusableCell(withReuseIdentifier: "customCell", for: indexPath) as! customCollectionViewCell
        
        cell.nameLbl.text = heroes[indexPath.row].localized_name.capitalized
     
    
        let defaultLink = "https://api.opendota.com"
        let completeLink = defaultLink + heroes[indexPath.row].img
        cell.customImg.downloadedFrom(link: completeLink)
        cell.customImg.clipsToBounds = true
        cell.customImg.layer.cornerRadius = cell.customImg.frame.width / 2
        cell.customImg.contentMode = .scaleAspectFill
        return cell
    }
    
   

}

extension UIViewController {
    
    func showToast(message : String, font:UIFont) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height - 100, width: 150, height: 30))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseIn, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}

extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
            else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }

}
