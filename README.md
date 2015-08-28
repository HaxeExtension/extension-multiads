#extension-multiads

A minimalistic OpenFL / Lime extension to manage multiple ad networks using a single API.

###Currently supports

* AdMob (Android & iOS)
* Amazon (Android only)

###Simple use Example

```haxe
// This example show a simple example.

import extension.multiads.Ads;

class SimpleExample {
	function new(){
		// first of all, decide if you want to display testing ads by calling enableTestingAds() method.
		// Note that if you decide to call enableTestingAds(), you must do that before calling INIT methods.	
		Ads.enableTestingAds();
		//Ads.autoEnableTestingAds();

		// then call init with Android and iOS banner IDs in the main method.
		// parameters are (bannerId:String, interstitialId:String, gravityMode:GravityMode).
		// if you don't have the bannerId and interstitialId, go to www.google.com/ads/admob to create them.
		// for amazon parameters are (AppID:String,VerticalAlign,?maxHeight:Int).
		// maxHeight is optional and should not be less than 100 in case you set it manually.

		Ads.initAndroidAdMob( "ca-app-pub-3612074xxxxx21909", "ca-app-pub-361207xxxxxxxx107", Ads.VALIGN_BOTTOM);
		Ads.initIOSAdMob( "ca-app-pub-36120743xxxxxxxxxx502", "ca-app-pub-361207xxxxxxxx706", Ads.VALIGN_BOTTOM);
		Ads.initAmazonAds( "d12eee8xxxxx211ea3", Ads.VALIGN_BOTTOM);	
	}

	function gameOver() {
		// some implementation
		Ads.showInterstitial(0);

		/* NOTE:
		showInterstitial function has two parameters you can use to control how often you want to display the interstitial ad.

		public static function showInterstitial(minInterval:Int=60, minCallsBeforeDisplay:Int=0);

		* The banner will not show if it was displayed less than "minInterval" seconds ago.
		* The banner will show only after "#minCallsBeforeDisplay" calls to showInterstitial function.

		- To display an interstitial after every time the game finishes, call:
		Ads.showInterstitial(0);
		- To avoid displaying the interstitial if the game was too short (60 seconds), call:
		Ads.showInterstitial(60);
		- To display an interstitial every 3 finished games call:
		Ads.showInterstitial(0,3);
		- To display an interstitial every 3 finished games (but never before 120 secs since last display), call:
		Ads.showInterstitial(120,3); */
	}
	
	function mainMenu() {
		// some implementation
		Ads.showBanner(); // this will show the banner.
	}

	function beginGame() {
		// some implementation
		Ads.hideBanner(); // if you don't want the banner to be on screen while playing... call Ads.hideBanner();
	}
}

```

###How to Install

```bash
haxelib install extension-multiads
```

###How to Choose the Ad Network

To build using AdMob (the default)
```bash
lime test android
lime test ios
```

To build using Amazon Ads
```bash
lime test android -Damazon
```

###License

The MIT License (MIT) - [LICENSE.md](LICENSE.md)

Copyright &copy;  2015 SempaiGames (http://www.sempaigames.com)

Author: Federico Bricker
