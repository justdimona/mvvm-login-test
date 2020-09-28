//
//  LoginViewModel.swift
//  Smartlink Cameras
//
//  Created by SecureNet Mobile Team on 1/10/20.
//  Copyright © 2020 SecureNet Technologies, LLC. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

final class LoginViewModel: ViewModelProtocol {
    
    typealias Dependency = HasUserService
    
    struct Bindings {
        let loginButtonTap: Observable<Void>
        let rememberUserCheckboxTap: Observable<Void>
        let usernameTextChanged: Observable<String?>
    }
    
    let loginResult: Observable<Void>
    
    var rememberUserCheckbox = BehaviorRelay(value: false)
    
    let disposeBag = DisposeBag()
        
    init(dependency: Dependency, bindings: Bindings) {
        
        loginResult = bindings.loginButtonTap
            .do(onNext: { _ in dependency.userService.login()  })
        
        bindings.rememberUserCheckboxTap
            .subscribe(onNext: { [weak self] (_) in guard let self = self else { return }
                self.rememberUserCheckbox.accept(!self.rememberUserCheckbox.value)
            })
            .disposed(by: disposeBag)
        
        bindings.usernameTextChanged
            .debounce(.seconds(3), scheduler: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .distinctUntilChanged()
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .flatMapLatest { dependency.userService.baseURL(for: $0).materialize() }
            .compactMap { $0.element }
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)        
    }
    
    deinit {
        
    }
    
}
