extends Node

enum AdType {
  INTERSTITIAL = 1,
  BANNER = 2,
  NATIVE = 4,
  REWARDED_VIDEO = 8,
  NON_SKIPPABLE_VIDEO = 16,
}

enum ShowStyle {
  INTERSTITIAL = 1,
  BANNER_TOP = 2,
  BANNER_BOTTOM = 4,
  REWARDED_VIDEO = 8,
  NON_SKIPPABLE_VIDEO = 16,
}

enum ConsentType {
  UNKNOWN = 0,
  PERSONALIZED = 3, #equal to CCPA "OptIn" status
  NON_PERSONALIZED = 1, #equal to CCPA "OptOut" status
}

enum LogLevel {
	NONE = 0,
	DEBUG = 1,
	VERBOSE = 2
}

signal interstitial_loaded(precached)
signal interstitial_load_failed()
signal interstitial_show_failed()
signal interstitial_shown()
signal interstitial_closed()
signal interstitial_clicked()
signal interstitial_expired()
signal banner_loaded(precached)
signal banner_load_failed()
signal banner_shown()
signal banner_clicked()
signal banner_expired()
signal rewarded_video_loaded(precached)
signal rewarded_video_load_failed()
signal rewarded_video_shown()
signal rewarded_video_show_failed()
signal rewarded_video_clicked()
signal rewarded_video_finished(amount, currency)
signal rewarded_video_closed(finished)
signal rewarded_video_expired()
signal initialization_finished(error_list)

var _appodeal : JNISingleton = null

func _ready() -> void:
	if Engine.has_singleton("GodotAppodeal"):
		print("%s : singletone found" % name)
		_appodeal = Engine.get_singleton("GodotAppodeal")

		#If you want to disable Appodeal Consent Manager and manage user data consent on your own,
		#make sure to set GDPR and CCPA consent status BEFORE calling initialize(). It's recommended
		#to let Appodeal Consent Manager do it's job though.

		print("%s : initializing ..." % name)
		initialize(ProjectSettings.get_setting("Appodeal/AppKey"), AdType.INTERSTITIAL|AdType.REWARDED_VIDEO)

		#It's easier to autocache ads rather than to cache them manually, however this might cause
		#performance issues if the ads will have to cache during the gameplay.

		setAutocache(true, AdType.INTERSTITIAL)

		#When you need to logcat and trace possible problems or performance issues regarding ads,
		#you should try setting LogLevel to LogLevel.DEBUG or LogLevel.VERBOSE, but be advised that
		#high logging levels (VERBOSE especially) tend to decrease performance and thus you should keep
		#LogLevel.NONE for production builds.

		setLogLevel(LogLevel.NONE)

		#If testing is enabled, the game will only show test ads. This behaviour can be tweaked in the
		#Appodeal control panel in your app's settings, but you probably want to keep testing disabled
		#for profuction builds anyway.

		print("%s : WARNING! TESTING ENABLED" % name)
		setTestingEnabled(true)

		#Make sure to call connectSignals() once, otherwise you won't get any callbacks.

		connectSignals()

	else:
		print("%s : Appodeal singletone not found" % name)

#A working example of how you can show an interstitial ad.
func showInterstitial() -> void:
	if !_appodeal:
		return
	if canShow(ShowStyle.INTERSTITIAL):
		showAd(ShowStyle.INTERSTITIAL)
		print("%s : showing interstitial" % name)
	else:
		print("%s : can't show interstitial, skipping" % name)

#A working example of how you can show a rewarded ad.
func showRewardedAd() -> void:
	if !_appodeal:
		return
	if canShow(ShowStyle.REWARDED_VIDEO):
		showAd(ShowStyle.REWARDED_VIDEO)
		print("%s : showing rewarded video" % name)
	else:
		print("%s : can't show rewarded video, skipping" % name)

#Initializes the SDK. If no consent settings provided before calling this, will also summon ConsentScreen.
func initialize(appKey:String, adTypes) -> void:
	_appodeal.initialize(appKey, adTypes)

#Returns true if Appodeal was initialized for the given ad type.
func isInitializedForAdType(adType:int) -> bool:
	return _appodeal.isInitializedForAdType(adType)

#Enables children directed treatment.
func setChildDirectedTreatment(enabled:bool) -> void:
	_appodeal.setChildDirectedTreatment(enabled)

#Sets GDRPUserConsent status (see ConsentType enum)
func updateGDPRUserConsent(consentType:int) -> void:
	_appodeal.updateGDPRUserConsent(consentType)

#Sets CCPAUserConsent status (see ConsentType enum)
func updateCCPAUserConsent(consentType:int) -> void:
	_appodeal.updateCCPAUserConsent(consentType)

#Returns a dict of current session consent status.
func getConsentStatus() -> Dictionary:
	return _appodeal.getConsentStatus()

#Purely for testing purposes to check if your consent works as intended.
func printConsentStatus() -> void:
	var _dict : Dictionary = getConsentStatus()
	for key in _dict:
		print("%s: consent -> %s = %s" % [name, key.to_upper(), _dict[key]])

