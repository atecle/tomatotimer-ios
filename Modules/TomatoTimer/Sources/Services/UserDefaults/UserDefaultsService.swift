import Foundation

protocol UserDefaultsServiceProvider {
    var userDefaultsService: UserDefaultsServiceType { get }
}

extension UserDefaults {
    enum Key: String {
        case presentedOnboarding = "did_present_onboarding"
//        case presentedNewOnboarding = "did_present_onboarding"
        case presentedNewFeaturesOnboarding = "did_present_new_features_onboarding"
        case didSyncTomatoTimerPro = "did_sync_tomato_timer_pro"
        case didSyncTomatoTimerPlus = "did_sync_tomato_timer_plus"
        case didEnterBackground
        case didBecomeActive
    }
}

protocol UserDefaultsServiceType {
    func getValue<T>(key: UserDefaults.Key) -> T?
    func setValue<T>(key: UserDefaults.Key, value: T?)
}

struct UserDefaultsService: UserDefaultsServiceType {

    private let userDefaults: UserDefaults
    private let iCloudStore: NSUbiquitousKeyValueStore

    init(
        userDefaults: UserDefaults = .standard,
        iCloudStore: NSUbiquitousKeyValueStore = .default
    ) {
        self.userDefaults = userDefaults
        self.iCloudStore = iCloudStore
    }

    func getValue<T>(key: UserDefaults.Key) -> T? {
        return userDefaults.object(forKey: key.rawValue) as? T
    }

    func setValue<T>(key: UserDefaults.Key, value: T?) {
        return userDefaults.set(value, forKey: key.rawValue)
    }
}
