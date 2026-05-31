//
//  ColorsViewController.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit
import Destinations

struct ColorDetailSelectionModel: Hashable {

    var color: ColorViewModel?
    var targetID: UUID?

}

@Observable
final class ColorsListInterfaceState: DestinationStateable, DestinationTypes {

    @AutoCaseIterable
    enum Events: EventTypeable {
        case color
        case retrieveInitialColors
        case moreButton

        var rawValue: String {
            switch self {
                case .color:
                    return "color"
                case .retrieveInitialColors:
                    return "retrieveInitialColors"
                case .moreButton:
                    return "moreButton"
            }
        }

        static func == (lhs: Events, rhs: Events) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(rawValue)
        }
    }

    enum InteractorType: InteractorTypeable {
        case colors
    }

    typealias Destination = ControllerDestination<ColorsViewController, Events, DestinationType, AppContentType, TabType, InteractorType>

    var destination: Destination

    var stateModel: (any ColorsListStateModeling)

    init(destination: Destination, state: (any ColorsListStateModeling)) {
        self.destination = destination
        self.stateModel = state
    }
}

final class ColorsViewController: UIViewController, UICollectionViewDelegate, ControllerDestinationInterfacing, DestinationTypes {

    typealias EventType = ColorsListInterfaceState.Events
    typealias InteractorType = ColorsListInterfaceState.InteractorType
    typealias Destination = ColorsListInterfaceState.Destination
    
    enum ColorItem: Sendable, Equatable, Hashable {
        case color(model: ColorViewModel?)

        var reuseID: String {
            switch self {
                case .color(_):
                    return "ColorItem"
            }
        }
    }
    
    private enum Section: Equatable, Hashable {
        case colors
    }
    
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, ColorItem>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, ColorItem>
    
    lazy private var dataSource = makeDataSource()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
    
        collectionView.register(ColorCell.self, forCellWithReuseIdentifier: ColorItem.color(model: nil).reuseID)
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    
    lazy var collectionViewLayout: UICollectionViewCompositionalLayout = {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIdx, environment in
            guard let strongSelf = self else { return NSCollectionLayoutSection(group: NSCollectionLayoutGroup(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))) }
                        
            let inset: CGFloat = 2.5

            let section = strongSelf.dataSource.snapshot().sectionIdentifiers[safe: sectionIdx]

            let layoutSection: NSCollectionLayoutSection
            
            switch section {
                case .colors:

                    let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension:  .fractionalWidth(1), heightDimension: .estimated(150)))
                    
                    let horizontalMargin = 10.0

                    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(150))
                    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                        
                    layoutSection = NSCollectionLayoutSection(group: group)
                    layoutSection.interGroupSpacing = 10
                    layoutSection.contentInsets =  NSDirectionalEdgeInsets(top: 0, leading: horizontalMargin, bottom: 10, trailing: horizontalMargin)
                    
                    return layoutSection
                case .none:
                    return nil
            }
        }
        
        layout.configuration.scrollDirection = .vertical

        return layout
    }()

    var destinationState: ColorsListInterfaceState

    init(destination: Destination, state: (any ColorsListStateModeling)) {
        self.destinationState = ColorsListInterfaceState(destination: destination, state: state)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        collectionView.dataSource = dataSource

    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        navigationController?.navigationBar.tintColor = .white
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
                
        let button = PillButton()
        button.titleLabel?.text = "Request More"
        button.tapAction { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.requestMoreButtonAction()
        }
        
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            button.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -5)
        ])
        
    }
    
    func requestMoreButtonAction() {
        destination().handleEvent(.moreButton, content: nil)
    }
    
    func updateItems(items: [ColorsRequest.Item]) {
        self.buildNewCollection(with: items)
    }
    
    
    private func makeDataSource() -> UICollectionViewDiffableDataSource<Section, ColorItem> {
        let dataSource: UICollectionViewDiffableDataSource<Section, ColorItem> = UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, item in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: item.reuseID, for: indexPath)
                        
            switch item {
                case .color(model: let colorModel):
                    if let cell = cell as? ColorCell, let colorModel {
                        cell.update(with: colorModel)
                    }
            }
            
            return cell
        }
        
        return dataSource
    }
    
    
    func buildNewCollection(with items: [ColorViewModel]) {
                
        var snapshot = NSDiffableDataSourceSnapshot<Section, ColorItem>()

        let sections = buildCollectionSections()

        snapshot.appendSections(sections)

        if sections.contains(.colors), items.count > 0 {
            snapshot.appendItems(items.map { ColorItem.color(model: $0) }, toSection: .colors)
        }
        
        if snapshot.numberOfSections > 0 {
            dataSource.apply(snapshot, animatingDifferences: true)
            snapshot.reloadSections(sections)
        }
    }
    
    private func buildCollectionSections() -> [Section] {
        var sections: [Section] = []
        
        sections.append(.colors)
        
        return sections
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let model = destinationState.stateModel.items[safe: indexPath.item] else { return }
        destination().handleEvent(.color, content: .color(model: model))
    }

}
