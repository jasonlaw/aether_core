## 0.7.1
* Default rest call with json content type

## 0.7.0
* AppSettings baseUrl will follow the hosting environment in production
* Added extension gqlFr to simplify defination of fragment
* Move CredentialActions to CredentialService
* Bumped dio to 5.0.0, which may introduce some breaking changes
* Temp fixed the cookie_mgr bug locally

## 0.6.5
* Fixed XFileImage deprecated issue

## 0.6.4
* New Launcher API to open external app for upgrader

## 0.6.3
* Fixed dio upload multipart issue

## 0.6.2
* Added Response.noContent (StatusCode == 204)

## 0.6.1
* Fixed response error message
* Added Dio debug mode simple logging

## 0.6.0
* Connectivity status
* Replace GetStorage with Hive
* Replace GetConnect with Dio

## 0.5.4
* Added Field<MediaFile> as default gql field

## 0.5.3
* Added text input filtering for money input
* Added text input filtering for profanity censor
* Added quick api map.asFormData extensions

## 0.5.2
* Enum checking is not working in web release mode, workaround with EnumSafeType

## 0.5.1
* Support gql enum 

## 0.5.0
* Flutter 3.0

## 0.4.5
* Rollback the entity field default instance changes

## 0.4.4
* Fixed AppSettings issue
* Make entity field default instance true

## 0.4.3
* Fixed gql query typo

## 0.4.2
* Credential actions error handling issue

## 0.4.1
* Credential actions

## 0.4.0
* Introduce AppBuilder

## 0.3.9
* Upgrade url_launcher, custom safeLaunchUrl

## 0.3.8
* Added AppTranslations

## 0.3.7
* Fixed app_theme bug

## 0.3.6
* Fixed upload media file bug

## 0.3.5
* Renamed: AppService.init and App.config

## 0.3.4
* Rework on App.dialog and notification

## 0.3.3
* Add url to MediaFile model

## 0.3.2
* Refactoring and rework the App init setup
* EntitySearch api call

## 0.3.1
* Added App credential callback actions

## 0.3.0
* Use cross platform XFile in MediaFile

## 0.2.9
* Added crypto (checkSum) support
* Refresh token with checkSum

## 0.2.8
* Added entity onLoaded callback function

## 0.2.7
* Added x-refresh-token storage

## 0.2.6
* Added post-token for post api request

## 0.2.5
* Added methods to ListField: lastOrDefault, firstWhereOrDefault.

## 0.2.4
* Added ListField.rxEx, which will listening to list activity only. Changes from its children entity will be ignored.

## 0.2.3
* Update getx version to 4.5.1

## 0.2.2
* Improved the Upgrader checking
