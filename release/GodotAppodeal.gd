extends Node

# These flags are used for initialization and can be combined with | operator
enum AdType {
	NONE = 0, # 0b0000_0000_0000
	INTERSTITIAL = 3, # 0b0000_0000_0011
	BANNER = 4, # 0b0000_0000_0100
	REWARDED_VIDEO = 128, #0b0000_1000_0000
#	NATIVE = 512, # 0b0010_0000_0000 not implemented in the plugin
	MREC = 256, # 0b0001_0000_0000
}

# These enums are used for specifying the ad type for showing, they can't be combined with | operator
enum ShowStyle {
	INTERSTITIAL = 3, # 0b0000_0000_0011
	BANNER_BOTTOM = 8, # 0b0000_0000_1000
	BANNER_TOP = 16, # 0b0000_0001_0000
	BANNER_LEFT = 1024, # 0b0100_0000_0000
	BANNER_RIGHT = 2048, # 0b1000_0000_0000
#	BANNER_VIEW = 64, # 0b0000_0100_0000 im not sure what this is so it's not implemented
	REWARDED_VIDEO = 128, # 0b0000_1000_0000
	MREC = 256, # 0b0001_0000_0000
#	NATIVE = 512, # 0b0010_0000_0000 not implemented in the plugin
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
signal banner_loaded(heightDpi, precached)
signal banner_load_failed()
signal banner_shown()
signal banner_show_failed()
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
signal mrec_loaded(precached)
signal mrec_load_failed()
signal mrec_shown()
signal mrec_show_failed()
signal mrec_clicked()
signal mrec_expired()
signal initialization_finished(message_string)
signal ad_revenue_received(revenueInfo)
signal iap_validate_success(message)
signal iap_validate_failed(message)

var _appodeal : JNISingleton = null

func _ready() -> void:
	if Engine.has_singleton("GodotAppodeal"):
		output("singleton found")
		_appodeal = Engine.get_singleton("GodotAppodeal")
		connectSignals()
	else:
		output("singleton not found")

func output(message) -> void:
	print("%s: %s" % [name, message])

func initializationExample() -> void:
		# It's easier to autocache ads rather than to cache them manually, however this might cause
		# performance issues if the ads will have to cache during the gameplay. Also autocaching tends
		# to hurt your fillrate and display rate drastically when it comes to ads other than banners,
		# so you should probably consider manual caching instead.
		setAutocache(false, AdType.INTERSTITIAL)

		# When you need to logcat and trace possible problems or performance issues regarding ads,
		# you should try setting LogLevel to LogLevel.DEBUG or LogLevel.VERBOSE, but be advised that
		# high logging levels (VERBOSE especially) tend to decrease performance and thus you should keep
		# LogLevel.NONE for production builds.
		setLogLevel(LogLevel.NONE)

		# If testing is enabled, the game will only show test ads. This behaviour can be tweaked in the
		# Appodeal control panel in your app's settings, but you probably want to keep testing disabled
		# for profuction builds anyway.
		output("WARNING! TESTING ENABLED")
		setTestingEnabled(true)

		# Make sure to call connectSignals() once, otherwise you won't get any callbacks.
		connectSignals()

