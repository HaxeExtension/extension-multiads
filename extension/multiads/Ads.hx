package extension.multiads;

#if fbads
import extension.facebookads.FacebookAds;
#end
#if amazonads
import extension.amazonads.AmazonAds;
import extension.amazonads.AmazonAdsEvent;
#end
#if admob
import extension.admob.AdMob;
import extension.admob.GravityMode;
#end
import httpSocket.Http;
import httpSocket.ThreadedHttp;
import openfl.net.SharedObject;

class Ads {
	public static inline var VALIGN_TOP:String = 'TOP';
	public static inline var VALIGN_BOTTOM:String = 'BOTTOM';

	public static inline var NETWORK_NONE:Int = 0;
	public static inline var NETWORK_ADMOB:Int = 1;
	public static inline var NETWORK_AMAZON:Int = 2;
	public static inline var NETWORK_FACEBOOK:Int = 3;

	private static var testingAds:Bool = false;
	private static var initialized:Bool = false;
	private static var mediationOrder:Array<Int> = [];
	private static var disabled:Bool = false;

	#if amazonads
	private static var displayingBanner:Bool = false;
	private static var _amazonAds:AmazonAds = null;
	private static var valign:String = VALIGN_BOTTOM;
	#end

	////////////////////////////////////////////////////////////////////////////

	public static function disable(){
		trace("Disabling ads!");
		hideBanner();
		disabled = true;
	}

	////////////////////////////////////////////////////////////////////////////
	
	private static function saveMediationData(data:String){
		try{
			var ld:SharedObject=SharedObject.getLocal('extension-multiads');
			ld.data.mediationOrder = data;
			ld.flush();			
		}catch( e:Dynamic ){
			trace("ERROR: Could not save mediation order!");
		}
	}

	private static function getSavedMediationData():String{
		try{
			var ld:SharedObject=SharedObject.getLocal('extension-multiads');
			if(ld.data==null) return null;
			if(ld.data.mediationOrder == null) return null;
			return ld.data.mediationOrder;
		}catch( e:Dynamic ){
			trace("ERROR: Could not load mediation order!");
		}
		return null;
	}

	private static function loadMediationOrderFromString(data:String):Bool{
		try{
			if(data==null) return false;
			var order:Array<Int> = haxe.Json.parse(data);
			setMediationOrder(order);
			return true;
		} catch ( e:Dynamic ) {
			trace("ERROR: Could not parse mediation order!");
		}
		return false;
	}

	////////////////////////////////////////////////////////////////////////////

	public static function loadMediationOrder(url:String, defaultOrder:Array<Int>){
		if(disabled) return;

		var oldMediationData = getSavedMediationData();
		if(!loadMediationOrderFromString(oldMediationData)){
			trace("Can't load last mediation order: Using default Mediation Order.");
			setMediationOrder(defaultOrder);			
		}
		trace(mediationOrder);

		ThreadedHttp.requestUrl(url,
			function(http:Http, msg:String){
				try{
					var data = http.data.toString();				
					if(data == oldMediationData){
						trace("Got the same mediation order: "+data);
						return;
					}
					if(loadMediationOrderFromString(data)) {					
						trace("Got new mediation order: "+data);
						trace(mediationOrder);
						saveMediationData(data);
					}
				}catch(e:Dynamic){
					trace("loadMediationOrder error!");
					trace(e);
				}				
			},
			function(http:Http, msg:String){
				trace("loadMediationOrder error!");
				trace(msg);
			}
		);
	}

	public static function setMediationOrder(order:Array<Int>){
		if(disabled) return;

		mediationOrder = [];
		for(network in order){
			if(mediationOrder.indexOf(network)!=-1) continue;
			#if amazonads
				if(Math.abs(network) == NETWORK_AMAZON) mediationOrder.push(network);
			#end
			#if admob
				if(Math.abs(network) == NETWORK_ADMOB) mediationOrder.push(network);
			#end
			#if fbads
				if(Math.abs(network) == NETWORK_FACEBOOK) mediationOrder.push(network);
			#end
		}
	}

	////////////////////////////////////////////////////////////////////////////	

	public static function autoEnableTestingAds () {
		#if testingAds
		enableTestingAds();
		#end
	}

	public static function enableTestingAds() {
		if(disabled) return;

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
		#end
		#if admob
			AdMob.enableTestingAds();
			trace("enabling testing ads for AdMob");
		#end
		#if fbads
			FacebookAds.enableTestingAds();
			trace("enabling testing ads for Facebook");
		#end
	}

