/*
import UIKit

private let reuseIdentifier = "Cell"

class ProjectListViewController: UICollectionViewController {
    
    typealias DataSource = UICollectionViewDiffableDataSource<Int, Project.ID>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int,  Project.ID>
    
    var dataSource: DataSource!
    var projects: [Project] = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        collectionView.backgroundColor = .systemGray6
        
        let url = URL(string: "http://127.0.0.1:5000/api/projects/get/all")!
        URLSession.shared.fetchData(for: url) { (result: Result<[Project], Error>) in
            switch result {
            case .success(let results):
                self.projects.append(contentsOf: results)
                self.updateSnapshot()
            case .failure(let error):
                print(error)
            }
        }
        
    }
    
    func updateSnapshot(reloading ids: [Project.ID] = []) {
           var snapshot = Snapshot()
           snapshot.appendSections([0])
           snapshot.appendItems(projects.map { $0.id })
           if !ids.isEmpty {
               snapshot.reloadItems(ids)
           }
           dataSource.apply(snapshot)
       }

}

class ProjectDoneButton: UIButton {
    var id: Project.ID?
}
*/