		# If you want to disable Appodeal Consent Manager and manage user data consent on your own,
		# make sure to set GDPR and CCPA consent status BEFORE calling initialize(). It's recommended
		# to let Appodeal Consent Manager do it's job though.
		output("initializing...")
		initialize(ProjectSettings.get_setting("Appodeal/AppKey"), AdType.INTERSTITIAL|AdType.REWARDED_VIDEO|AdType.BANNER)

# An example of how you can show an interstitial ad.
func showInterstitial() -> void:
	if !_appodeal:
		return
	if canShow(ShowStyle.INTERSTITIAL):
		showAd(ShowStyle.INTERSTITIAL)
		output("showing interstitial")
	else:
		output("can't show interstitial, skipping")

# An example of how you can show a rewarded ad.
func showRewardedAd() -> void:
	if !_appodeal:
		return
	if canShow(ShowStyle.REWARDED_VIDEO):
		showAd(ShowStyle.REWARDED_VIDEO)
		output("showing rewarded video")
	else:
		output("can't show rewarded video, skipping")

# Initializes the SDK. If no consent settings provided before calling this, will also summon ConsentScreen.
func initialize(appKey:String, adTypes) -> void:
	_appodeal.connect("initialization_finished", self, "_initialization_finished") #Emitted when initialization is complete
	_appodeal.initialize(appKey, adTypes)

# Returns true if Appodeal was initialized for the given ad type.
func isInitializedForAdType(adType:int) -> bool:
	return _appodeal.isInitializedForAdType(adType)

# Enables children directed treatment.
func setChildDirectedTreatment(enabled:bool) -> void:
	_appodeal.setChildDirectedTreatment(enabled)

# Sets autocaching for the given selected ad type.
func setAutocache(enabled:bool, adType:int) -> void:
	_appodeal.setAutocache(enabled, adType)

# Returns true if autocache is enabled for the given ad type.
func isAutocacheEnabled(adType:int) -> bool:
	return _appodeal.isAutocacheEnabled(adType)

# Caches an ad for the given type. No need to use this if you have autocache enabled for this adType.
func cacheAd(adType:int) -> void:
	_appodeal.cacheAd(adType)

# Destroys a cached ad
func destroy(adType:int) -> void:
	_appodeal.destroy(adType)

# Destroys cached ads for all ad types
func destroyAllAdTypes() -> void:
	_appodeal.destroyAllAdTypes()

# Returns true if the given ad type is cached.
func isAdPrecached(adType:int) -> bool:
	return _appodeal.isPrecacheAd(adType)

# Returns true if the given ad type is cached for specified placement.
func isAdPrecachedByPlacement(adType:int, placementName:String) -> bool:
	return _appodeal.isPrecacheByPlacement(adType, placementName)

# Switches logging level (see LogLevel enum).
func setLogLevel(logLevel:int) -> void:
	_appodeal.setLogLevel(logLevel)

# Swtiches testing mode.
func setTestingEnabled(enabled:bool) -> void:
	_appodeal.setTestingEnabled(enabled)

# Returns false if an ad can't be shown for any reason.
func canShow(showStyle:int) -> bool:
	return _appodeal.canShow(showStyle)

# Returs true if an ad type is loaded.
func isLoaded(adType:int) -> bool:
	return _appodeal.isLoaded(adType)

# Returns false if an ad for given placement can't be shown for any reason (see Appodeal Wiki about placements).
func canShowForPlacement(showStyle:int, placementName:String) -> bool:
	return _appodeal.canShowForPlacement(showStyle, placementName)

# Shows an ad of a given showStyle.
func showAd(showStyle:int) -> void:
	_appodeal.showAd(showStyle)

# Shows an ad of a given showStyle for specified placement (see Appodeal Wiki about placements).
func showAdForPlacement(showStyle:int, placementName:String) -> void:
	_appodeal.showAdForPlacement(showStyle, placementName)

# If true enables 728x90 banners. Otherwise disables them.
func enable728x90Banners(enabled:bool) -> void:
	_appodeal.enable728x90Banners(enabled)

# Hides the banner.
func hideBanner() -> void:
	_appodeal.hideBanner()

# Sets smart banners enabled/disabled.
func setSmartBannersEnabled(enabled:bool) -> void:
	_appodeal.setSmartBannersEnabled(enabled)

# Sets banner animation enabled/disabled.
func setBannerAnimationEnabled(enabled:bool) -> void:
	_appodeal.setBannerAnimationEnabled(enabled)

# Sets custom banner rotation for sideview banners.
func setBannerRotation(leftBannerRotation:int=-90, rightBannerRotation:int=90) -> void:
	_appodeal.setBannerRotation(leftBannerRotation, rightBannerRotation)

# Programmatically creates an Android View for MREC. I think this only has to be called once and then it gets reused by the SDK.
func createLayoutForMREC() -> void:
	_appodeal.createLayoutForMREC()

# Hides the MREC.
func hideMREC() -> void:
	_appodeal.hideMREC()

# Disables one given ad network. Probably better to do this from Appodeal Dashboard.
func disableNetwork(network:String) -> void:
	_appodeal.disableNetwork(network)

# Disables multiple given ad networks. Probably better to do this from Appodeal Dashboard.
func disableNetworks(networks:Array) -> void:
	_appodeal.disableNetworks(networks)

# Sets a segmant filter. Probably better to do this from Appodeal Dashboard.
func setSegmentFilter(filter:Dictionary) -> void:
	_appodeal.setSegmentFilter(filter)

# Returns predicted eCPM for a given ad type.
func getPredictedEcpmForAdType(adType:int) -> float:
	return _appodeal.getPredictedEcpmForAdType(adType)

# Returns predicted eCPM for a given ad type and placement.
func getPredictedEcpmByPlacement(adType:int, placementName:String) -> float:
	return _appodeal.getPredictedEcpmByPlacement(adType, placementName)

# Returns reward information for given placement (see Appodeal Wiki about placements).
func getRewardForPlacement(placementName:String) -> Dictionary:
	return _appodeal.getRewardForPlacement(placementName)

# Sets user ID to use for S2S callbacks.
func setUserId(userId:String) -> void:
	_appodeal.setUserId(userId)

# Extra data to send to Appodeal. Probably has to do with data attribution and has nothing to do with the monetization.
func setExtras(extras:Dictionary) -> void:
	_appodeal.setExtras(extras)

# Another way to attribute data and log events. Usually people use dedicated tracking SDKs for this.
func logEvent(eventName:String, parameters:Dictionary) -> void:
	_appodeal.logEvent(eventName, parameters)

# Track in-app purchase.
func trackIAP(amount:float, currencyCode:String) -> void:
	_appodeal.trackInAppPurchase(amount, currencyCode)

# Advanced IAP tracking, see https://docs.appodeal.com/android/advanced/in-app-purchases
# The dictionary MUST have all these keys, otherwise validateIAP will do nothing:
#	"inappType" - String, must be equal to "subscription" if the IAP is a subscription
#	"publicKey" - String, see https://support.google.com/googleplay/android-developer/answer/186113
#	"signature" - String
#	"purchaseData" - String
#	"purchaseToken" - String
#	"purchaseTimestamp" - int (long)
#	"developerPayload" - String
#	"orderId" - String
#	"sku" - String
#	"price" - String
#	"currency" - String
# You can specify additional params as a dictionary of Strings like this:
#	"additionalParams" - a Dict of Strings
func validateIAP(purchaseDetails:Dictionary) -> void:
	_appodeal.validatePurchase(purchaseDetails)

# Mute videoads if call volume is muted. AFAIK this is an Android-only feature.
func muteVideosIfCallsMuted(mute:bool) -> void:
	_appodeal.muteVideosIfCallsMuted(mute)

# Set self-hosted Bidon environment endpoint
func setBidonEndpoint(endpoint:String) -> void:
	_appodeal.setBidonEndpoint(endpoint)

# Get self-hosted Bidon environment endpoint
func getBidonEndpoint() -> String:
	return _appodeal.getBidonEndpoint()

# Connects JNISingletone signals with the callback functions in this script.
func connectSignals() -> void:
	_appodeal.connect("interstitial_loaded", self, "_interstitial_loaded") # Emitted when interstitial has been loaded and cached (precached:bool)
	_appodeal.connect("interstitial_load_failed", self, "_interstitial_load_failed") # Emitted when interstitial failed to load
	_appodeal.connect("interstitial_shown", self, "_interstitial_shown") # Emitted when interstitial has started to show
	_appodeal.connect("interstitial_show_failed", self, "_interstitial_show_failed") # Emitted when interstitial failed to show for some reason
	_appodeal.connect("interstitial_clicked", self, "_interstitial_clicked") # Emitted when interstitial clicked
	_appodeal.connect("interstitial_closed", self, "_interstitial_closed") # Emitted when interstitial was closed (the usual scenario when the gameplay continues)
	_appodeal.connect("interstitial_expired", self, "_interstitial_expired") # Emitted when cached interstitial has expired and needs recache

