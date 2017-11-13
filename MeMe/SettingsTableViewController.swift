//
//  SettingsTableViewController.swift
//  MeMe
//
//  Created by Guilherme Ramos on 12/11/2017.
//  Copyright © 2017 Guilherme Ramos. All rights reserved.
//

import UIKit

protocol SettingsTableViewControllerDelegate: class {
    func didSelect(font: UIFont?)
}

class SettingsTableViewController: UITableViewController {
    // MARK: Properties

    @IBOutlet weak var fontSettingDetailLabel: UILabel!
    var fonts: [String] = []
    var selectedFont: UIFont?
    let animationDuration: TimeInterval = 0.25
    weak var delegate: SettingsTableViewControllerDelegate?

    // This enum will define which option was selected based on the tag of the cell
    enum SettingsOption: Int {
        case font = 0, color
    }

    // This enum will define which group we'll have for settings
    enum SettingsOptionGroup: Int {
        case text = 0, image
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadFonts()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Setup the previous saved selected font or tell the user to select one
        if let font = UserDefaults.standard.value(forKey: NSAttributedStringKey.font.rawValue) as? String {
            fontSettingDetailLabel.text = font
        } else {
            fontSettingDetailLabel.text = "Impact"
        }
    }

    // MARK: UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard let cell = tableView.cellForRow(at: indexPath), let option = SettingsOption(rawValue: cell.tag) else {
            return
        }

        switch option {
        case .font:
            showPickerView()
        default:
            break
        }
    }

    // Load all available fonts into arrays
    fileprivate func loadFonts() {
        for fontFamily in UIFont.familyNames.sorted() {
            for fontName in UIFont.fontNames(forFamilyName: fontFamily).sorted() {
                fonts.append(fontName)
            }
        }
    }

    // Since i couldn't find a way to resize the alertcontroller with the picker view
    // I used the solution based on the stackoverflow answer of @bubuxu
    // reference: https://stackoverflow.com/questions/41361177/sizing-a-uipickerview-inside-a-uialertview
    fileprivate func showPickerView() {
        let controller = UIAlertController()
        controller.message = "\n\n\n\n\n\n\n\n\n"

        let picker = UIPickerView(frame: CGRect(x: 0, y: 0, width: controller.view.frame.width, height: 160))
        picker.delegate = self
        picker.dataSource = self

        controller.view.addSubview(picker)

        let action = UIAlertAction(title: "OK", style: .default, handler: { (_) in
            if picker.selectedRow(inComponent: 0) == 0 {
                self.pickerView(picker, didSelectRow: 0, inComponent: 0)
            }
        })
        controller.addAction(action)

        present(controller, animated: true) {
            picker.frame.size.width = controller.view.frame.width
        }
    }

    // MARK: Actions

    // Dismiss the settings view controller returning to our main view controller
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    // Pass the selected font back to the main view controller
    // and dismiss the settingsviewcontroller
    @IBAction func doneButtonPressed(_ sender: Any) {
        guard delegate != nil else {
            return
        }

        if let selectedFont = selectedFont {
            delegate?.didSelect(font: selectedFont)
            UserDefaults.standard.set(selectedFont.fontName, forKey: NSAttributedStringKey.font.rawValue)
        }

        dismiss(animated: true, completion: nil)
    }
}

// MARK: UIPickerViewDelegate, UIPickerViewDataSource
// Currently used as a SIMPLE SOLUTION for a font change setting
extension SettingsTableViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return fonts.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return fonts[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Instantiate the indexPath for the font option setting
        let indexPath = IndexPath(row: SettingsOption.font.rawValue, section: SettingsOptionGroup.text.rawValue)
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }
        selectedFont = UIFont(name: fonts[row], size: 40)
        cell.detailTextLabel?.text = selectedFont?.fontName
    }
}