	////////////////////////////////////////////////////////////////////////////

	public static function initAndroidAdMob (bannerID:String, interstitialID:String, verticalAlign:String) {
		#if (admob && android)
		if(disabled) return;
		mediationOrder.push(NETWORK_ADMOB);
		initialized = true;
		AdMob.initAndroid(bannerID, interstitialID, (verticalAlign==VALIGN_TOP)?GravityMode.TOP:GravityMode.BOTTOM);
		#end
	}

	////////////////////////////////////////////////////////////////////////////

	public static function initIOSAdMob (bannerID:String, interstitialID:String, verticalAlign:String) {
		#if (admob && ios)
		if(disabled) return;
		mediationOrder.push(NETWORK_ADMOB);
		initialized = true;
		AdMob.initIOS(bannerID, interstitialID, (verticalAlign==VALIGN_TOP)?GravityMode.TOP:GravityMode.BOTTOM);
		#end
	}

	////////////////////////////////////////////////////////////////////////////

	public static function initFacebookAds (bannerID:String, interstitialID:String, verticalAlign:String) {
		#if fbads
		if(disabled) return;
		mediationOrder.push(NETWORK_FACEBOOK);
		initialized = true;
		FacebookAds.init(bannerID, interstitialID, (verticalAlign==VALIGN_TOP));
		#end
	}

	////////////////////////////////////////////////////////////////////////////

	public static function initAmazonAds (appID:String, verticalAlign:String, maxHeight:Float=0) {
		#if amazonads
		if(disabled) return;
		mediationOrder.push(NETWORK_AMAZON);
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

	private static function getBannerNetwork():Int{
		if(mediationOrder.length == 0) return NETWORK_NONE;
		var network:Int = mediationOrder[0];
		if(network<0) network*=-1;
		return network;
	}

	public static function showBanner () {
		if(disabled) return;

		var network = getBannerNetwork();
		if(network == NETWORK_NONE) return;
		if(network<0) network*=-1;
		#if amazonads
			if(network == NETWORK_AMAZON){
				if(displayingBanner) return;
				displayingBanner = true;
				_amazonAds.showAd(AmazonAds.SIZE_AUTO, AmazonAds.HALIGN_CENTER, (Ads.valign==VALIGN_TOP)?AmazonAds.VALIGN_TOP:AmazonAds.VALIGN_BOTTOM);
			}
		#end
		#if admob
			if(network == NETWORK_ADMOB) AdMob.showBanner();
		#end
		#if fbads
			if(network == NETWORK_FACEBOOK) FacebookAds.showBanner();
		#end
	}

	////////////////////////////////////////////////////////////////////////////

	public static function hideBanner () {
		if(disabled) return;

		#if amazonads
			_amazonAds.hideAd();
			displayingBanner = false;
		#end
		#if admob
			AdMob.hideBanner();
		#end
		#if fbads
			FacebookAds.hideBanner();
		#end
	}

	////////////////////////////////////////////////////////////////////////////

	private static function __showInterstitial (network:Int):Bool {
		#if amazonads
			if(network == NETWORK_AMAZON){
				var res:Bool = _amazonAds.showInterstitial();
				_amazonAds.cacheInterstitial();
				return res;			
			}
		#end
		#if admob
			if(network == NETWORK_ADMOB) return AdMob.showInterstitial(0,0);
		#end
		#if fbads
			if(network == NETWORK_FACEBOOK) return FacebookAds.showInterstitial(0,0);
		#end
		return false;
	}

	private static var lastTimeInterstitial:Int = -60*1000;
	private static var displayCallsCounter:Int = 0;
	
	////////////////////////////////////////////////////////////////////////////

	public static function showInterstitial(minInterval:Int=60, minCallsBeforeDisplay:Int=0):Bool {
		if(disabled) return false;

		displayCallsCounter++;
		if( (openfl.Lib.getTimer()-lastTimeInterstitial)<(minInterval*1000) ) return false;
		if( minCallsBeforeDisplay > displayCallsCounter ) return false;
		for(network in mediationOrder){
			if(__showInterstitial(network)){
				displayCallsCounter = 0;
				lastTimeInterstitial = openfl.Lib.getTimer();
				return true;
			}
		}
		return false;
	}

	////////////////////////////////////////////////////////////////////////////

}