#Sets autocaching for the given selected ad type.
func setAutocache(enabled:bool, adType:int) -> void:
	_appodeal.setAutocache(enabled, adType)

#Returns true if autocache is enabled for the given ad type.
func isAutocacheEnabled(adType:int) -> bool:
	return _appodeal.isAutocacheEnabled(adType)

#Caches an ad for the given type. No need to use this if you have autocache enabled for this adType.
func cacheAd(adType:int) -> void:
	_appodeal.cacheAd(adType)

#Returns true if the given ad type is cached.
func isAdPrecached(adType:int) -> bool:
	return _appodeal.isPrecacheAd(adType)

#Switches logging level (see LogLevel enum).
func setLogLevel(logLevel:int) -> void:
	_appodeal.setLogLevel(logLevel)

#Swtiches testing mode.
func setTestingEnabled(enabled:bool) -> void:
	_appodeal.setTestingEnabled(enabled)

#Returns false if an ad can't be shown for any reason.
func canShow(showStyle:int) -> bool:
	return _appodeal.canShow(showStyle)
	
#Returns false if an ad for given placement can't be shown for any reason (see Appodeal Wiki about placements).
func canShowForPlacement(showStyle:int, placementName:String) -> bool:
	return _appodeal.canShowForPlacement(showStyle, placementName)

#Shows an ad of a given showStyle.
func showAd(showStyle:int) -> void:
	_appodeal.showAd(showStyle)

#Shows an ad of a given showStyle for specified placement (see Appodeal Wiki about placements).
func showAdForPlacement(showStyle:int, placementName:String) -> void:
	_appodeal.showAdForPlacement(showStyle, placementName)

#If set to 1, enables 728x90 banners. Otherwise disables them.
func setPreferredBannerAdSize(size:int) -> void:
	_appodeal.setPreferredBannerAdSize(size)

#Hides the banner.
func hideBanner() -> void:
	_appodeal.hideBanner()

#Sets smart banners enabled/disabled.
func setSmartBannersEnabled(enabled:bool) -> void:
	_appodeal.setSmartBannersEnabled(enabled)

#Sets banner animation enabled/disabled.
func setBannerAnimationEnabled(enabled:bool) -> void:
	_appodeal.setBannerAnimationEnabled(enabled)

#Disables one given ad network. Probably better to do this from Appodeal Dashboard.
func disableNetwork(network:String) -> void:
	_appodeal.disableNetwork(network)

#Disables multiple given ad networks. Probably better to do this from Appodeal Dashboard.
func disableNetworks(networks:Array) -> void:
	_appodeal.disableNetworks(networks)

#Sets a segmant filter. Probably better to do this from Appodeal Dashboard.
func setSegmentFilter(filter:Dictionary) -> void:
	_appodeal.setSegmentFilter(filter)

#Returns predicted eCPM for a given ad type.
func getPredictedEcpmForAdType(adType:int) -> float:
	return _appodeal.getPredictedEcpmForAdType(adType)

#Returns reward information for given placement (see Appodeal Wiki about placements).
func getRewardForPlacement(placementName:String) -> Dictionary:
	return _appodeal.getRewardForPlacement(placementName)

#Sets user ID to use for S2S callbacks.
func setUserId(userId:String) -> void:
	_appodeal.setUserId(userId)

#Extra data to send to Appodeal. Probably has to do with data attribution and has nothing to do with the monetization.
func setExtras(extras:Dictionary) -> void:
	_appodeal.setExtras(extras)

#Another way to attribute data and log events. Usually people use dedicated tracking SDKs for this.
func logEvent(eventName:String, parameters:Dictionary) -> void:
	_appodeal.logEvent(eventName, parameters)

#Track in-app purchase.
func trackIAP(amount:float, currencyCode:String) -> void:
	_appodeal.trackInAppPurchase(amount, currencyCode)

#Mute videoads if call volume is muted. AFAIK this is an Android-only feature.
func muteVideosIfCallsMuted(mute:bool) -> void:
	_appodeal.muteVideosIfCallsMuted(mute)

