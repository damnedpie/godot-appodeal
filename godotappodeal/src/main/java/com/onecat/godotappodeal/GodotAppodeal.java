package com.onecat.godotappodeal;

import android.app.Activity;
import android.view.View;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.HashSet;
import java.util.HashMap;
import java.util.List;
import java.util.Set;
import java.util.Map;

import com.appodeal.ads.Appodeal;
import com.appodeal.ads.AppodealServices;
import com.appodeal.ads.BannerCallbacks;
import com.appodeal.ads.InterstitialCallbacks;
import com.appodeal.ads.MrecCallbacks;
import com.appodeal.ads.MrecView;
import com.appodeal.ads.RewardedVideoCallbacks;
import com.appodeal.ads.inapp.InAppPurchase;
import com.appodeal.ads.inapp.InAppPurchaseValidateCallback;
import com.appodeal.ads.rewarded.Reward;
import com.appodeal.ads.initializing.ApdInitializationCallback;
import com.appodeal.ads.initializing.ApdInitializationError;
import com.appodeal.ads.revenue.AdRevenueCallbacks;
import com.appodeal.ads.revenue.RevenueInfo;
import com.appodeal.ads.service.ServiceError;
import com.appodeal.ads.utils.Log;

import org.godotengine.godot.Dictionary;
import org.godotengine.godot.Godot;
import org.godotengine.godot.plugin.GodotPlugin;
import org.godotengine.godot.plugin.SignalInfo;
import org.godotengine.godot.plugin.UsedByGodot;

@SuppressWarnings({"unused", "SpellCheckingInspection"})
public class GodotAppodeal extends GodotPlugin {
    private Activity activity;
    private FrameLayout layout = null;
    private MrecView mrecView = null;

    public GodotAppodeal(Godot godot) {
        super(godot);
        activity = getActivity();
    }

    @Nullable
    @Override
    public View onMainCreate(Activity activity) {
        layout = new FrameLayout(activity);
        return layout;
    }

    @Override
    public void onMainDestroy() {
        destroyAllAdTypes();
        super.onMainDestroy();
    }

    @NonNull
    @Override
    public String getPluginName() {
        return "GodotAppodeal";
    }

    @NonNull
    @Override
    public Set<SignalInfo> getPluginSignals() {
        Set<SignalInfo> signalInfoSet = new HashSet<>();
        // Interstitial
        signalInfoSet.add(new SignalInfo("interstitial_loaded", Boolean.class));
        signalInfoSet.add(new SignalInfo("interstitial_load_failed"));
        signalInfoSet.add(new SignalInfo("interstitial_show_failed"));
        signalInfoSet.add(new SignalInfo("interstitial_shown"));
        signalInfoSet.add(new SignalInfo("interstitial_closed"));
        signalInfoSet.add(new SignalInfo("interstitial_clicked"));
        signalInfoSet.add(new SignalInfo("interstitial_expired"));
        // Banner
        signalInfoSet.add(new SignalInfo("banner_loaded", Integer.class, Boolean.class));
        signalInfoSet.add(new SignalInfo("banner_load_failed"));
        signalInfoSet.add(new SignalInfo("banner_shown"));
        signalInfoSet.add(new SignalInfo("banner_show_failed"));
        signalInfoSet.add(new SignalInfo("banner_clicked"));
        signalInfoSet.add(new SignalInfo("banner_expired"));
        // Rewarded video
        signalInfoSet.add(new SignalInfo("rewarded_video_loaded", Boolean.class));
        signalInfoSet.add(new SignalInfo("rewarded_video_load_failed"));
        signalInfoSet.add(new SignalInfo("rewarded_video_shown"));
        signalInfoSet.add(new SignalInfo("rewarded_video_show_failed"));
        signalInfoSet.add(new SignalInfo("rewarded_video_clicked"));
        signalInfoSet.add(new SignalInfo("rewarded_video_finished", Double.class, String.class));
        signalInfoSet.add(new SignalInfo("rewarded_video_closed", Boolean.class));
        signalInfoSet.add(new SignalInfo("rewarded_video_expired"));
        // MREC
        signalInfoSet.add(new SignalInfo("mrec_loaded", Boolean.class));
        signalInfoSet.add(new SignalInfo("mrec_load_failed"));
        signalInfoSet.add(new SignalInfo("mrec_shown"));
        signalInfoSet.add(new SignalInfo("mrec_show_failed"));
        signalInfoSet.add(new SignalInfo("mrec_clicked"));
        signalInfoSet.add(new SignalInfo("mrec_expired"));
        // Other
        signalInfoSet.add(new SignalInfo("initialization_finished", String.class));
        signalInfoSet.add(new SignalInfo("ad_revenue_received", Dictionary.class));
        signalInfoSet.add(new SignalInfo("iap_validate_success", String.class));
        signalInfoSet.add(new SignalInfo("iap_validate_failed", String.class));
        return  signalInfoSet;
    }

