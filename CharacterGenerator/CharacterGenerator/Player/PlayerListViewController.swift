//
//  PlayerListViewController.swift
//  CharacterGenerator
//
//  Created by Brian Arnold on 2/19/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import UIKit

import RolePlayingCore

class PlayerListViewController: UITableViewController {
    
    var configuration: Configuration!
    var characterGenerator: CharacterGenerator!
    var players: Players! {
        return configuration.players
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton
        
        configuration = try! Configuration("Configuration")
        characterGenerator = try! CharacterGenerator(configuration)
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    @objc func insertNewObject(_ sender: Any) {
        let player = characterGenerator.makeCharacter()
        players.insert(player, at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let player = players[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! PlayerDetailViewController
                controller.player = player
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let player = players[indexPath.row]!
        cell.textLabel!.text = player.name
        cell.detailTextLabel!.text = "Level \(player.level) \(player.raceName) \(player.className)"
        cell.imageView!.image = UIImage(named: "GenericPlayer")
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            players.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // TODO: add support for inserting.
        }
    }

}

