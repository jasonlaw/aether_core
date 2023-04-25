![](https://raw.githubusercontent.com/jasonlaw/aether-resources/master/Aether.png)

[![Pub release](https://img.shields.io/pub/v/aether_core.svg?label=aether_core&color=blue)](https://pub.dev/packages/aether_core) [![GitHub Release Date](https://img.shields.io/github/release-date/jasonlaw/aether_core.svg)](https://github.com/jasonlaw/aether_core)

# aether_core

Aether Core for Flutter
    
    Aether Core is a comprehensive application framework designed specifically for Flutter development. It offers a range of features that can help developers streamline their workflow, including a simplified ORM for managing entities, context-less routing based on the popular Getx package, and built-in support for authentication management within the context.
    
    In addition to these features, Aether Core also includes streamlined integration of dialogs and snackbars, making it easy for developers to add these common UI elements to their applications. It also provides seamless integration with the DIO package, allowing developers to easily make REST or GraphQL calls.
    
    Overall, Aether Core is a powerful and flexible framework that can help developers create high-quality Flutter applications with ease. By simplifying many of the common tasks involved in application development, it can help developers save time and focus on building out the core functionality of their applications.  

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

## Building App Service
Before RunApp, build the AppService via AppBuilder.
~~~dart
final builder = AppBuilder(appName: 'VIQ Community Admin');

// Customize the credential actions
// Extends AppCredential 
class CustomAppCredential extends AppCredential {
    ...
}
builder.useAppCredential( CustomAppCredential() );

// Customize dialog settings
// Extends AppDialog
class CustomAppDialog extends AppDialog {
    ...
}
builder.useAppDialog( CustomAppDialog() );

// Build the app service
await builder.build();
~~~

### Dialog, Snackbar and Progress indicator
~~~dart
// Dialog
App.dialog.show({String? title, 
            String? description, 
            String? cancelTitle, 
            Color? cancelTitleColor, 
            String? buttonTitle, 
            Color? buttonTitleColor,  
            bool barrierDismissible = false, 
            DialogPlatform? dialogPlatform})
            
App.dialog.showConfirm(String question, 
            {String? title, 
             String? buttonTitle, 
             String? cancelButtonTitle})

// Notification
App.dialog.showInfo(String info, {String? title})
App.dialog.showError(dynamic error, {String? title})

// Progress indicator
App.showProgressIndicator({String? status})
App.dismissProgressIndicator()
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

### Quick REST API Access
~~~dart
final result = await '/api/login'.api(body: request.data).post(
        timeout: Duration(seconds: 5),
        headers: {"AppToken": request["appToken"]});
~~~
By default it will connect via the **App.api**. You may override it for external api.
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
 'community'
        .gql([...data.fragment, 'location'.gql(Location().fragment)],
            params: {'id': communityId})
        .query()
        .then((response) {
          if (response.hasError) {
            App.error(response.errorText);
            return;
          }
          if (response.isOk) {
            data.load(response.body);
          }
        });
~~~