    private int getAdType(int value) {
        int res = Appodeal.NONE;
        if((value&Appodeal.INTERSTITIAL) != 0) { res |= Appodeal.INTERSTITIAL; }
        if((value&Appodeal.BANNER) != 0) { res |= Appodeal.BANNER; }
        if((value&Appodeal.NATIVE) != 0) { res |= Appodeal.NATIVE; }
        if((value&Appodeal.REWARDED_VIDEO) != 0) { res |= Appodeal.REWARDED_VIDEO; }
        if((value&Appodeal.MREC) != 0) { res |= Appodeal.MREC; }
        return res;
    }

    private int getShowStyle(int value) {
        int res = Appodeal.NONE;
        if((value&Appodeal.INTERSTITIAL) != 0) { return Appodeal.INTERSTITIAL; }
        if((value&Appodeal.BANNER_TOP) != 0) { return Appodeal.BANNER_TOP; }
        if((value&Appodeal.BANNER_BOTTOM) != 0) { return Appodeal.BANNER_BOTTOM; }
        if((value&Appodeal.BANNER_LEFT) != 0) { return Appodeal.BANNER_LEFT; }
        if((value&Appodeal.BANNER_RIGHT) != 0) { return Appodeal.BANNER_RIGHT; }
        if((value&Appodeal.REWARDED_VIDEO) != 0) { return Appodeal.REWARDED_VIDEO; }
        if((value&Appodeal.MREC) != 0) { return Appodeal.MREC; }
        return res;
    }

    private void setCallbacks(int types) {
        if((types&Appodeal.INTERSTITIAL) != 0) {
            Appodeal.setInterstitialCallbacks(new InterstitialCallbacks() {
                @Override
                public void onInterstitialLoaded(boolean b) { emitSignal("interstitial_loaded", b); }

                @Override
                public void onInterstitialFailedToLoad() {
                    emitSignal("interstitial_load_failed");
                }

                @Override
                public void onInterstitialShown() {
                    emitSignal("interstitial_shown");
                }

                @Override
                public void onInterstitialShowFailed() {
                    emitSignal("interstitial_show_failed");
                }

                @Override
                public void onInterstitialClicked() {
                    emitSignal("interstitial_clicked");
                }

                @Override
                public void onInterstitialClosed() {
                    emitSignal("interstitial_closed");
                }

                @Override
                public void onInterstitialExpired() {
                    emitSignal("interstitial_expired");
                }
            });
        }
        if((types&Appodeal.BANNER) != 0) {
            Appodeal.setBannerCallbacks(new BannerCallbacks() {
                @Override
                public void onBannerLoaded(int hDpi, boolean b) {
                    emitSignal("banner_loaded", hDpi, b);
                }

                @Override
                public void onBannerFailedToLoad() {
                    emitSignal("banner_load_failed");
                }

                @Override
                public void onBannerShown() {
                    emitSignal("banner_shown");
                }

                @Override
                public void onBannerShowFailed() {
                    emitSignal("banner_show_failed");
                }

                @Override
                public void onBannerClicked() {
                    emitSignal("banner_clicked");
                }

                @Override
                public void onBannerExpired() {
                    emitSignal("banner_expired");
                }
            });
        }
        if((types&Appodeal.REWARDED_VIDEO) != 0) {
            Appodeal.setRewardedVideoCallbacks(new RewardedVideoCallbacks() {
                @Override
                public void onRewardedVideoLoaded(boolean b) { emitSignal("rewarded_video_loaded", b); }

                @Override
                public void onRewardedVideoFailedToLoad() { emitSignal("rewarded_video_load_failed"); }

                @Override
                public void onRewardedVideoShown() {
                    emitSignal("rewarded_video_shown");
                }

                @Override
                public void onRewardedVideoShowFailed() { emitSignal("rewarded_video_show_failed"); }

                @Override
                public void onRewardedVideoFinished(double v, String s) { emitSignal("rewarded_video_finished", v, String.valueOf(s)); }

                @Override
                public void onRewardedVideoClosed(boolean b) { emitSignal("rewarded_video_closed", b); }

                @Override
                public void onRewardedVideoExpired() {
                    emitSignal("rewarded_video_expired");
                }

                @Override
                public void onRewardedVideoClicked() {
                    emitSignal("rewarded_video_clicked");
                }
            });
        }
        if((types&Appodeal.MREC) != 0) {
            Appodeal.setMrecCallbacks(new MrecCallbacks() {
                @Override
                public void onMrecExpired() { emitSignal("mrec_expired"); }

                @Override
                public void onMrecShowFailed() { emitSignal("mrec_show_failed"); }

                @Override
                public void onMrecShown() { emitSignal("mrec_shown"); }

                @Override
                public void onMrecFailedToLoad() { emitSignal("mrec_load_failed"); }

                @Override
                public void onMrecLoaded(boolean b) { emitSignal("mrec_loaded", b); }

                @Override
                public void onMrecClicked() { emitSignal("mrec_clicked"); }
            });
        }
        Appodeal.setAdRevenueCallbacks(new AdRevenueCallbacks() {
            @Override
            public void onAdRevenueReceive(RevenueInfo revenueInfo) {
                Dictionary godotDict = new Dictionary();
                godotDict.put("networkName", revenueInfo.getNetworkName());
                godotDict.put("demandSource", revenueInfo.getDemandSource());
                godotDict.put("adUnitName", revenueInfo.getAdUnitName());
                godotDict.put("placement", revenueInfo.getPlacement());
                godotDict.put("revenue", revenueInfo.getRevenue());
                godotDict.put("adType", revenueInfo.getAdType());
                godotDict.put("adTypeString", revenueInfo.getAdTypeString());
                godotDict.put("platform", revenueInfo.getPlatform());
                godotDict.put("currency", revenueInfo.getCurrency());
                godotDict.put("revenuePrecision", revenueInfo.getRevenuePrecision());
                emitSignal("ad_revenue_received", godotDict);
            }
        });
    }

