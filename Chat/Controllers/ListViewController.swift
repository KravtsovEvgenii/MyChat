
//  ListViewController.swift
//  Chat
//  Created by User on 05.12.2020.

import UIKit
import FirebaseFirestore



class ListViewController: UIViewController {
    
    
    init(currentUser: ChatUser) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
        title = currentUser.username
    }
    deinit{
        waitingChatsListener?.remove()
        activeChatsListener?.remove()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private var waitingChatsListener: ListenerRegistration?
    private var activeChatsListener: ListenerRegistration?
    
    private let currentUser: ChatUser
    enum Section : Int, CaseIterable {
        case waitingChats
        case activeChats
        
        func description() -> String {
            switch self {
            case .waitingChats:
                return "Waiting chats"
            case .activeChats:
                return "Active chats"
            }
        }
    }
    
    var activeChats = [Chat]()
    var waitingChats = [Chat]()
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, Chat>?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        setupCollectionView()
        setupDataSource()
        reloadData()
        setupListeners()
      
     
    }
}
//MARK: Listener setup
extension ListViewController {
    func setupListeners() {
        waitingChatsListener = ListenerService.shared.waitingChatsObserve(chats: waitingChats, completion: { (result) in
            switch result {
            
            case .success(let waitingChats):
                if self.waitingChats != [], self.waitingChats.count <= waitingChats.count {
                    let chatRequestVC = ChatRequestViewController(chat: waitingChats.last!)
                    chatRequestVC.delegate = self
                    self.present(chatRequestVC, animated: true, completion: nil)
                }
                self.waitingChats = waitingChats
                self.reloadData()
            case .failure(let error):
                self.showAlert(withTitle: "Error", withMessage: error.localizedDescription)
            }
        })
    
     activeChatsListener = ListenerService.shared.activeChatsObserve(chats: activeChats, completion: { (result) in
        switch result {
        case .success(let activeChats):
            self.activeChats = activeChats
            self.reloadData()
        case .failure(let error):
            self.showAlert(withTitle: "Error", withMessage: error.localizedDescription)
        }
    })
    }
}
//MARK: UICollectionViewDelegate
extension ListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let chat = dataSource?.itemIdentifier(for: indexPath) else {return}
        guard let section = Section(rawValue: indexPath.section) else {return}
        switch section {
        case .waitingChats:
            let chatRequestVC = ChatRequestViewController(chat: chat)
            chatRequestVC.delegate = self
            self.present(chatRequestVC, animated: true, completion: nil)
        case .activeChats:
            let chatVC = ChatsViewController(user: currentUser, chat: chat)
            navigationController?.pushViewController(chatVC, animated: true)
        }
    }
}

extension ListViewController {
    //MARK: setupCollectionView
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: creatingCompositionalLayout())
        collectionView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        collectionView.backgroundColor = .mainWhite()
        view.addSubview(collectionView)
        collectionView.register(WaitingChatCell.self, forCellWithReuseIdentifier:WaitingChatCell.reuseId )
        collectionView.register(ActiveChatCell.self, forCellWithReuseIdentifier: ActiveChatCell.reuseId)
        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeader.reuseId)
        collectionView.delegate = self
    }
    
    private func reloadData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section,Chat>()
        snapshot.appendSections([.waitingChats,.activeChats,])
        snapshot.appendItems(activeChats, toSection: .activeChats)
        snapshot.appendItems(waitingChats, toSection: .waitingChats)
        dataSource?.apply(snapshot)
        
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
}
//MARK: Setup DataSource
extension ListViewController {
    
    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section,Chat>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, chatPerson) -> UICollectionViewCell? in
            guard let section = Section(rawValue: indexPath.section) else {return nil}
            switch section {
            
            case .activeChats:
                let cell = self.configure(collectionView: collectionView, cellType: ActiveChatCell.self, with: chatPerson, for: indexPath)
                return cell
            case .waitingChats:
                let cell = self.configure(collectionView: collectionView, cellType: WaitingChatCell.self, with: chatPerson, for: indexPath)
                return cell
            }
        })
        //Создаем хедеры и конфигурируем в соответствии с секцией
        dataSource?.supplementaryViewProvider = {
            collectionView, kind, indexPath in
            guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeader.reuseId, for: indexPath) as? SectionHeader else { fatalError("Can not create new section header") }
            guard let section = Section(rawValue: indexPath.section) else { fatalError("Unknown section kind") }
            sectionHeader.configure(text: section.description(),
                                    font: .laoSangamMN20(),
                                    textColor: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1))
            return sectionHeader
        }
    }
}

extension ListViewController {
    
    //MARK: CreatingCompositionalLayout
    private func creatingCompositionalLayout() -> UICollectionViewLayout {
        
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, enviroment) -> NSCollectionLayoutSection? in
            guard let section = Section(rawValue: sectionIndex) else {return nil}
            
            switch section{
            case .activeChats:
                return self.createActiveChats()
            case .waitingChats:
                return self.createWaitingChats()
            }
        }
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.interSectionSpacing = 20
        layout.configuration = configuration
        return layout
    }
    
    private func createWaitingChats() -> NSCollectionLayoutSection{
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(88), heightDimension: .absolute(88))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0)
        let section = NSCollectionLayoutSection(group: group)
        //Определяем что секция будет скроллиться
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 0, trailing: 20)
        section.interGroupSpacing = 16
        
        let sectionHeader = createSectionHeader()
        section.boundarySupplementaryItems = [sectionHeader]
        return section
    }
    
    private func createActiveChats() -> NSCollectionLayoutSection{
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(78))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 8, bottom: 0, trailing: 8)
        section.interGroupSpacing = 8
        //Добавляем хедер секции
        let sectionHeader = createSectionHeader()
        section.boundarySupplementaryItems = [sectionHeader]
        return section
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
}

//MARK: Search bar Delegate
extension ListViewController : UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
    }
}
//MARK: WaitingChatsNavigationDelegate
extension ListViewController: WaitingChatsNavigationDelegate {
    func removeWaitingChat(chat: Chat) {
        FireStoreService.shared.deleteWaitingChat(chat: chat) { (result) in
            switch result {
            case .success():
                self.showAlert(withTitle: "Success", withMessage: "Chat Deleted")
            case .failure(let error):
                self.showAlert(withTitle: "Error", withMessage: error.localizedDescription)
            }
        }
        
    }
    
    func changeChatToActive(chat: Chat) {
        FireStoreService.shared.changeToActive(chat: chat) { (result) in
            switch result {
            case .success():
                self.showAlert(withTitle: "Success", withMessage: "Chat with \(chat.friendName)")
            case .failure(let error):
                self.showAlert(withTitle: "Error", withMessage: error.localizedDescription)
            }
        }
    }
    
    
}

//MARK: Canvas setup
//import SwiftUI
//struct ListViewControllerProvider: PreviewProvider {
//
//    static var previews: some View {
//        ContainerView().edgesIgnoringSafeArea(.all)
//    }
//
//    struct ContainerView: UIViewControllerRepresentable{
//        typealias UIViewControllerType = MainTabBarController
//
//        func makeUIViewController(context: Self.Context) -> Self.UIViewControllerType{
//            let fakeUser = ChatUser(username: "fake", email: "fake", avatarStringURL: "fake", description: "fake", sex: "fake", id: "fake")
//            return MainTabBarController(currentUser: fakeUser)
//        }
//        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
//
//        }
//    }
//}
