# Godot Appodeal 3.3.2
[![Godot](https://img.shields.io/badge/Godot%20Engine-3.6-blue?style=for-the-badge&logo=godotengine&logoSize=auto)
](https://godotengine.org/)
[![Appodeal](https://img.shields.io/badge/Appodeal_3.3.2-red?style=for-the-badge&logoSize=auto)
](https://appodeal.com/)
![GitHub License](https://img.shields.io/github/license/damnedpie/godot-appodeal?style=for-the-badge)
![GitHub Repo stars](https://img.shields.io/github/stars/damnedpie/godot-appodeal?style=for-the-badge&logo=github&logoSize=auto&color=%23FFD700)

Appodeal SDK 3.3.2 Android plugin for Godot. Built on Godot 3.6 AAR.

## Setup

### Project integration

Grab the``GodotAppodeal`` plugin binary (.aar) and config (.gdap) from the releases page and put both into ``res://android/plugins``. For easy start, you can also use my ``GodotAppodeal.gd`` script (it's very well documented).

Make sure to open your Godot project, go to Project -> Settings and add a new ``"Appodeal/AppKey" property (String)``. Store your Appodeal AppKey inside this property and reference it via ``ProjectSettings.get_setting("Appodeal/AppKey")``.

Add to ``res://android/build/build.gradle`` in ``android -> defaultConfig``:
```groovy
multiDexEnabled true
```
In the same file, add implementation 'androidx.multidex:multidex:2.0.1' to your dependencies:
```groovy
dependencies {
    implementation "androidx.fragment:fragment:$versions.fragmentVersion"
    implementation 'androidx.multidex:multidex:2.0.1'
```

### AD-ID permission

It's mandatory to have the ``com.google.android.gms.ads.AD_ID`` permission in your ``AndroidManifest.xml`` for ad networks to obtain the AdID of the device. Without this permission advertising SDKs can't operate and will cause crashes, so add the following permission to your project's ``AndroidManifest.xml``:

```xml
<uses-permission android:name="com.google.android.gms.permission.AD_ID"/>
```

Make sure to add it between `<!--CHUNK_USER_PERMISSIONS_BEGIN-->` and `<!--CHUNK_USER_PERMISSIONS_END-->` comments so it won't get deleted by Godot on export.

### AdMob

If you use AdMob, add meta-data to ``AndroidManifest.xml`` in ``<application></application>``:
```xml
<!-- AdMob -->
        <meta-data
            android:name="com.google.android.gms.ads.APPLICATION_ID"
            android:value="YOUR_ADMOB_APP_ID"/>
```

If you don't provide AdMob App ID, the SDK will crash with the following in your logcat:
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

In the past, it was possible to disable some ad network adapters that used AdMob in case you didn't have a valid ID. Now, however, it's basically pointless, because you'd have to disable almost all adapters rendering the integration useless.

Now the only solution to this is providing an ID. If you don't have an AdMob account, you can (at least for testing) use a test ID, like demonstrated [here](https://developers.google.com/admob/android/quick-start#import_the_mobile_ads_sdk). I don't know how safe is it to use in production though.

## Usage

Add the ``GodotAppodeal.gd`` as an Autoload to your project and use its methods, they are all well commented.

### Initialization

Appodeal has to be initialized via ``initialize(appKey, adTypes)`` method.

### Ad Types

The adTypes parameter in the code is responsible for the ad formats you are going to implement into your app. An enum is defined in ``GodotAppodeal.gd`` for those.
```gdscript
# These flags are used for initialization and can be combined with | operator
enum AdType {
	NONE = 0, # 0b0000_0000_0000
	INTERSTITIAL = 3, # 0b0000_0000_0011
	BANNER = 4, # 0b0000_0000_0100
	REWARDED_VIDEO = 128, #0b0000_1000_0000
	NATIVE = 512, # 0b0010_0000_0000 not implemented in the plugin
	MREC = 256, # 0b0001_0000_0000
}
```
Ad types can be combined using "|" operator like this: ``initialize(appKey, AdType.INTERSTITIAL | AdType.REWARDED_VIDEO)``.

### Show Styles

The showStyle parameter is responsible for the form in which the ad will be served. An enum is defined in ``GodotAppodeal.gd`` for those.
```gdscript
enum ShowStyle {
	INTERSTITIAL = 3, # 0b0000_0000_0011
	BANNER_BOTTOM = 8, # 0b0000_0000_1000
	BANNER_TOP = 16, # 0b0000_0001_0000
	BANNER_LEFT = 1024, # 0b0100_0000_0000
	BANNER_RIGHT = 2048, # 0b1000_0000_0000
	BANNER_VIEW = 64, # 0b0000_0100_0000 im not sure what this is so it's not implemented
	REWARDED_VIDEO = 128, # 0b0000_1000_0000
	MREC = 256, # 0b0001_0000_0000
	NATIVE = 512, # 0b0010_0000_0000 not implemented in the plugin
}
```

### Advanced IAP reporting

If you need to use the advanced IAP logging and validation mechanism (details [here](https://docs.appodeal.com/android/advanced/in-app-purchases)), this plugin has a method to do it. Please note, however, that the official Godot Google Play Billing plugin's returned Purchase dictionary lacks a property that is required by Appodeal and the MMPs that the IAPs are reported to. In order to fix this, go to [this class](https://github.com/godotengine/godot-google-play-billing/blob/master/godot-google-play-billing/src/main/java/org/godotengine/godot/plugin/googleplaybilling/utils/GooglePlayBillingUtils.java) of the Billing plugin and change this method to look like this, then build the plugin:

```java
public class GooglePlayBillingUtils {
    public static Dictionary convertPurchaseToDictionary(Purchase purchase) {
        Dictionary dictionary = new Dictionary();
        dictionary.put("original_json", purchase.getOriginalJson());
        dictionary.put("order_id", purchase.getOrderId());
        dictionary.put("package_name", purchase.getPackageName());
        dictionary.put("purchase_state", purchase.getPurchaseState());
        dictionary.put("purchase_time", purchase.getPurchaseTime());
        dictionary.put("purchase_token", purchase.getPurchaseToken());
        dictionary.put("quantity", purchase.getQuantity());
        dictionary.put("signature", purchase.getSignature());
        dictionary.put("developer_payload", purchase.getDeveloperPayload()); // Add this!
        ArrayList<String> skus = purchase.getSkus();
        dictionary.put("sku", skus.get(0));
        String[] skusArray = skus.toArray(new String[0]);
        dictionary.put("skus", skusArray);
        dictionary.put("is_acknowledged", purchase.isAcknowledged());
        dictionary.put("is_auto_renewing", purchase.isAutoRenewing());
        return dictionary;
    }
    // The rest of the class remains intact
}
```

Now you should be good to go and use the ``validateIAP()`` method in the ``GodotAppodeal.gd``; the method is commented with instructions on how to form the dictionary that will get passed into Appodeal SDK, so make sure you read it. Just grab all the required data from GodotGooglePlayBilling's returned ``Purchase`` dictionary (which you get in the ``purchases_updated`` callback of the Billing plugin) and pass it through Appodeal plugin's ``validateIAP()`` method.

### MREC banners

Note: I haven't used MREC ads in my production games as of yet. I only tested MRECs with testing mode enabled in SDK settings.

In order to use MRECs, you need to initialize the SDK with ``AdType.MREC`` flag. Then, you need to call ``createLayoutForMREC()`` to get the layout for displaying MRECs created. You should only do this once per app run.

Just like with plain banners, it's best to use autocaching with MRECs. To show a MREC, simply call ``showAd(ShowStyle.MREC)``. You can hide MRECs by calling ``hideMREC()``.

## Building

If you want to rebuild the plugin, just run ``.\gradlew build`` from plugin project root directory. Make sure to provide actual Godot build template ``(godot-lib.release.aar)`` for the engine version you are using at ``godotappodeal\libs`` folder.

