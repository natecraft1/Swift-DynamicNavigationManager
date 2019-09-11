// During FB interview we got into the discussion of how to provide a navigation flow manager which asks
// for the next step which is initialized with different params depending on which VC will be presented next.

import UIKit

enum Page {
    case search(SearchInitializer)
    case seatSelection(SeatSelectionInitializer)
    case payment(PaymentInitializer)
    case confirmation(ConfirmationInitializer)
    
    typealias SearchInitializer = ([String]) -> UIViewController
    typealias SeatSelectionInitializer = ([Int]) -> UIViewController
    typealias PaymentInitializer = (String) -> UIViewController
    typealias ConfirmationInitializer = (Bool) -> UIViewController
}

enum Step {
    case search
    case seatSelection
    case payment
    case confirmation

    var page: Page {
        switch self {
        case .search:
            return Page.search(FlowManager.createSearchController)
        case .confirmation:
            return Page.confirmation(FlowManager.createConfirmationController)
        case .seatSelection:
            return Page.seatSelection(FlowManager.createSeatSelectionController)
        case .payment:
            return Page.payment(FlowManager.createPaymentController)
        }
    }
}

class FlowManager {
    var steps: [Step] = [.search, .seatSelection, .payment, .confirmation]
    var current: Int = 0
    
    func getNextStep(skippingTo: Step? = nil) -> Step {
        var next = current + 1
        
        if let skipTo = skippingTo, let nextIdx = steps.firstIndex(of: skipTo) {
            next = Int(nextIdx)
        }
        current = next
        return steps[current]
    }

    static func createSearchController(data: [String]) -> SearchController {
        return SearchController(strings: data)
    }
    
    static func createConfirmationController(data: Bool) -> ConfirmationController {
        return ConfirmationController(b: data)
    }
    
    static func createPaymentController(s: String) -> PaymentController {
        return PaymentController(string: s)
    }
    
    static func createSeatSelectionController(data: [Int]) -> SeatSelectionController {
        return SeatSelectionController(ints: data)
    }
}

class MainController: UIViewController {
    var flow: FlowManager!
    
    convenience init(flow: FlowManager) {
        self.init()
        self.flow = flow
    }
    
    func didTapNext(skippingTo: Step? = nil) {
        let step = flow.getNextStep(skippingTo: skippingTo)
        var controller: UIViewController
        switch step.page {
        case .confirmation(let initializer):
            controller = initializer(true)
        case .payment(let initializer):
            controller = initializer("hello world")
        case .search(let initializer):
            controller = initializer(["one", "two"])
        case .seatSelection(let initializer):
            controller = initializer([1,2,3])
        }
        present(controller, animated: true, completion: nil)
    }
    
}

class SearchController: UIViewController {
    init(strings: [String]) {
        super.init(nibName: nil, bundle: nil)
        print(strings, self)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}

class SeatSelectionController: UIViewController {
    init(ints: [Int]) {
        super.init(nibName: nil, bundle: nil)
        print(ints, self)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}

class PaymentController: UIViewController {
    init(string: String) {
        super.init(nibName: nil, bundle: nil)
        print(string, self)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}

class ConfirmationController: UIViewController {
    init(b: Bool) {
        super.init(nibName: nil, bundle: nil)
        print(b, self)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}

let main = MainController(flow: FlowManager())
main.didTapNext(skippingTo: .payment)
//main.didTapNext()
main.didTapNext()

