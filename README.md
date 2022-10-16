# godot-appodeal-3.x.x
Appodeal SDK 3.0.0 Android plugin for Godot.

## Setup

Grab the``GodotAppodeal`` plugin binary (.aar) and config (.gdap) from the releases page and put both into res://android/plugins. For easy start, you can also use my GodotAppodeal.gd script (it's very well documented).

Make sure to open your Godot project, go to Project -> Settings and add a new "Appodeal/AppKey" property (String). Store your Appodeal AppKey inside this property and reference it via ProjectSettings.get_setting("Appodeal/AppKey").

Add to ``res://android/build/build.gradle`` in ``android -> defaultConfig``:
```
multiDexEnabled true
```
By default, the plugin uses all Appodeal dependencies and this should be just fine for most projects. If you want to cherry-pick your ad adapters, you should use the [Get Started Wizard](https://wiki.appodeal.com/en/android-beta-3-0-0/get-started) and change the dependencies in ``GodotAppodeal.gdap``.

It's recommended to follow other instructions from the Get Started page and tweak some parts of your Godot project's AndroidManifest.xml.

### AD-Id permission

It's mandatory to have the com.google.android.gms.ads.APPLICATION_ID permission in your AndroidManifest.xml for ad networks to obtain the AdID of the device. Without this permission advertising SDKs can't operate and will cause crashes, so add the following permission to your project's AndroidManifest.xml:

```xml
<uses-permission android:name="com.google.android.gms.permission.AD_ID"/>
```

### AdMob

If you use AdMob, add meta-data to AndroidManifest.xml in ``<application></application>``:
```xml
<!-- AdMob -->
        <meta-data
            android:name="com.google.android.gms.ads.APPLICATION_ID"
            android:value="YOUR_ADMOB_APP_ID"/>
```

WARNING! If you include AdMob adapter into your build (see "Customizing ad adapters" below) but you don't provide a valid AdMob App ID into your AndroidManifest, your project will crash due to AdMob's inavailability to initialize. Your logcat would have messages like this:
```
******************************************************************************
* The Google Mobile Ads SDK was initialized incorrectly. AdMob publishers    *
* should follow the instructions here:                                       *
* https://googlemobileadssdk.page.link/admob-android-update-manifest         *
* to add a valid App ID inside the AndroidManifest.                          *
* Google Ad Manager publishers should follow instructions here:              *
* https://googlemobileadssdk.page.link/ad-manager-android-update-manifest.   *
******************************************************************************
```

How to fix it:
- Solution #1: Disable the AdMob adapter
- Solution #2: Provide a valid (or [testing](https://developers.google.com/admob/android/quick-start#import_the_mobile_ads_sdk)) Admob app ID.

### Customizing ad adapters

You can customize what ad network adapters and services are going to be included into your game via editing GodotAppodeal.gdap settings file. By default, the plugin will use all Appodeal adapters and dependencies:
```
[config]

name="GodotAppodeal"
binary_type="local"
binary="GodotAppodeal.3.0.0.release.aar"

[dependencies]

remote=["com.appodeal.ads:sdk:3.0.0.+"]
custom_maven_repos=["https://artifactory.appodeal.com/appodeal"]
```

This is equal to the following:
```
[config]

name="GodotAppodeal"
binary_type="local"
binary="GodotAppodeal.3.0.0.release.aar"

[dependencies]

remote=[
"com.appodeal.ads.sdk:core:3.0.0",
"com.appodeal.ads.sdk.networks:adcolony:3.0.0.2",
"com.appodeal.ads.sdk.networks:admob:3.0.0.1",
"com.appodeal.ads.sdk.networks:applovin:3.0.0.1",
"com.appodeal.ads.sdk.networks:bidmachine:3.0.0.2",
"com.appodeal.ads.sdk.networks:facebook:3.0.0.2",
"com.appodeal.ads.sdk.networks:ironsource:3.0.0.1",
"com.appodeal.ads.sdk.networks:my_target:3.0.0.2",
"com.appodeal.ads.sdk.networks:unity_ads:3.0.0.0",
"com.appodeal.ads.sdk.networks:vungle:3.0.0.2",
"com.appodeal.ads.sdk.networks:yandex:3.0.0.1",
"com.appodeal.ads.sdk.services:adjust:3.0.0.0",
"com.appodeal.ads.sdk.services:appsflyer:3.0.0.1",
"com.appodeal.ads.sdk.services:firebase:3.0.0.0",
"com.appodeal.ads.sdk.services:facebook_analytics:3.0.0.1",
]
custom_maven_repos=["https://artifactory.appodeal.com/appodeal"]
```

In order to remove an adapter or service from the plugin, simply delete the line responsible for it from the above. Here is an example of how to remove AdMob network:
```
[config]

name="GodotAppodeal"
binary_type="local"
binary="GodotAppodeal.3.0.0.release.aar"

[dependencies]

remote=[
"com.appodeal.ads.sdk:core:3.0.0",
"com.appodeal.ads.sdk.networks:adcolony:3.0.0.2	",
"com.appodeal.ads.sdk.networks:applovin:3.0.0.1	",
"com.appodeal.ads.sdk.networks:bidmachine:3.0.0.2",
"com.appodeal.ads.sdk.networks:facebook:3.0.0.2",
"com.appodeal.ads.sdk.networks:ironsource:3.0.0.1",
"com.appodeal.ads.sdk.networks:my_target:3.0.0.2",
"com.appodeal.ads.sdk.networks:unity_ads:3.0.0.0",
"com.appodeal.ads.sdk.networks:vungle:3.0.0.2",
"com.appodeal.ads.sdk.networks:yandex:3.0.0.1",
"com.appodeal.ads.sdk.services:adjust:3.0.0.0",
"com.appodeal.ads.sdk.services:appsflyer:3.0.0.1",
"com.appodeal.ads.sdk.services:firebase:3.0.0.0",
"com.appodeal.ads.sdk.services:facebook_analytics:3.0.0.1",
]
custom_maven_repos=["https://artifactory.appodeal.com/appodeal"]
```

The entire Appodeal SDK dependencies content can be found [here](https://wiki.appodeal.com/en/android-beta-3-0-0/get-started/advanced/sdk-content). Make sure to keep it up to date if you customize your adapters list.

## Usage

Add the GodotAppodeal.gd as an Autoload to your project and use it's methods, they are all well commented.

### Initialization

Appodeal has to be initialized via initialize(appKey, adTypes) method. If you don't provide CCPA/GDPR consent status before calling initialize(), Appodeal SDK will summon their Consent Manager when required.

### Ad Types

The adTypes parameter in the code is responsible for the ad formats you are going to implement into your app. An enum is defined in GodotAppodeal.gd for those.
```gdscript
enum AdType {
  INTERSTITIAL = 1,
  BANNER = 2,
  NATIVE = 4,
  REWARDED_VIDEO = 8,
  NON_SKIPPABLE_VIDEO = 16,
}
```
Ad types can be combined using "|" operator, e.g. initialize(appKey, AdType.INTERSTITIAL | AdType.REWARDED_VIDEO).

### Show Styles

The showStyles parameter use for show ad. An enum is defined in GodotAppodeal.gd for those.
```gdscript
enum ShowStyle {
  INTERSTITIAL = 1,
  BANNER_TOP = 2,
  BANNER_BOTTOM = 4,
  REWARDED_VIDEO = 8,
  NON_SKIPPABLE_VIDEO = 16,
}
```

## Building

If you want to rebuild the plugin, just run ``.\gradlew build`` from plugin project root directory. Make sure to provide actual Godot build template (godot-lib.release.aar) for the engine version you are using at ``godotappodeal\libs`` folder.