	_appodeal.connect("banner_loaded", self, "_banner_loaded") # Emitted when banner has been loaded (precached:bool)
	_appodeal.connect("banner_load_failed", self, "_banner_load_failed") # Emitted when banner failed to load
	_appodeal.connect("banner_shown", self, "_banner_shown") # Emitted when banner has been shown
	_appodeal.connect("banner_show_failed", self, "_banner_show_failed") # Emitted when banner failed to show
	_appodeal.connect("banner_clicked", self, "_banner_clicked") # Emitted when banner has been clicked
	_appodeal.connect("banner_expired", self, "_banner_expired") # Emitted when banner has expired

	_appodeal.connect("rewarded_video_loaded", self, "_rewarded_video_loaded") # Emitted when rewarded ad has been loaded and cached (precached:bool)
	_appodeal.connect("rewarded_video_load_failed", self, "_rewarded_video_load_failed") # Emitted when rewarded ad failed to load
	_appodeal.connect("rewarded_video_shown", self, "_rewarded_video_shown") # Emitted when rewarded ad has started to show
	_appodeal.connect("rewarded_video_show_failed", self, "_rewarded_video_show_failed") # Emitted when rewarded ad failed to show for some reason
	_appodeal.connect("rewarded_video_clicked", self, "_rewarded_video_clicked") # Emitted when rewarded ad clicked
	_appodeal.connect("rewarded_video_finished", self, "_rewarded_video_finished") # Emitted when rewarded ad was viewed until the end, provides reward info (amount:float, currency:String)
	_appodeal.connect("rewarded_video_closed", self, "_rewarded_video_closed") # Emitted when rewarded ad was closed (the usual scenario when the gameplay continues)
	_appodeal.connect("rewarded_video_expired", self, "_rewarded_video_expired") # Emitted when cached rewarded ad has expired and needs recache

