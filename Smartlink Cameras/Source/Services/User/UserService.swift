//
//  UserService.swift
//  Smartlink Cameras
//
//  Created by SecureNet Mobile Team on 1/10/20.
//  Copyright © 2020 SecureNet Technologies, LLC. All rights reserved.
//

import Foundation
import RxRelay
import RxSwift

enum AuthenticationState {
    case signedIn
    case signedOut
}

protocol UserServiceProtocol {
    // Just an example
    
    // MARK: - Private variables
    var apiService: APIServiceProtocol! { get }
    var authenticationState: BehaviorRelay<AuthenticationState> { get }
    
    // MARK: - Public variables
    var isLoggedIn: Observable<Bool> { get }
    
    // MARK: - Public methods
    func login()
    func logout()
    func baseURL(for username: String) -> Observable<String>
    // ...
}

final class UserService: UserServiceProtocol {
    
    // MARK: - Private variables
    fileprivate(set) var apiService: APIServiceProtocol!
    fileprivate(set) var authenticationState: BehaviorRelay<AuthenticationState>
    fileprivate let disposeBag = DisposeBag()
    
    // MARK: - Public variables
    var isLoggedIn: Observable<Bool> {
        return UserDefaults.standard.rx
            .observe(Bool.self, UserDefaultKeys.isLoggedIn.rawValue)
            .map({ $0 ?? false })
    }
    
    
    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
        
        authenticationState = BehaviorRelay<AuthenticationState>(value: .signedOut)
        commonInit()
    }
    
    fileprivate func commonInit() {
        loggedInStream()
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    func login() {
        // Do API and other logic of course
        UserDefaults.standard.setLoggedIn(value: true)
    }
    
    func logout() {
        // Do API and other logic of course
        UserDefaults.standard.setLoggedIn(value: false)
    }
    
    func baseURL(for username: String) -> Observable<String> {
        do {
            let request = try apiService.request(username: username)
            return URLSession.shared.rx
                .json(request: request)
                .compactMap { $0 as? [String: Any] }
                .compactMap { $0["platform"] as? [String: Any] }
                .compactMap { $0["baseURL"] as? String }
        } catch {
            return Single.error(error).asObservable()
        }
    }
    
    deinit {
        apiService = nil
    }
    
}

extension UserService {
    
    fileprivate func loggedInStream() -> Observable<Void> {
        return isLoggedIn
            .do(onNext: { [weak self] value in self?.authenticationState.accept(value ? .signedIn : .signedOut) })
            .mapToVoid()
    }
    
}
