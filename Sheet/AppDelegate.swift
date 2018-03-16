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
    var pageVC: UIPageViewController? {
        return window?.rootViewController as? UIPageViewController
    }

    var sheets: [Sheet] = [Sheet(title: "Sheet 1", paragraphs: [Paragraph(text: "", date: Date())]), Sheet(title: "Sheet 2", paragraphs: [Paragraph(text: "", date: Date())])]
    
    func makeViewController(sheet: Sheet) -> ViewController {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as! ViewController
        viewController.paragraphs = sheet.paragraphs
        viewController.delegate = self
        viewController.title = sheet.title
        return viewController
    }
    
    func makeSheetTitle() -> String {
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
        pageVC?.dataSource = self
        let viewController = makeViewController(sheet: sheets.first!)
        pageVC?.setViewControllers([viewController], direction: .forward, animated: false, completion: nil)
        
        return true
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
    
    func viewController(_ viewController: ViewController, didUpdate paragraphs: [Paragraph]) {
        if let index = sheets.index(where: { $0.title == viewController.title }) {
            sheets[index] = Sheet(title: viewController.title!, paragraphs: paragraphs)
        }
    }
    
    func viewController(_ viewController: ViewController, didRequest operation: ViewControllerOperation) {
        guard let index = sheets.index(where: { $0.title == viewController.title }) else { return }
        switch operation {
        case .create:
            let newSheet = Sheet(title: makeSheetTitle(), paragraphs: [Paragraph(text: "", date: Date())])
            sheets.append(newSheet)
            pageVC?.setViewControllers([makeViewController(sheet: newSheet)], direction: .forward, animated: true, completion: nil)
            
        case .delete:
            guard sheets.count > 1 else { break }
            sheets.remove(at: index)
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
    }
    
}

