# godot-appodeal-3.2.1
Appodeal SDK 3.2.1 Android plugin for Godot. Built on Godot 3.5.3 artifact.

## Setup

Grab the``GodotAppodeal`` plugin binary (.aar) and config (.gdap) from the releases page and put both into res://android/plugins. For easy start, you can also use my GodotAppodeal.gd script (it's very well documented).

Make sure to open your Godot project, go to Project -> Settings and add a new "Appodeal/AppKey" property (String). Store your Appodeal AppKey inside this property and reference it via ProjectSettings.get_setting("Appodeal/AppKey").

Add to ``res://android/build/build.gradle`` in ``android -> defaultConfig``:
```
multiDexEnabled true
```
In the same file, add implementation 'androidx.multidex:multidex:2.0.1' to your dependencies:
```
dependencies {
    implementation libraries.kotlinStdLib
    implementation libraries.androidxFragment
    implementation 'androidx.multidex:multidex:2.0.1'
```

### AD-Id permission

It's mandatory to have the com.google.android.gms.ads.APPLICATION_ID permission in your AndroidManifest.xml for ad networks to obtain the AdID of the device. Without this permission advertising SDKs can't operate and will cause crashes, so add the following permission to your project's AndroidManifest.xml:

```xml
<uses-permission android:name="com.google.android.gms.permission.AD_ID"/>
```

Make sure to add it between `<!--CHUNK_USER_PERMISSIONS_BEGIN-->` and `<!--CHUNK_USER_PERMISSIONS_END-->` comments so it won't get deleted by Godot on export.

### AdMob

If you use AdMob, add meta-data to AndroidManifest.xml in ``<application></application>``:
```xml
<!-- AdMob -->
        <meta-data
            android:name="com.google.android.gms.ads.APPLICATION_ID"
            android:value="YOUR_ADMOB_APP_ID"/>
```

WARNING! If you include AdMob adapter into your build (see "Customizing ad adapters" below) but you don't provide a valid AdMob App ID into your AndroidManifest, your project will crash due to AdMob's unavailability to initialize. Your logcat would have messages like this:
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

Solution #1: Disable the all adapters that require Admob app ID.

In order to do that:
1. Open the GDAP file of the plugin and leave empty braces in the "remote" property (so it would look like remote=[])
2. Open the build.gradle file and inside your dependencies list add the following:
```
    implementation ('com.appodeal.ads:sdk:3.2.1.+') {
        exclude group: 'com.appodeal.ads.sdk.networks', module: 'admob' // Uses Google Ads ID
        exclude group: 'com.appodeal.ads.sdk.networks', module: 'bidmachine' // Uses Google Ads ID
        exclude group: 'com.appodeal.ads.sdk.networks', module: 'bigo_ads' // Uses Google Ads ID
        exclude group: 'com.appodeal.ads.sdk.networks', module: 'bidon' // Uses Google Ads ID
    }
```

Solution #2: Provide a valid (or [testing](https://developers.google.com/admob/android/quick-start#import_the_mobile_ads_sdk)) Admob app ID.

## Usage

Add the GodotAppodeal.gd as an Autoload to your project and use it's methods, they are all well commented.

### Initialization

Appodeal has to be initialized via initialize(appKey, adTypes) method.

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

## Changelog
Appodeal SDK 3.2.1: removed deprecated methods from both the bridge and the .gd script

Appodeal SDK 3.0.2: updated dependencies, bumped compileSdk to level 32


Added VAST and MRAID adapters to GDAP example (for some reason ads.sdk.core doesn't contain those adapters). Also added Sentry Analytics and Stack Analytics.

Appodeal SDK 3.0.1: added AdRevenueCallback for custom project analytics. In your Godot project you can receive RevenueInfo from this callback via adRevenueReceived(revenueInfo:Dictionary) implemented in GodotAppodeal.gd
Contents and meaning of the dictionary can be found [here](https://wiki.appodeal.com/en/android/get-started/advanced/ad-revenue-callbacks) or in GodotAppodeal.gd.
