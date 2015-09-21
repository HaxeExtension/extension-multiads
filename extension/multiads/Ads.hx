package extension.multiads;

#if fbads
import extension.facebookads.FacebookAds;
#elseif amazonads
import extension.amazonads.AmazonAds;
import extension.amazonads.AmazonAdsEvent;
#elseif admob
import extension.admob.AdMob;
import extension.admob.GravityMode;
#end

class Ads {
	public static inline var VALIGN_TOP:String = 'TOP';
	public static inline var VALIGN_BOTTOM:String = 'BOTTOM';
	private static var testingAds:Bool = false;
	private static var initialized:Bool = false;

	#if amazonads
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
		#if amazonads
			trace("enabling testing ads for Amazon");
		#elseif admob
			AdMob.enableTestingAds();
			trace("enabling testing ads for AdMob");
		#elseif fbads
			FacebookAds.enableTestingAds();
			trace("enabling testing ads for Facebook");
		#else
			trulala;
		#end
	}

	////////////////////////////////////////////////////////////////////////////

	public static function initAndroidAdMob (bannerID:String, interstitialID:String, verticalAlign:String) {
		#if admob
		initialized = true;
		AdMob.initAndroid(bannerID, interstitialID, (verticalAlign==VALIGN_TOP)?GravityMode.TOP:GravityMode.BOTTOM);
		#end
	}

	////////////////////////////////////////////////////////////////////////////

	public static function initIOSAdMob (bannerID:String, interstitialID:String, verticalAlign:String) {
		#if admob
		initialized = true;
		AdMob.initIOS(bannerID, interstitialID, (verticalAlign==VALIGN_TOP)?GravityMode.TOP:GravityMode.BOTTOM);
		#end
	}

	////////////////////////////////////////////////////////////////////////////

	public static function initFacebookAds (bannerID:String, interstitialID:String, verticalAlign:String) {
		#if fbads
		initialized = true;
		FacebookAds.init(bannerID, interstitialID, (verticalAlign==VALIGN_TOP));
		#end
	}

	////////////////////////////////////////////////////////////////////////////

	public static function initAmazonAds (appID:String, verticalAlign:String, maxHeight:Float=0) {
		#if amazonads
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
		#if amazonads
			if(displayingBanner) return;
			displayingBanner = true;
			_amazonAds.showAd(AmazonAds.SIZE_AUTO, AmazonAds.HALIGN_CENTER, (Ads.valign==VALIGN_TOP)?AmazonAds.VALIGN_TOP:AmazonAds.VALIGN_BOTTOM);
		#elseif admob
			AdMob.showBanner();
		#elseif fbads
			FacebookAds.showBanner();
		#end
	}

	////////////////////////////////////////////////////////////////////////////

	public static function hideBanner () {
		#if amazonads
			_amazonAds.hideAd();
			displayingBanner = false;
		#elseif admob
			AdMob.hideBanner();
		#elseif fbads
			FacebookAds.hideBanner();
		#end
	}

	////////////////////////////////////////////////////////////////////////////

	private static function __showInterstitial ():Bool {
		#if amazonads
			var res:Bool = _amazonAds.showInterstitial();
			_amazonAds.cacheInterstitial();
			return res;
		#elseif admob
			return AdMob.showInterstitial(0,0);
		#elseif fbads
			return FacebookAds.showInterstitial(0,0);
		#end
		return false;
	}

	private static var lastTimeInterstitial:Int = -60*1000;
	private static var displayCallsCounter:Int = 0;
	
	////////////////////////////////////////////////////////////////////////////

	public static function showInterstitial(minInterval:Int=60, minCallsBeforeDisplay:Int=0):Bool {
		displayCallsCounter++;
		if( (openfl.Lib.getTimer()-lastTimeInterstitial)<(minInterval*1000) ) return false;
		if( minCallsBeforeDisplay > displayCallsCounter ) return false;
		if(!__showInterstitial()) return false;
		displayCallsCounter = 0;
		lastTimeInterstitial = openfl.Lib.getTimer();
		return true;
	}

	////////////////////////////////////////////////////////////////////////////

}