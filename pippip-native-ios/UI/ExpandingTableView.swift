//
//  ExpandingTableView.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/27/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class ExpandingTableView: UITableView, UITableViewDelegate, UITableViewDataSource {

    var expandingModel: ExpandingTableModelProtocol? {
        didSet {
            self.delegate = self
            self.dataSource = self
        }
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if let model = expandingModel {
            return model.tableModel[section]?.count ?? 0
        }
        else {
            return 0
        }

    }

    func numberOfSections(in tableView: UITableView) -> Int {

        if let model = expandingModel {
            return model.tableModel.count
        }
        else {
            return 0
        }

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let model = expandingModel {
            return model.tableModel[indexPath.section]?[indexPath.item].cell ?? UITableViewCell()
        }
        else {
            return UITableViewCell()
        }

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if let model = expandingModel {
            if let selector = model.tableModel[indexPath.section]?[indexPath.item].selector {
                selector.didSelect(indexPath)
            }
        }

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if let model = expandingModel {
            return model.tableModel[indexPath.section]?[indexPath.item].cellHeight ?? 0.0
        }
        else {
            return 0.0
        }

    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        if let model = expandingModel {
            return model.headerViews[section]?.view
        }
        else {
            return nil
        }

    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        if let model = expandingModel {
            return model.headerViews[section]?.height ?? 0.0
        }
        else {
            return 0.0
        }

    }

    func expandRow(at indexPath: IndexPath, cells: [ CellDataProtocol ]) {

        if let model = expandingModel {
            model.insertCells(cells, section: indexPath.section, at: indexPath.item+1)
            self.insertRows(at: model.insertPaths, with: .top)
        }

    }

    func collapseRow(at indexPath: IndexPath, count: Int) {

        if let model = expandingModel {
            let _ = model.removeCells(section: indexPath.section, row: indexPath.item+1, count: count)
            self.deleteRows(at: model.deletePaths, with: .bottom)
        }

    }

    func rowsDeleted(animation: UITableViewRowAnimation) {

        if let model = expandingModel {
            self.deleteRows(at: model.deletePaths, with: animation)
        }

    }

    func rowInserted(animation: UITableViewRowAnimation) {

        if let model = expandingModel {
            self.insertRows(at: model.insertPaths, with: animation)
        }
        
    }

}
