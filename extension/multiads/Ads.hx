package extension.multiads;

#if amazon
import extension.amazonads.AmazonAds;
import extension.amazonads.AmazonAdsEvent;
#else
import extension.admob.AdMob;
import extension.admob.GravityMode;
#end

class Ads {
	public static inline var VALIGN_TOP:String = 'TOP';
	public static inline var VALIGN_BOTTOM:String = 'BOTTOM';
	private static var testingAds:Bool = false;
	private static var initialized:Bool = false;

	#if amazon
	private static var displayingBanner:Bool = false;
	private static var _amazonAds:AmazonAds = null;
	private static var valign:String = VALIGN_BOTTOM;
	#end

	////////////////////////////////////////////////////////////////////////////
	
	public static function autoEnableTestingAds () {
		#if testingAds
		enableTestingAds();
		#end
	}

	public static function enableTestingAds() {
		if ( testingAds ) return;
		if ( initialized ) {
			var msg:String;
			msg = "FATAL ERROR: If you want to enable Testing Ads, you must enable them before calling INIT!.\n";
			msg+= "Throwing an exception to avoid displaying read ads when you want testing ads.";
			trace(msg);
			throw msg;
			return;
		}
		testingAds = true;
		#if !amazon
		AdMob.enableTestingAds();
		#end
	}

	////////////////////////////////////////////////////////////////////////////

	public static function initAndroidAdMob (bannerID:String, interstitialID:String, verticalAlign:String) {
		#if !amazon
		initialized = true;
		AdMob.initAndroid(bannerID, interstitialID, (verticalAlign==VALIGN_TOP)?GravityMode.TOP:GravityMode.BOTTOM);
		#end
	}

	////////////////////////////////////////////////////////////////////////////

	public static function initIOSAdMob (bannerID:String, interstitialID:String, verticalAlign:String) {
		#if !amazon
		initialized = true;
		AdMob.initIOS(bannerID, interstitialID, (verticalAlign==VALIGN_TOP)?GravityMode.TOP:GravityMode.BOTTOM);
		#end
	}

	////////////////////////////////////////////////////////////////////////////

	public static function initAmazonAds (appID:String, verticalAlign:String, maxHeight:Float=0) {
		#if amazon
		initialized = true;		
		Ads.valign = verticalAlign;
		_amazonAds = new AmazonAds();
		_amazonAds.addEventListener(AmazonAdsEvent.INIT_OK, function(_){trace("AMAZON ADS INIT OK");});
		//_amazonAds.addEventListener(AmazonAdsEvent.INTERSTITIAL_CACHE_OK,  function(){trace("AMAZON ADS CACHE OK");});
		if(testingAds) _amazonAds.enableTesting(true);
		_amazonAds.init(appID, Math.round(maxHeight)); //you can only use Amazon Ads after successful initialization
		//_amazonAds.enableLogging(true); //enable to see extra debug information
		_amazonAds.cacheInterstitial();
   		#end
	}

	////////////////////////////////////////////////////////////////////////////

	public static function showBanner () {
		#if amazon
		if(displayingBanner) return;
		displayingBanner = true;
		_amazonAds.showAd(AmazonAds.SIZE_AUTO, AmazonAds.HALIGN_CENTER, (Ads.valign==VALIGN_TOP)?AmazonAds.VALIGN_TOP:AmazonAds.VALIGN_BOTTOM);
		#else
		AdMob.showBanner();
		#end
	}

	////////////////////////////////////////////////////////////////////////////

	public static function hideBanner () {
		#if amazon
		_amazonAds.hideAd();
		displayingBanner = false;
		#else
		AdMob.hideBanner();
		#end		
	}

	////////////////////////////////////////////////////////////////////////////

	private static function __showInterstitial () {
		#if amazon
		_amazonAds.showInterstitial();
		_amazonAds.cacheInterstitial();
		#else
		AdMob.showInterstitial(0,0);
		#end
	}

	private static var lastTimeInterstitial:Int = -60*1000;
	private static var displayCallsCounter:Int = 0;
	
	////////////////////////////////////////////////////////////////////////////

	public static function showInterstitial(minInterval:Int=60, minCallsBeforeDisplay:Int=0) {
		displayCallsCounter++;
		if( (openfl.Lib.getTimer()-lastTimeInterstitial)<(minInterval*1000) ) return;
		if( minCallsBeforeDisplay > displayCallsCounter ) return;
		displayCallsCounter = 0;
		lastTimeInterstitial = openfl.Lib.getTimer();
		__showInterstitial();
	}

	////////////////////////////////////////////////////////////////////////////

}