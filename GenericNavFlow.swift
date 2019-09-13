// During an interview I got into a discussion of how to provide a navigation flow manager which asks
// for the next step which is initialized with different params depending on which VC will be presented next.
// This is my idea...

import UIKit

enum Page: Equatable {
    case search(SearchInitializer)
    case seatSelection(SeatSelectionInitializer)
    case payment(PaymentInitializer)
    case confirmation(ConfirmationInitializer)
    
    typealias SearchInitializer = ([String]) -> SearchController
    typealias SeatSelectionInitializer = ([Int]) -> SeatSelectionController
    typealias PaymentInitializer = (String) -> PaymentController
    typealias ConfirmationInitializer = (Bool) -> ConfirmationController
    
    var identifier: String {
        switch self {
        case .confirmation:
            return "confirmation"
        case .seatSelection:
            return "seatSelection"
        case .payment:
            return "payment"
        case .search:
            return "search"
        }
    }
    
    static func ==(lhs: Page, rhs: Page) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

protocol FlightBookingFlow: UIViewController {
    func navigate(to: Page)
}

extension FlightBookingFlow {
    func navigate(to page: Page) {
        var controller: UIViewController
        
        switch page {
        case .confirmation(let confirmationVCInit):
            controller = confirmationVCInit(true)
        case .payment(let paymentVCInit):
            controller = paymentVCInit("hello world")
        case .search(let searchVCInit):
            controller = searchVCInit(["one", "two"])
        case .seatSelection(let seatSelectionInit):
            controller = seatSelectionInit([1,2,3])
        }
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

class MainController: UIViewController, FlightBookingFlow {
    var flow: FlowManager!
    
    convenience init(flow: FlowManager) {
        self.init()
        self.flow = flow
        navigate(to: flow.start())
    }
    
    func didTapNext(skippingTo: Page? = nil) {
        let page = flow.getNextStep(skippingTo: skippingTo)
        navigate(to: page)
    }

}

class FlowManager {
    var currentStep: Int = 0
    var flow: [Page] = [.search(SearchController.create),
                         .seatSelection(SeatSelectionController.create),
                         .payment(PaymentController.create),
                         .confirmation(ConfirmationController.create)]
    
    func start() -> Page {
        guard let firstPage = flow.first else { preconditionFailure("at least one page is required") }
        return firstPage
    }
    
    func getNextStep(skippingTo: Page? = nil) -> Page {
        var next = currentStep + 1
        
        if let skipTo = skippingTo, let nextIdx = flow.firstIndex(of: skipTo) {
            next = Int(nextIdx)
        }
        
        guard next < flow.count else { return flow[currentStep] }
        
        currentStep = next
        return flow[currentStep]
    }

}

class SearchController: UIViewController, FlightBookingFlow {
    init(strings: [String]) {
        super.init(nibName: nil, bundle: nil)
        print(strings, self)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    static func create(data: [String]) -> SearchController {
        return SearchController(strings: data)
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
    
    static func create(data: [Int]) -> SeatSelectionController {
        return SeatSelectionController(ints: data)
    }
}

class PaymentController: UIViewController, FlightBookingFlow {
    init(string: String) {
        super.init(nibName: nil, bundle: nil)
        print(string, self)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    static func create(s: String) -> PaymentController {
        return PaymentController(string: s)
    }
}

class ConfirmationController: UIViewController, FlightBookingFlow {
    init(b: Bool) {
        super.init(nibName: nil, bundle: nil)
        print(b, self)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    static func create(data: Bool) -> ConfirmationController {
        return ConfirmationController(b: data)
    }
}

let main = MainController(flow: FlowManager())
// toggle between the next two lines
main.didTapNext(skippingTo: .payment(PaymentController.create))
//main.didTapNext()
main.didTapNext()