    @UsedByGodot
    public void setTestingEnabled(boolean testing) {
        Appodeal.setTesting(testing);
    }

    @UsedByGodot
    public void disableNetworks(String[] networks) {
        for (String network : networks) {
            disableNetwork(network);
        }
    }

    @UsedByGodot
    public void disableNetwork(String network) {
        Appodeal.disableNetwork(network);
    }

    @UsedByGodot
    public double getPredictedEcpmForAdType(int adType) {
        return Appodeal.getPredictedEcpm(getAdType(adType));
    }

    @UsedByGodot
    public double getPredictedEcpmByPlacement(int adType, String placementName) {
        return Appodeal.getPredictedEcpmByPlacement(adType, placementName);
    }

    @UsedByGodot
    public void setAutocache(boolean enabled, int adType) {
        Appodeal.setAutoCache(getAdType(adType), enabled);
    }

    @UsedByGodot
    public boolean isAutocacheEnabled(int adType) {
        return Appodeal.isAutoCacheEnabled(getAdType(adType));
    }

    @UsedByGodot
    public void initialize(String appId, int adTypes) {
        int types = getAdType(adTypes);
        setCallbacks(types);
        Appodeal.initialize(
                activity,
                appId,
                types,
                new ApdInitializationCallback() {
                    @Override
                    public void onInitializationFinished(List<ApdInitializationError> list) {
                        if (list != null && !list.isEmpty()) {
                            StringBuilder message = new StringBuilder();
                            for (ApdInitializationError e : list) {
                                if (e.getMessage() != null) {
                                    message.append(" | ");
                                    message.append(e.getMessage());
                                }
                            }
                            if (message.length() == 0){
                                message = new StringBuilder("Initialization OK!");
                            }
                            emitSignal("initialization_finished", message.toString());
                        }
                        else {
                            emitSignal("initialization_finished", "Initialization OK!");
                        }
                    }
                }
        );
    }

    @UsedByGodot
    public boolean isInitializedForAdType(int adType) {
        return Appodeal.isInitialized(getAdType(adType));
    }

    @UsedByGodot //0 - none, 1 - debug, 2 - verbose
    public void setLogLevel(int level) {
        if (level == 0){
            Appodeal.setLogLevel(Log.LogLevel.none);
            return;
        }
        if (level == 1){
            Appodeal.setLogLevel(Log.LogLevel.debug);
            return;
        }
        if (level == 2){
            Appodeal.setLogLevel(Log.LogLevel.verbose);
            return;
        }
        Appodeal.setLogLevel(Log.LogLevel.none);
    }

