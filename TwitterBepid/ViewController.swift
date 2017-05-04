//
//  ViewController.swift
//  TwitterBepid
//
//  Created by IFCE on 02/05/17.
//  Copyright © 2017 BEPID. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // Index path.row esta pegando o id errado do array errado
    @IBOutlet weak var tableView: UITableView!
    var tableData: Array<String> = Array<String>()
    var tableJson: [Any] = [Any]()
    
    func getText() {
        var text: String? = ""
        
        let requestURL = URL(string:"https://ios-twitter.herokuapp.com/api/message")!
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request, completionHandler: {(data, response, error) in
            guard let data = data, error == nil else { return }
            
            let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [Any?]
            self.tableJson = json
            print(self.tableJson)
            for item in json {
                let dic = item as? [String: Any]
                text = dic?["text"] as? String
                if text?.isEmpty == false {
                    self.tableData.append(text!)
                }
            }
            
            self.tableView.reloadData()
        }).resume()
        
    }
    func postText(texto:String) {
        let postString = ["text":texto]
        var request = URLRequest(url:URL(string:"https://ios-twitter.herokuapp.com/api/message")!)
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application-idValue", forHTTPHeaderField: "secret-key")
        request.httpBody = try! JSONSerialization.data(withJSONObject: postString, options:.prettyPrinted)
        let session = URLSession.shared
        //Post
        session.dataTask(with: request){data, response, err in
            //Guard: ws there error ?
            guard(err == nil) else {
                print("\(err)")
                return
            }
            //Guard: check was any data returned?
            guard let data = data else{
                print("no data return")
                return
            }
            //Convert Json to Object
            let parseResult: [String:AnyObject]!
            do{
                parseResult = try JSONSerialization.jsonObject(with: data, options:.allowFragments) as! [String:AnyObject]
                print("\(parseResult)")
            } catch {
                print("Could not parse data as Json \(data)")
                return
            }
            self.tableView.reloadData()
            }.resume()
    }
    func deleteText(id: Int) {
        let idPost = ["id":id]
        do {
            let json = try! JSONSerialization.data(withJSONObject: idPost, options: [])
            let jsonDec = try! JSONSerialization.jsonObject(with: json, options: [])
            var request = URLRequest(url:URL(string:"https://ios-twitter.herokuapp.com/api/message/\(id)")!)
            request.httpMethod = "DELETE"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let task = URLSession.shared.dataTask(with: request) {data, response, error in
                guard let data = data, error == nil else{
                    print("error=\(error)")
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("response = \(response)")
                }
                print(data as NSData) //<-`as NSData` is useful for debugging
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    print(json)
                    //Why don't you use decoded JSON object? (`json` may not be a `String`)
                } catch {
                    print("error serializing JSON: \(error)")
                }
                //Not sure what you mean with "i need to return the json as String"
                let responseString = String(data: data, encoding: .utf8) ?? ""
                print(responseString)
            }
            task.resume()
        }
        
    }
    func editText(id: Int, texto: String) {
        let editString = ["text":texto]
        do {
            let json = try! JSONSerialization.data(withJSONObject: editString, options: [])
            let jsonDec = try! JSONSerialization.jsonObject(with: json, options: [])
            var request = URLRequest(url:URL(string:"https://ios-twitter.herokuapp.com/api/message/\(id)")!)
            request.httpMethod = "PUT"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = json
            
            let session = URLSession.shared
            //Post
            session.dataTask(with: request){data, response, err in
                //Guard: ws there error ?
                guard(err == nil) else {
                    print("\(err)")
                    return
                }
                //Guard: check was any data returned?
                guard data != nil else{
                    print("no data return")
                    return
                }
                self.tableView.reloadData()
                }.resume()
        }
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Call function to Get all Json texts
        getText()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    @IBAction func add_twitter(_ sender: UIBarButtonItem) {
        var texto: String = ""
        
        // criando o alerta
        let alert = UIAlertController(title: "O que você quer tweetar?", message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        // criando o textFielf
        alert.addTextField { (guestName: UITextField!) -> Void in
            guestName.placeholder = "Digite o tweet"
            
        }
        
        alert.addAction(UIAlertAction(title: "Salvar", style: UIAlertActionStyle.default, handler: { (alertAction) in
            texto = "\(alert.textFields![0].text!)"
            print("\(texto)")
            self.postText(texto: texto)
            print("Salvar")
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.cancel, handler: { (alertAction) in
            print("Cancelei")
        }))
        
        self.present(alert, animated: true, completion: nil)
        
        
    }
    @IBAction func edit_twitter(_ sender: AnyObject?) {
        var texto: String = ""
        
        // criando o alerta
        let alert = UIAlertController(title: "Edite seu tweet!", message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        // criando o textFielf
        alert.addTextField { (guestName: UITextField!) -> Void in
            guestName.placeholder = "Digite o tweet"
            
        }
        
        alert.addAction(UIAlertAction(title: "Salvar", style: UIAlertActionStyle.default, handler: { (alertAction) in
            texto = "\(alert.textFields![0].text!)"
            print("\(texto)")
//            self.editText(id: indexPath.row, texto: texto)
            print("Salvar")
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.cancel, handler: { (alertAction) in
            print("Cancelei")
        }))
        
        self.present(alert, animated: true, completion: nil)
        
        
    }
    //MARK: - Data Source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = tableData[indexPath.row]
        return cell
    }
    
    //MARK: - Delegate
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            print("DELETE•ACTION");
//            self.deleteText(id: indexPath.row)
            self.tableData.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
        }
        
        let share = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
            print("EDIT•ACTION");

        }
        
        share.backgroundColor = UIColor.blue
        
        return [delete, share]
    }
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        
//        if editingStyle == UITableViewCellEditingStyle.delete{
//            deleteText(id: indexPath.row)
//            tableData.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .fade)
//            tableView.reloadData()
//        } else if editingStyle == UITableViewCellEditingStyle.insert{
//            tableView.reloadData()
//            
//        }
//    }
    
}

