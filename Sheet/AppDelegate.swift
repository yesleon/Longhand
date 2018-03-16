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

    var sheets: [Sheet] = [Sheet(title: "Sheet 1", paragraphs: [Paragraph(text: "", date: Date())]), Sheet(title: "Sheet 2", paragraphs: [Paragraph(text: "", date: Date())])]
    
    func makeViewController(sheet: Sheet) -> ViewController {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as! ViewController
        viewController.paragraphs = sheet.paragraphs
        viewController.delegate = self
        viewController.title = sheet.title
        return viewController
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        if let pageVC = window?.rootViewController as? UIPageViewController {
            pageVC.dataSource = self
            let viewController = makeViewController(sheet: sheets.first!)
            pageVC.setViewControllers([viewController], direction: .forward, animated: false, completion: nil)
        }
        return true
    }


}

extension AppDelegate: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let index = sheets.index(where: { $0.title == viewController.title }) {
            let nextIndex = index + 1
            if nextIndex < sheets.count {
                return makeViewController(sheet: sheets[nextIndex])
            } else {
                return nil
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let index = sheets.index(where: { $0.title == viewController.title }) {
            let previousIndex = index - 1
            if previousIndex >= 0 {
                return makeViewController(sheet: sheets[previousIndex])
            } else {
                return nil
            }
        }
        return nil
    }
    
}

extension AppDelegate: ViewControllerDelegate {
    
    func viewController(_ viewController: ViewController, didUpdate paragraphs: [Paragraph]) {
        if let index = sheets.index(where: { $0.title == viewController.title }) {
            sheets[index] = Sheet(title: viewController.title!, paragraphs: paragraphs)
        }
    }
    
}

