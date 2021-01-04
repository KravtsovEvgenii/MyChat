//
//  PeopleViewController.swift
//  Chat
//
//  Created by User on 05.12.2020.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class PeopleViewController: UIViewController {
    
    init(currentUser: ChatUser) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
        title = currentUser.username
    }
    deinit {
        usersListener?.remove()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let currentUser: ChatUser
    
    var collectionView: UICollectionView!
    var users: [ChatUser] = []
    private var usersListener: ListenerRegistration?
    var dataSource: UICollectionViewDiffableDataSource<Section, ChatUser>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSearchBar()
        setupCollectionView()
       createDataSource()
        
        //Отслеживаем изменения в базе
        usersListener = ListenerService.shared.usersObserve(users: users, completion: { (result) in
            switch result {
            
            case .success(let chatUsers):
                self.users = chatUsers
                self.loadData(withSearchText: nil)
            case .failure(let error):
                self.showAlert(withTitle: "Error", withMessage: error.localizedDescription)
            }
        })
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "LogOut", style: .plain, target: self, action: #selector(logOutAction))
    }
    
    @objc private func logOutAction() {
        let alertController = UIAlertController(title: nil, message: "Are you sure?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancel)
        let okAction = UIAlertAction(title: "Yes", style: .destructive) { (_) in
            do{
                try Auth.auth().signOut()
                let keyWindow =  UIApplication.shared.windows.filter {$0.isKeyWindow}.first
                keyWindow?.rootViewController = AuthViewController()
            }catch let error{
                print(error.localizedDescription)
            }
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    enum Section : Int, CaseIterable {
        case users
        
        func discription(usersCount: Int) -> String {
            switch self {
            case .users:
                return "\(usersCount) Peoples"
            }
        }
    }



}
//MARK: -UICollectionViewDelegate
extension PeopleViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let user = dataSource.itemIdentifier(for: indexPath) else {return}
        let profileVC = ProfileViewController(user: user)
        present(profileVC, animated: true, completion: nil)
    }
    
}
//MARK: SetupCollectionView
extension PeopleViewController {
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: creatingCompositionalLayout())
        collectionView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        collectionView.backgroundColor = .mainWhite()
        view.addSubview(collectionView)
        collectionView.register(UserCell.self, forCellWithReuseIdentifier: UserCell.reuseId )
        
        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeader.reuseId)
        collectionView.delegate = self
    }
    
    //MARK: Setup Search Bar
    private func setupSearchBar() {
        navigationController?.navigationBar.barTintColor = .mainWhite()
        navigationController?.navigationBar.shadowImage = UIImage()
        //Search Controller
        let searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
    }
    
    private func creatingCompositionalLayout() -> UICollectionViewLayout {
        
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, enviroment) -> NSCollectionLayoutSection? in
            guard let section = Section(rawValue: sectionIndex) else {return nil}
            
            switch section{
            case .users:
                return self.createusersSection()
            }
        }
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.interSectionSpacing = 20
        layout.configuration = configuration
        return layout
    }
    
    private func createusersSection()-> NSCollectionLayoutSection {
        let itmeSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itmeSize)
        //Закладываем ширину item 0,6 от ширины секции 
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.6))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        group.interItemSpacing = .fixed(15)
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 15
        section.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 15, bottom: 0, trailing: 15)
        let sectionHeader = createSectionHeader()
        section.boundarySupplementaryItems = [sectionHeader]
        return section
    }
    private func loadData(withSearchText text: String?) {
        let filtered = users.filter { (user) -> Bool in
            return user.contains(text: text)
        }
        var snapshot = NSDiffableDataSourceSnapshot<Section,ChatUser>()
        snapshot.appendSections([.users,])
        snapshot.appendItems(filtered, toSection: .users)
        dataSource?.apply(snapshot)
        
    }
    
    
    //Create Header
    
    private func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let sectionHeaderSize = NSCollectionLayoutSize(widthDimension:              .fractionalWidth(1),
                                                       heightDimension: .estimated(1))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: sectionHeaderSize,
                                                                        elementKind: UICollectionView.elementKindSectionHeader,
                                                                        alignment: .top)
        
        return sectionHeader
    }
    
    private func createDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section,ChatUser>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, user) -> UICollectionViewCell? in
            guard let section = Section(rawValue: indexPath.section) else {return nil}
            switch section {
            case .users :
                let cell = self.configure(collectionView: collectionView, cellType: UserCell.self, with: user, for: indexPath)
                return cell
            }
            
        })
        //Создаем хедеры и конфигурируем в соответствии с секцией
        dataSource?.supplementaryViewProvider = {
            collectionView, kind, indexPath in
            guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeader.reuseId, for: indexPath) as? SectionHeader else { fatalError("Can not create new section header") }
            guard let section = Section(rawValue: indexPath.section) else { fatalError("Unknown section kind") }
            let items = self.dataSource.snapshot().itemIdentifiers(inSection: .users)
            sectionHeader.configure(text: section.discription(usersCount: items.count),
                                    font: .systemFont(ofSize: 30, weight: .light),
                                    textColor: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1))
            return sectionHeader
        }
    }
}

    
    

//MARK: Search bar Delegate
extension PeopleViewController : UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        loadData(withSearchText: searchText)
    }
}