	_appodeal.connect("mrec_loaded", self, "_mrec_loaded") # Emitted when MREC has been loaded (precached:bool)
	_appodeal.connect("mrec_load_failed", self, "_mrec_load_failed") # Emitted when MREC failed to load
	_appodeal.connect("mrec_shown", self, "_mrec_shown") # Emitted when MREC got shown
	_appodeal.connect("mrec_show_failed", self, "_mrec_show_failed") # Emitted when MREC failed to show for some reason
	_appodeal.connect("mrec_clicked", self, "_mrec_clicked") # Emitted when MREC has been clicked
	_appodeal.connect("mrec_expired", self, "_mrec_expired") # Emitted when MREC has expired

	_appodeal.connect("ad_revenue_received", self, "_ad_revenue_received") #Emitted when ad revenue has been received
	_appodeal.connect("iap_validate_success", self, "_iap_validate_success") #Emitted when an IAP has successfully been validated via validateIAP()
	_appodeal.connect("iap_validate_failed", self, "_iap_validate_failed") #Emitted when ad IAP has failed to validate via validateIAP()


#---------------#
#---CALLBACKS---#
#---------------#

func _initialization_finished(message_string) -> void:
	output("initialization finished with message: %s" % message_string)
	emit_signal("initialization_finished", message_string)

func _ad_revenue_received(revenueInfo:Dictionary) -> void:
	#Dictionary contents will be as follows:
	# networkName : String - The name of the ad network, guaranteed not to be null.
	# demandSource : String - The demand source name and bidder name in case of impression from real-time bidding, guaranteed not to be null.
	# adUnitName : String - Unique ad unit name guaranteed not to be null.
	# placement : String - Appodeal's placement name, guaranteed not to be null.
	# revenue : float - The ad's revenue amount or 0 if it doesn't exist.
	# adType : int - Appodeal ad type.
	# adTypeString : String - Appodeal ad type as string presentation.
	# platform : String - Appodeal platform name.
	# currency : String - Current currency supported by Appodeal (USD) as string presentation.
	# revenuePrecision - The revenue precision, which can be:
	#### 1. 'exact' - programmatic revenue is the resulting price of the auction
	#### 2. 'publisher_defined' - revenue from crosspromo campaigns
	#### 3. 'estimated' - revenue based on ad network pricefloors or historical eCPM
	#### 4. 'undefined' - revenue amount is not defined
	emit_signal("ad_revenue_received", revenueInfo)
	print("%s: ad revenue received" % name)

func _interstitial_load_failed() -> void:
	emit_signal("interstitial_load_failed")
	output("interstitial_load_failed")

func _interstitial_shown() -> void:
	emit_signal("interstitial_shown")
	output("interstitial_shown")

func _interstitial_show_failed() -> void:
	emit_signal("interstitial_show_failed")
	output("interstitial_show_failed")

func _interstitial_clicked() -> void:
	emit_signal("interstitial_clicked")
	output("interstitial_clicked")

func _interstitial_closed() -> void:
	emit_signal("interstitial_closed")
	output("interstitial_close")

func _interstitial_expired() -> void:
	emit_signal("interstitial_expired")
	output("interstitial_expired")

func _interstitial_loaded(precached:bool) -> void:
	emit_signal("interstitial_loaded", precached)
	output("interstitial_loaded")

func _banner_loaded(heightDpi, precached) -> void:
	emit_signal("banner_loaded", heightDpi, precached)
	output("banner_loaded")

func _banner_load_failed() -> void:
	emit_signal("banner_load_failed")
	output("banner_load_failed")

func _banner_shown() -> void:
	emit_signal("banner_shown")
	output("banner_shown")

func _banner_show_failed() -> void:
	emit_signal("banner_show_failed")
	output("banner_show_failed")

func _banner_clicked() -> void:
	emit_signal("banner_clicked")
	output("banner_clicked")

func _banner_expired() -> void:
	emit_signal("banner_expired")
	output("banner_expired")

func _rewarded_video_loaded(precached:bool) -> void:
	emit_signal("rewarded_video_loaded", precached)
	output("rewarded_video_loaded")

func _rewarded_video_load_failed() -> void:
	emit_signal("rewarded_video_load_failed")
	output("rewarded_video_load_failed")

func _rewarded_video_shown() -> void:
	emit_signal("rewarded_video_shown")
	output("rewarded_video_shown")
	
func _rewarded_video_show_failed() -> void:
	emit_signal("rewarded_video_show_failed")
	output("rewarded_video_show_failed")

func _rewarded_video_finished(amount:float, currency) -> void:
	emit_signal("rewarded_video_finished", amount, currency)
	output("rewarded_video_finished")

func _rewarded_video_closed(finished:bool) -> void:
	emit_signal("rewarded_video_closed", finished)
	output("rewarded_video_closed")

func _rewarded_video_expired() -> void:
	emit_signal("rewarded_video_expired")
	output("rewarded_video_expired")

func _rewarded_video_clicked() -> void:
	emit_signal("rewarded_video_clicked")
	output("rewarded_video_clicked")

func _mrec_loaded(precached:bool) -> void:
	emit_signal("mrec_loaded", precached)
	output("mrec_loaded")

func _mrec_load_failed() -> void:
	emit_signal("mrec_load_failed")
	output("mrec_load_failed")

func _mrec_shown() -> void:
	emit_signal("mrec_shown")
	output("mrec_shown")

func _mrec_show_failed() -> void:
	emit_signal("mrec_show_failed")
	output("mrec_show_failed")

func _mrec_clicked() -> void:
	emit_signal("mrec_clicked")
	output("mrec_clicked")

func _mrec_expired() -> void:
	emit_signal("mrec_expired")
	output("mrec expired name")

func _iap_validate_success(message:String) -> void:
	emit_signal("iap_validate_success", message)
	output("iap_validate_success")

func _iap_validate_failed(message:String) -> void:
	emit_signal("iap_validate_failed", message)
	output("iap_validate_failed")
