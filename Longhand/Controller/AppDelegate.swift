//
//  AppDelegate.swift
//  Sheet
//
//  Created by Li-Heng Hsu on 16/03/2018.
//  Copyright © 2018 Li-Heng Hsu. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var pageVC: UIPageViewController? {
        return window?.rootViewController as? UIPageViewController
    }
    private weak var statusBarBackgroundView: UIView?
    
    private let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("Sheets.plist")

    private var sheets: [Sheet] = [Sheet(title: "Sheet 1", paragraphs: [Paragraph(text: "", date: Date())]), Sheet(title: "Sheet 2", paragraphs: [Paragraph(text: "", date: Date())])]
    
    private func makeViewController(sheet: Sheet) -> ViewController {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as! ViewController
        viewController.paragraphs = sheet.paragraphs
        viewController.delegate = self
        viewController.title = sheet.title
        return viewController
    }
    
    private func makeSheetTitle() -> String {
        let prefix = "Sheet "
        let numbers = sheets.flatMap { sheet -> Int? in
            var title = sheet.title
            title.removeFirst(prefix.count)
            return Int(title)
        }
        let largestNumber = numbers.sorted().last ?? 0
        return prefix + "\(largestNumber + 1)"
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        do {
            let sheetsData = try Data(contentsOf: url)
            let sheets = try PropertyListDecoder().decode([Sheet].self, from: sheetsData)
            self.sheets = sheets
        } catch {
            print(error)
        }
        pageVC?.dataSource = self
        let viewController = makeViewController(sheet: sheets.first!)
        pageVC?.setViewControllers([viewController], direction: .forward, animated: false, completion: nil)
        
        let view = UIView(frame: window!.bounds)
        view.backgroundColor = .white
        window?.insertSubview(view, at: 0)
        
        window?.tintColor = #colorLiteral(red: 0.9463686347, green: 0.59736377, blue: 0.2002493739, alpha: 1)
        
        let statusBarBackgroundView = UIView()
        statusBarBackgroundView.backgroundColor = .white
        window?.addSubview(statusBarBackgroundView)
        self.statusBarBackgroundView = statusBarBackgroundView
        
        return true
    }
    
    func application(_ application: UIApplication, didChangeStatusBarFrame oldStatusBarFrame: CGRect) {
        DispatchQueue.main.async { [weak self] in
            guard let statusBarBackgroundView = self?.statusBarBackgroundView else { return }
            statusBarBackgroundView.frame = application.statusBarFrame
            self?.window?.bringSubview(toFront: statusBarBackgroundView)
        }
    }

}

extension AppDelegate: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = sheets.index(where: { $0.title == viewController.title }) else { return nil }
        let nextIndex = index + 1
        if nextIndex < sheets.count {
            return makeViewController(sheet: sheets[nextIndex])
        } else {
            return nil
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = sheets.index(where: { $0.title == viewController.title }) else { return nil }
        let previousIndex = index - 1
        if previousIndex >= 0 {
            return makeViewController(sheet: sheets[previousIndex])
        } else {
            return nil
        }
    }
    
}

extension AppDelegate: ViewControllerDelegate {
    
    func saveSheets() {
        do {
            let sheetsData = try PropertyListEncoder().encode(sheets)
            
            try sheetsData.write(to: url)
        } catch {
            print(error)
        }
    }
    
    func viewController(_ viewController: ViewController, didUpdate paragraphs: [Paragraph]) {
        if let index = sheets.index(where: { $0.title == viewController.title }) {
            sheets[index] = Sheet(title: viewController.title!, paragraphs: paragraphs)
            saveSheets()
        }
    }
    
    func viewController(_ viewController: ViewController, didRequest operation: ViewControllerOperation) {
        guard let index = sheets.index(where: { $0.title == viewController.title }) else { return }
        func create(at index: Int) {
            let newSheet = Sheet(title: makeSheetTitle(), paragraphs: [Paragraph(text: "", date: Date())])
            sheets.insert(newSheet, at: index)
            pageVC?.setViewControllers([makeViewController(sheet: newSheet)], direction: .forward, animated: true, completion: nil)
        }
        switch operation {
        case .create:
            create(at: index + 1)
            
        case .delete:
            sheets.remove(at: index)
            if sheets.isEmpty {
                create(at: index)
                break
            }
            let nextIndex = index
            let previousIndex = index - 1
            if nextIndex < sheets.count {
                let viewController = makeViewController(sheet: sheets[nextIndex])
                pageVC?.setViewControllers([viewController], direction: .forward, animated: true, completion: nil)
            } else if previousIndex >= 0 {
                let viewController = makeViewController(sheet: sheets[previousIndex])
                pageVC?.setViewControllers([viewController], direction: .reverse, animated: true, completion: nil)
            }
        }
        saveSheets()
    }
    
}

