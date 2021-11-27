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
await AppService.startup(); 
~~~

### Notification services
~~~dart
// Customization
App.custom.info(Future<void> Function(String info, {String? title}) notifyInfo)
App.custom.confirm(Future<bool> Function(String question, {String? title, String? okButtonTitle, String? cancelButtonTitle})
App.custom.error(Future<void> Function(dynamic error, {String? title}) notifyError)
App.custom.progressIndicator(void Function(EasyLoading easyLoading) configure)

// Call the service
App.info(String info, {String? title})
App.confirm(String question, {String? title, String? okButtonTitle, String? cancelButtonTitle})
App.error(dynamic error, {String? title})

App.showProgressIndicator({String? status})
App.dismissProgressIndicator()
~~~

### Unauthorized handler (401 error)
~~~dart
 App.connect.addUnauthorizedResponseHandler((response) async {
    await App.error(
      'Your login session may have expired. Please re-login again.',
      title: 'Unauthorized',
    );
    App.identity.signOut();
  });
~~~

## Entity
~~~dart
class Company extends Entity {
  late final Field<DateTime> name = this.field('name');
  late final Field<DateTime> time = this.field('time');
  late final Field<int> capacity = this.field('capacity');
  late final Field<double> kpi = this.field('kpi');
  late final ListField<Machine> machines = this.fieldList('machines');
  late final Field<Settings> settings = this.field('settings');
  late final Field<PlanQuality> planQuality = this.field('planQuality');

  Company() {
    print('Company constructor');
    this.capacity.computed(
      bindings: [machines],
      compute: () => machines.fold(0, (p, e) => p! + e.capacity()),
    );
    this.machines.register(() => Machine());
    this.settings.register(() => Settings(), auto: true);
    print('End of Company constructor');
  }
}

class Machine extends Entity {
  late final Field<String> name = this.field('name');
  late final Field<int> capacity = this.field('capacity');
}

class Settings extends Entity {
  late final Field<int> minCapacity =
      this.field('minCapacity', defaultValue: 10);
}

class PlanQuality extends Entity {}
~~~

## API Connect
### Quick REST PI Access
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