#Connects JNISingletone signals with the callback functions in this script.
func connectSignals() -> void:
	_appodeal.connect("initialization_finished", self, "_initialization_finished") #Emitted when initialization is complete
	
	_appodeal.connect("interstitial_loaded", self, "_interstitial_loaded") #Emitted when interstitial has been loaded and cached (precached:bool)
	_appodeal.connect("interstitial_load_failed", self, "_interstitial_load_failed") #Emitted when interstitial failed to load
	_appodeal.connect("interstitial_shown", self, "_interstitial_shown") #Emitted when interstitial has started to show
	_appodeal.connect("interstitial_show_failed", self, "_interstitial_show_failed") #Emitted when interstitial failed to show for some reason
	_appodeal.connect("interstitial_clicked", self, "_interstitial_clicked") #Emitted when interstitial clicked
	_appodeal.connect("interstitial_closed", self, "_interstitial_closed") #Emitted when interstitial was closed (the usual scenario when the gameplay continues)
	_appodeal.connect("interstitial_expired", self, "_interstitial_expired") #Emitted when cached interstitial has expired and needs recache
	
	_appodeal.connect("banner_loaded", self, "_banner_loaded") #Emitted when banner has been loaded (precached:bool)
	_appodeal.connect("banner_load_failed", self, "_banner_load_failed") #Emitted when banner failed to load
	_appodeal.connect("banner_shown", self, "_banner_shown") #Emitted when banner has been shown
	_appodeal.connect("banner_clicked", self, "_banner_clicked") #Emitted when banner has been clicked
	_appodeal.connect("banner_expired", self, "_banner_expired") #Emitted when banner has expired
	
	_appodeal.connect("rewarded_video_loaded", self, "_rewarded_video_loaded") #Emitted when rewarded ad has been loaded and cached (precached:bool)
	_appodeal.connect("rewarded_video_load_failed", self, "_rewarded_video_load_failed") #Emitted when rewarded ad failed to load
	_appodeal.connect("rewarded_video_shown", self, "_rewarded_video_shown") #Emitted when rewarded ad has started to show
	_appodeal.connect("rewarded_video_show_failed", self, "_rewarded_video_show_failed") #Emitted when rewarded ad failed to show for some reason
	_appodeal.connect("rewarded_video_clicked", self, "_rewarded_video_clicked") #Emitted when rewarded ad clicked
	_appodeal.connect("rewarded_video_finished", self, "_rewarded_video_finished") #Emitted when rewarded ad was viewed until the end, provides reward info (amount:float, currency:String)
	_appodeal.connect("rewarded_video_closed", self, "_rewarded_video_closed") #Emitted when rewarded ad was closed (the usual scenario when the gameplay continues)
	_appodeal.connect("rewarded_video_expired", self, "_rewarded_video_expired") #Emitted when cached rewarded ad has expired and needs recache

#---------------#
#---CALLBACKS---#
#---------------#

func _initialization_finished(error_list) -> void:
	emit_signal("initialization_finished", error_list)
	print("%s: initialization finished with %s errors" % [name, error_list.size()])

func _interstitial_load_failed() -> void:
	emit_signal("interstitial_load_failed")
	print("%s : interstitial_load_failed" % name)

func _interstitial_shown() -> void:
	emit_signal("interstitial_shown")
	print("%s : interstitial_shown" % name)

func _interstitial_show_failed() -> void:
	emit_signal("interstitial_show_failed")
	print("%s : interstitial_show_failed" % name)

func _interstitial_clicked() -> void:
	emit_signal("interstitial_clicked")
	print("%s : interstitial_clicked" % name)

func _interstitial_closed() -> void:
	emit_signal("interstitial_closed")
	print("%s : interstitial_close" % name)

func _interstitial_expired() -> void:
	emit_signal("interstitial_expired")
	print("%s : interstitial_expired" % name)

func _interstitial_loaded(precached:bool) -> void:
	emit_signal("interstitial_loaded", precached)
	print("%s : interstitial_loaded" % name)

func _banner_loaded(precached) -> void:
	emit_signal("banner_loaded", precached)
	print("%s : banner_loaded" % name)

func _banner_load_failed() -> void:
	emit_signal("banner_load_failed")
	print("%s : banner_load_failed" % name)

func _banner_shown() -> void:
	emit_signal("banner_shown")
	print("%s : banner_shown" % name)

func _banner_clicked() -> void:
	emit_signal("banner_clicked")
	print("%s : banner_clicked" % name)

func _banner_expired() -> void:
	emit_signal("banner_expired")
	print("%s : banner_expired" % name)

func _rewarded_video_loaded(precached:bool):
	emit_signal("rewarded_video_loaded", precached)
	print("%s : rewarded_video_loaded" % name)

func _rewarded_video_load_failed() -> void:
	emit_signal("rewarded_video_load_failed")
	print("%s : rewarded_video_load_failed" % name)

func _rewarded_video_shown() -> void:
	emit_signal("rewarded_video_shown")
	print("%s : rewarded_video_shown" % name)
	
func _rewarded_video_show_failed() -> void:
	emit_signal("rewarded_video_show_failed")
	print("%s : rewarded_video_show_failed" % name)

func _rewarded_video_finished(amount:float, currency) -> void:
	emit_signal("rewarded_video_finished", amount, currency)
	print("%s : rewarded_video_finished" % name)

func _rewarded_video_closed(finished:bool) -> void:
	emit_signal("rewarded_video_closed", finished)
	print("%s : rewarded_video_closed" % name)

func _rewarded_video_expired() -> void:
	emit_signal("rewarded_video_expired")
	print("%s : rewarded_video_expired" % name)

func _rewarded_video_clicked() -> void:
	emit_signal("rewarded_video_clicked")
	print("%s : rewarded_video_clicked" % name)

