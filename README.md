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

Make sure to add it between <!--CHUNK_USER_PERMISSIONS_BEGIN--> and <!--CHUNK_USER_PERMISSIONS_END--> comments so it won't get deleted by Godot on export.

### AdMob

If you use AdMob, add meta-data to AndroidManifest.xml in ``<application></application>``:
```xml
<!-- AdMob -->
        <meta-data
            android:name="com.google.android.gms.ads.APPLICATION_ID"
            android:value="YOUR_ADMOB_APP_ID"/>
```

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