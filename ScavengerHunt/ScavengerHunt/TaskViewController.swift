//
//  ViewController.swift
//  ScavengerHunt
//
//  Created by Debbie Hirshson on 1/19/25.
//

import UIKit

class TaskViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyStateLabel: UILabel!
    
    var hunts = [Task](){
        didSet{
            emptyStateLabel.isHidden = !hunts.isEmpty
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableHeaderView = UIView()
        tableView.dataSource = self
        hunts = Task.mockHunts
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
       
        //if statement uneccesary as there is only one possible segue
        if segue.identifier == "MapSegue" {
            if let mapViewController = segue.destination as? MapViewController,
                // Get the index path for the current selected table view row.
               let selectedIndexPath = tableView.indexPathForSelectedRow {

                // Get the task associated with the slected index path
                let task = hunts[selectedIndexPath.row]

                // Set task to pass to next screen
                mapViewController.task = task
            }
        }
    } //end prepare

} //end class
extension TaskViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hunts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as? TaskCell else {
            fatalError("Unable to dequeue Hunt Cell")
        }

        cell.configure(with: hunts[indexPath.row])

        return cell
    }
}

