using Toybox.WatchUi;
using Toybox.System;
using Toybox.Communications;
using Toybox.System;
using Toybox.Application as App;
using Toybox.Graphics as Gfx; 
 

class WeatherAppView extends WatchUi.View {
    var UNITS = null;
	hidden var width = null;
	hidden var height = null;
	
	hidden var lattitude = null;
	hidden var longitude = null;
	hidden var mTimer = null;
	
    function initialize() {
    	System.println("initialize");
        View.initialize();

        UNITS=(System.getDeviceSettings().temperatureUnits==System.UNIT_STATUTE) ? "us" : "si";
        System.println("units in " + UNITS);
        
        // TODO : check ?
        var positionInfo = Position.getInfo().position;
        var quality = Position.getInfo().accuracy;
        if (positionInfo == null) {
          var activityInfo = Activity.getActivityInfo();
          if (activityInfo != null) {
            positionInfo = activityInfo.currentLocation;
            quality = activityInfo.currentLocationAccuracy;
          }
        }
        
        if (positionInfo != null && quality > Position.QUALITY_NOT_AVAILABLE) {
          lattitude = positionInfo.toDegrees()[0];
          longitude = positionInfo.toDegrees()[1];
          System.println("Refresh location " + lattitude + ", " + longitude + " quality : " + quality);
        }
        
        makeCurrentWeatherRequest();
    }

    // Load your resources here
    function onLayout(dc) {
        //setLayout(Rez.Layouts.MainLayout(dc));
        width=dc.getWidth();
        height=dc.getHeight();
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    	// Allocate a 1Hz timer               
        mTimer = new Timer.Timer();     
        mTimer.start(method(:onTimer), 1000, true);
    }

	// Handler for the timer callback
    function onTimer() {
    	//System.println("onTimer");
    	// for testing
    	//mModel.generateTest();
    	
    	//mModel.updateTimer();
        WatchUi.requestUpdate();
    }
    
    // Update the view
    function onUpdate(dc) {
    	System.println("onUpdate");
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        // Get and show the current time
        var clockTime = System.getClockTime();
        var timeString = Lang.format("$1$:$2$", [clockTime.hour, clockTime.min.format("%02d")]);
		
		dc.setColor(Gfx.COLOR_BLACK,Gfx.COLOR_BLACK);
		dc.clear();
		dc.setColor(Gfx.COLOR_BLUE,Gfx.COLOR_TRANSPARENT);
		
		dc.drawText(width/2,25,Gfx.FONT_SMALL,timeString,Gfx.TEXT_JUSTIFY_CENTER);

  
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    	mTimer.stop();
        mTimer = null;
    }


 function makeCurrentWeatherRequest() {
 		System.println("makeCurrentWeatherRequest");
        if (System.getDeviceSettings().phoneConnected) {

            var appid = App.getApp().getProperty("weather_api_key");              
        
            var params = {
                    "latitude " => 50.4747, // thumeries for sample
                    "longitude "=> 3.061,
                    "key"=> "xxx", // my key !
                    "units" => "si",
                    "lang" => "fr",
                    "exclude" => "[hourly,currently,daily,alerts,flags]"
                    };

            var url = "https://api.darksky.net/forecast/";
    
            var options = {
                    :methods => Communications.HTTP_REQUEST_METHOD_GET,
                    :headers => {"Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED},
                    :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
            };
        
            Communications.makeWebRequest(
                    url,
                    params,
                    options,
                    method(:receiveWeather));
        } else {
            System.println("no phone connection");
        }

/*
        var headers = {"Accept" => "application/json"};
        var params = {};

        var options = {
              :headers => headers,
                :method => Communications.HTTP_REQUEST_METHOD_GET,
                :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
                :params => params
            };

        System.println("Current weather request " + url);

        Communications.makeWebRequest(
            url,
            params, options,
            method(:currentWeatherCallback)
        );
        */
    }

  function formatWindSpeed(value) {
        if (value == null) {
            return "";
        }

        switch (App.getApp().getProperty("WindSpeedUnits")) {
        case 1:
          return (value * 3.6).format("%0.f");
        case 2:
          return (value * 2.237).format("%0.f");
        default:
          return value.format("%.1f");
        }

        return "";
    }

    
   function receiveWeather(responseCode, data) {
   		System.println("receiveWeather");
        if (responseCode == 200) {
             if (data instanceof Lang.String && data.equals("Forbidden")) {
                var dict = { "msg" => "WRONG KEY" };
                System.println("wrong API key");
                //Background.exit(dict);
            } else {
                if (data instanceof Dictionary) {
                // Print the arguments duplicated and returned 
                var keys = data.keys();
                mMessage = "";
                for( var i = 0; i < keys.size(); i++ ) {
                    //mMessage += Lang.format("$1$: $2$\n", [keys[i], args[keys[i]]]);
                    System.println(keys[i] + " => " + data[keys[i]]);
                }
            }   
            }
        } else {
            System.println("Current weather response code " + responseCode + " message " + data.get("message"));         
        }
        WatchUi.requestUpdate();
    }
}