    @UsedByGodot
    public void setExtras(Dictionary extras) {
        String[] keys = extras.get_keys();
        for (String key : keys) {
            Object val = extras.get(key);
            if (val instanceof Integer) {
                Appodeal.setExtraData(key, (int) val);
            } else if (val instanceof Double) {
                Appodeal.setExtraData(key, (double) val);
            } else if (val instanceof Boolean) {
                Appodeal.setExtraData(key, (boolean) val);
            } else if (val instanceof String) {
                Appodeal.setExtraData(key, (String) val);
            }
        }
    }

    @UsedByGodot
    public void setChildDirectedTreatment(boolean value) {
        Appodeal.setChildDirectedTreatment(value);
    }

    @UsedByGodot
    public void logEvent(String eventName, Dictionary params){
        String[] keys = params.get_keys();
        Map<String, Object> javaMap = new HashMap<>();
        for (String key : keys) {
            Object val = params.get(key);
            javaMap.put(key, val);
        }
        Appodeal.logEvent(eventName, javaMap);
    }

    @UsedByGodot
    public void setUserId(String userId) {
        Appodeal.setUserId(userId);
    }

    @UsedByGodot
    public boolean isLoaded(int adType) {
        return Appodeal.isLoaded(getAdType(adType));
    }

    @UsedByGodot
    public boolean canShow(int style) {
        return Appodeal.canShow(getShowStyle(style));
    }

    @UsedByGodot
    public boolean canShowForPlacement(int adType, String placementName) {
        return Appodeal.canShow(adType, placementName);
    }

