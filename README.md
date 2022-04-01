# aether_core

Aether Core for Flutter
    
    Application framework for flutter development.    

## Settings files
Create the following 3 files:

    assets\system\settings.json
    assets\system\settings.staging.json
    assets\system\settings.debug.json

Flow logic in sequence:

    1. The system will first load the settings.json.
    2. If in staging mode, load settings.staging.json and override any existing settings.
    3. If in debug mode, load settings.debug.json and override any existing settings.

Example
~~~json
{
    "ApiBaseUrl": "https://viqcommunity.com",
    "ApiKey": "<Api Key>",
    "ApiConnectTimeoutInSec": 15,
    "GooglePlayURL": "https://play.google.com/store/apps/details?id=com.viqcore.community_live",
    "AppleAppStoreURL": "https://apps.apple.com/my/app/viqcore-community/id1499329657",
    "HuaweiAppGalleryURL": "https://appgallery.cloud.huawei.com/marketshare/app/C102024395?locale=en_GB&source=appshare&subsource=C102024395"
}
~~~

## AppService
Before runApp, initialize AppService. After that, you may access the service via App instance.
~~~dart
await AppService.init(); 
~~~

### Dialog, Notification and Progress indicator
~~~dart
// Configurations
App.config.dialog(void Function(DialogDefaultSettings settings) configure)
App.config.notification(void Function(NotificationDefaultSettings settings) configure)
App.config.progressIndicator(void Function(EasyLoading easyLoading) configure)

// Dialog
App.dialog({String? title, 
            String? description, 
            String? cancelTitle, 
            Color? cancelTitleColor, 
            String? buttonTitle, 
            Color? buttonTitleColor,  
            bool barrierDismissible = false, 
            DialogPlatform? dialogPlatform})
            
App.confirm(String question, 
            {String? title, 
             String? buttonTitle, 
             String? cancelButtonTitle})

// Notification
App.info(String info, {String? title})
App.error(dynamic error, {String? title})

// Progress indicator
App.showProgressIndicator({String? status})
App.dismissProgressIndicator()
~~~

## Credential Management
Example:
~~~dart
class CredentialManager {
  static void init() {
    App.config.silentLogin(() => CredentialManager.silentLogin());
    App.config.login((request) => CredentialManager.login(request));
    App.config.logout(() => CredentialManager.logout());

    App.connect.addAuthenticator<void>((request) async {
      final token = CredentialIdentity.refreshToken;
      if (token != null) {
        final result = await '/api/login/refresh'
            .api()
            .post(headers: {'x-refresh-token': token});
        if (result.hasError) {
          //AppAuth.reset();
          App.identity.signOut();
        }
      }
      return request;
    });
  }

  static Future<void> login(LoginRequest request) async {
    if (!request.validated()) return LoginStatus.failed;

    final result = await '/api/login/admin'
        .api(body: request.toMap())
        .post(timeout: const Duration(seconds: 5));

    if (result.hasError) return Future.error(result.errorText);
    
    App.identity.load(result.body);    
  }

  static Future<void> silentLogin() async {
    final result = await '/api/mylogin/silentlogin'
        .api()
        .post(timeout: const Duration(seconds: 10));

    if (result.isOk) {
      App.identity.load(result.body);
    }
  }

  static Future<void> logout() async {
    final result =
        await '/api/logout'.api().post(timeout: const Duration(seconds: 5));
    if (result.hasError) {
      // if failed to logout, we manually clear the cookies.
      App.connect.clearCookies();
    }
    //AppAuth.reset();
    App.identity.signOut();
    return await Get.toNamed('/');
  }
}
~~~

## Entity
~~~dart
class Company extends Entity {
  late final Field<DateTime> name = field('name');
  late final Field<DateTime> time = field('time');
  late final Field<int> capacity = field('capacity');
  late final Field<double> kpi = field('kpi');
  late final ListField<Machine> machines = fieldList('machines');
  late final Field<Settings> settings = field('settings');
  late final Field<PlanQuality> planQuality = field('planQuality');

  Company() {
    print('Company constructor');
    capacity.computed(
      bindings: [machines],
      compute: () => machines.fold(0, (p, e) => p! + e.capacity()),
    );
    machines.register(() => Machine());
    settings.register(() => Settings(), auto: true);
    print('End of Company constructor');
  }
}

class Machine extends Entity {
  late final Field<String> name = field('name');
  late final Field<int> capacity = field('capacity');
}

class Settings extends Entity {
  late final Field<int> minCapacity =
      field('minCapacity', defaultValue: 10);
}

class PlanQuality extends Entity {}
~~~

## API Connect

### Unauthorized handler (401 error)
~~~dart
 App.connect.addUnauthorizedResponseHandler((response) async {
    await App.dialog(
      description: 'Your login session may have expired. Please re-login again.',
      title: 'Unauthorized',
      barrierDismissible: true,
    );
    App.identity.signOut();
  });
~~~

### Quick REST API Access
~~~dart
final result = await '/api/login'.api(body: request.data).post(
        timeout: Duration(seconds: 5),
        headers: {"AppToken": request["appToken"]});
~~~
By default it will connect via the **App.connect**. You may override it for external api.
~~~dart
final response = await 'https://oauth2.googleapis.com/token'
          .api(body: {
            'code': code,
            'client_id': clientID,
            'client_secret': clientSecret,
            'redirect_uri': redirectUri,
            'grant_type': 'authorization_code',
          })
          .external() // Indicate this is an external API
          .post();
~~~
### Quick GraphQL API Access
~~~dart
final result = await 'register'
        .gql([
          'customerId'
        ], params: {
          'input:RegisterCustomerInput': {
            'name': name.value,
            'email': email.value,
            'password': password.value
          }
        })
        .mutation();
~~~