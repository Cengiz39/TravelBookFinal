

import UIKit
import CoreData
class ViewController: UIViewController , UITableViewDelegate, UITableViewDataSource {

    var idArray = [UUID]()
    var titleArray = [String]()
    var storedId = UUID()
    var storeCheck = Bool()
    var countedObject = Int()
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
        self.navigationController?.navigationBar.prefersLargeTitles = true
       
    }
    override func viewWillAppear(_ animated: Bool) {
        getData()
        if countedObject > 0 {
         navigationItem.title = "Lokasyonlar: \(countedObject)"
            }else{
            self.navigationController?.navigationBar.prefersLargeTitles = false
            navigationItem.title = "Gösterilecek herhangi bir eleman yok."
        }
    }
    @objc func addButtonClicked(){
        storeCheck = false
        performSegue(withIdentifier: "FirstSegue", sender: nil)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        storedId = idArray[indexPath.row]
        storeCheck = true
        performSegue(withIdentifier: "FirstSegue", sender: nil)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = titleArray[indexPath.row]
        return cell
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FirstSegue"{
            let destinationVC = segue.destination as! SecondViewController
            print(storeCheck)
            destinationVC.checkedVar = storeCheck
            destinationVC.storedIdVar = storedId
        }
    }
    func getData(){
        print("getData caller.")
        
        idArray.removeAll(keepingCapacity: false)
        titleArray.removeAll(keepingCapacity: false)
        let appDelegateVar = UIApplication.shared.delegate as! AppDelegate
        let appContext = appDelegateVar.persistentContainer.viewContext
        let appFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LocationDb")
        appFetchRequest.returnsObjectsAsFaults = false
        do {
            let fetchResults = try appContext.fetch(appFetchRequest)
            for resultArray in fetchResults as! [NSManagedObject] {
                if let titleString = resultArray.value(forKey: "title") as? String{
                    
                    print(countedObject)
                    titleArray.append(titleString)
                }
                if let idValue = resultArray.value(forKey: "id") as? UUID{
                    idArray.append(idValue)
                }
                countedObject = titleArray.count
                tableView.reloadData()
            }
        } catch  {
            print("Error!")
        }
    }
}