    @UsedByGodot
    public void showAd(int style) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Appodeal.show(activity, getShowStyle(style));
            }
        });
    }

    @UsedByGodot
    public void showAdForPlacement(int style, String placementName) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Appodeal.show(activity, getShowStyle(style), placementName);
            }
        });
    }

    @UsedByGodot
    public void cacheAd(int adType) {
        Appodeal.cache(activity, getAdType(adType));
    }

    @UsedByGodot
    public boolean isPrecacheAd(int adType) {
        return Appodeal.isPrecache(getAdType(adType));
    }

    @UsedByGodot
    public boolean isPrecacheByPlacement(int adType, String placementName) {
        return Appodeal.isPrecacheByPlacement(adType, placementName);
    }

    @UsedByGodot
    public void destroy(int adType) {
        Appodeal.destroy(adType);
    }

    @UsedByGodot
    public void destroyAllAdTypes() {
        Appodeal.destroy(Appodeal.INTERSTITIAL);
        Appodeal.destroy(Appodeal.BANNER);
        Appodeal.destroy(Appodeal.NATIVE);
        Appodeal.destroy(Appodeal.REWARDED_VIDEO);
        Appodeal.destroy(Appodeal.MREC);
    }

    @UsedByGodot
    public void setSegmentFilter(Dictionary filter) {
        String[] keys = filter.get_keys();
        for (String key : keys) {
            Object val = filter.get(key);
            if (val instanceof Integer) {
                Appodeal.setCustomFilter(key, (int) val);
            } else if (val instanceof Double) {
                Appodeal.setCustomFilter(key, (double) val);
            } else if (val instanceof Boolean) {
                Appodeal.setCustomFilter(key, (boolean) val);
            } else if (val instanceof String) {
                Appodeal.setCustomFilter(key, (String) val);
            }
        }
    }

    @UsedByGodot
    public void enable728x90Banners(boolean enable) {
        Appodeal.set728x90Banners(enable);
    }

    @UsedByGodot
    public void hideBanner() {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Appodeal.hide(activity, Appodeal.BANNER);
            }
        });
    }

    @UsedByGodot
    public void setSmartBannersEnabled(boolean enabled) {
        Appodeal.setSmartBanners(enabled);
    }

    @UsedByGodot
    public void setBannerAnimationEnabled(boolean enabled) {Appodeal.setBannerAnimation(enabled);}

    @UsedByGodot
    public void setBannerRotation(int leftBannerRotation, int rightBannerRotation) {
        Appodeal.setBannerRotation(leftBannerRotation, rightBannerRotation);
    }

    @UsedByGodot
    public void createLayoutForMREC() {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                mrecView = Appodeal.getMrecView(activity);
                layout.addView(mrecView);
            }
        });
    }

    @UsedByGodot
    public void hideMREC() {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Appodeal.hide(activity, Appodeal.MREC);
            }
        });
    }

    @UsedByGodot
    public Dictionary getRewardForPlacement(String placement) {
        Reward reward = Appodeal.getReward(placement);
        Dictionary res = new Dictionary();
        res.put("currency", reward.getCurrency());
        res.put("amount", reward.getAmount());
        return res;
    }

    @UsedByGodot
    public void muteVideosIfCallsMuted(boolean mute) {
        Appodeal.muteVideosIfCallsMuted(mute);
    }

    @UsedByGodot
    public void trackInAppPurchase(double amount, String currencyCode) {
        Appodeal.trackInAppPurchase(activity.getApplicationContext(), amount, currencyCode);
    }

    @UsedByGodot
    public void validatePurchase(Dictionary purchaseDetails) {
        // Check if the dictionary is valid
        String[] requiredKeys = {
                "inappType",
                "publicKey",
                "signature",
                "purchaseData",
                "purchaseToken",
                "purchaseTimestamp",
                "developerPayload",
                "orderId",
                "sku",
                "price",
                "currency",
                //"additionalParams"
        };
        for (String requiredKey : requiredKeys) {
            if (purchaseDetails.get(requiredKey) == null) {
                return;
            }
        }

        // Check whether this is a subscription
        InAppPurchase.Type inappType = InAppPurchase.Type.InApp;
        if (purchaseDetails.get("inappType") == "subscription"){
            inappType = InAppPurchase.Type.Subs;
        }

        // Convert Godot "additionalParams" dictionary into a Map
        Map <String, String> additionalParams = new HashMap<>();
        if (purchaseDetails.get("additionalParams") != null){
            Dictionary additionalParamsDict = (Dictionary) purchaseDetails.get("additionalParams");
            String[] paramKeys = additionalParamsDict.get_keys();
            for (String paramKey : paramKeys) {
                additionalParams.put(paramKey, (String) additionalParamsDict.get(paramKey));
            }
        }

        // Create new InAppPurchase
        InAppPurchase inAppPurchase = InAppPurchase.newBuilder(inappType)
                .withPublicKey((String) purchaseDetails.get("publicKey"))
                .withSignature((String) purchaseDetails.get("signature"))
                .withPurchaseData((String) purchaseDetails.get("purchaseData"))
                .withPurchaseToken((String) purchaseDetails.get("purchaseToken"))
                .withPurchaseTimestamp(((Number)purchaseDetails.get("purchaseTimestamp")).longValue())
                .withDeveloperPayload((String) purchaseDetails.get("developerPayload"))
                .withOrderId((String) purchaseDetails.get("orderId"))
                .withSku((String) purchaseDetails.get("sku")) // Stock keeping unit id from Google API
                .withPrice((String) purchaseDetails.get("price")) // Price from Stock keeping unit
                .withCurrency((String) purchaseDetails.get("currency")) // Currency from Stock keeping unit
                .withAdditionalParams(additionalParams) // Appodeal In-app event if needed
                .build();
        // Validate InApp purchase
        Appodeal.validateInAppPurchase(activity, inAppPurchase, new InAppPurchaseValidateCallback() {
            @Override
            public void onInAppPurchaseValidateSuccess(@NonNull InAppPurchase purchase, @Nullable List<ServiceError> errors) {
                // In-App purchase validation was validated successfully by at least one connected service
                StringBuilder signalMessage = new StringBuilder();
                if (errors != null){
                    signalMessage.append(String.format("%s validated successfully", purchase.getOrderId()));
                    for(int i = 0; i < errors.size(); i++){
                        signalMessage.append(String.format("\n%s : %s", errors.get(i).getComponentName(), errors.get(i).getDescription()));
                    }
                }
                emitSignal("iap_validate_success", signalMessage.toString());
            }
            @Override
            public void onInAppPurchaseValidateFail(@NonNull InAppPurchase purchase, @NonNull List<ServiceError> errors) {
                // In-App purchase validation was failed by all connected service
                StringBuilder signalMessage = new StringBuilder();
                signalMessage.append(String.format("%s failed to validate", purchase.getOrderId()));
                for(int i = 0; i < errors.size(); i++) {
                        signalMessage.append(String.format("\n%s : %s", errors.get(i).getComponentName(), errors.get(i).getDescription()));
                }
                emitSignal("iap_validate_failed", signalMessage.toString());
            }
        });
    }

    @UsedByGodot
    public void setBidonEndpoint(String endpoint) {
        Appodeal.setBidonEndpoint(endpoint);
    }

    @UsedByGodot
    public String getBidonEndpoint() {
        String endpoint = Appodeal.getBidonEndpoint();
        if (endpoint == null) return "";
        return endpoint;
    }
}
