using Toybox.WatchUi;
using Toybox.System;
using Toybox.Communications;
using Toybox.System;
using Toybox.Application as App;
using Toybox.Graphics as Gfx; 
using Toybox.Math; 

class WeatherAppView extends WatchUi.View {
    var units = null;
	private var width = null;
	private var height = null;
	

	private var mTimer = null;
	
	private var summary = null;
	private var pressure = null;
    private var temperature = null;
    private var windspeed = null;
    private var windbearing = null;
    private var weathericon = null;

    function initialize() {
    	System.println("initialize");
        View.initialize();

        units =(System.getDeviceSettings().temperatureUnits==System.UNIT_STATUTE) ? "us" : "si";
        //System.println("units in " + units);
        System.println("lang : " + System.getDeviceSettings().systemLanguage);
        makeCurrentWeatherRequest();

        // debug
        summary = "Ciel Nuageux";
        pressure = 1018.7;
        temperature = 5.12;
        windspeed = 7.49;
        windbearing = 290;
        weathericon = "partly-cloudy-day";
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
        //mTimer = new Timer.Timer();     
        //mTimer.start(method(:onTimer), 1000, true);
    }

	// Handler for the timer callback
    function onTimer() {
    	//System.println("onTimer");
    	// for testing
    	//mModel.generateTest();
    	
    	//mModel.updateTimer();
        //WatchUi.requestUpdate();
    }
    
    // Update the view
    function onUpdate(dc) {
    	System.println("onUpdate");
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        // Get and show the current time
        var clockTime = System.getClockTime();
        var timeString = Lang.format("$1$:$2$:$3$", [clockTime.hour, clockTime.min.format("%02d"), clockTime.sec.format("%02d")]);
		
		dc.setColor(Gfx.COLOR_BLACK,Gfx.COLOR_BLACK);
		dc.clear();
		dc.setColor(Gfx.COLOR_BLUE,Gfx.COLOR_TRANSPARENT);
		
		dc.drawText(width/2,25,Gfx.FONT_SMALL,timeString,Gfx.TEXT_JUSTIFY_CENTER);

		if (summary != null) {
            System.println("icon: "+ weathericon);
            drawIcon(dc,width/2,150,weathericon);

            dc.drawText(width/2,50,Gfx.FONT_SMALL,summary,Gfx.TEXT_JUSTIFY_CENTER);
            var _tempstr = "T : " + temperature.format("%.2f") + "°";
            dc.drawText(width/2-60,70,Gfx.FONT_SMALL,_tempstr,Gfx.TEXT_JUSTIFY_CENTER);
            var _pressstr = "P : " + pressure.format("%.2f") + " hPa";
            dc.drawText(width/2+50,70,Gfx.FONT_SMALL,_pressstr,Gfx.TEXT_JUSTIFY_CENTER);
            _tempstr = "W:" + formatHeading(windbearing) + " @ " + formatWindSpeed(windspeed) + "nds " ;
            dc.drawText(width/2-60,90,Gfx.FONT_SMALL,_tempstr,Gfx.TEXT_JUSTIFY_CENTER);
            
            // bf = sq3 (v^2 / 9) en kmh            
            //var _bfs = pow((windspeed*windspeed/9),(1/3)); e, kmh
            var _bfs = (windspeed * 0.5144 /5)+1; //  si < 8, sinon +0
            System.println("speed : "+ _bfs );
        }
  
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

            var appid = getAPIkey();              
        
            // currently,  daily
            var params = {
                    "units" => units,
                    "lang" => "fr",
                    "exclude" => "[minutely,hourly,alerts,flags]"
                    };

            var url = "https://api.darksky.net/forecast/"+appid+"/50.4747,3.061";
    
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
    }

  	function formatWindSpeed(value) {
        if (value == null) {
            return "-";
        }
/* bug here ?
        switch (App.getApp().getProperty("WindSpeedUnits")) {
        case 1: //kmh
          return (value * 3.6).format("%0.f");
        case 2: //mph
          return (value * 2.237).format("%0.f");
        case 3: // nds
            return (value * 0.5144).format("%0.f");
        default: //ms
          return value.format("%.1f");
        }
*/
		return (value * 0.5144).format("%0.f");
        return "-";
    }

   function formatHeading(heading){
        //var sixteenthPI = Math.PI / 16.0;
        //var sixteenthPI = 11.25;
        var index = Math.floor(heading/22.5).toNumber();
        System.println("test en deg : "+ index);
        var rose = ["N","NNE","NE","ENE","E",
                "ESE","SE","SSE","S","SSO","SO",
                "OSO","O","ONO","NO","NNO"];

        return rose[index];
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
                
                //mMessage = "";
                // currently => {visibility=>16.093000, windBearing=>260, precipIntensity=>0, 
                // apparentTemperature=>6.060000, summary=>Ciel Nuageux, precipProbability=>0, humidity=>0.870000, 
                // uvIndex=>0, cloudCover=>0.700000, dewPoint=>7.630000, icon=>partly-cloudy-day,
                // ozone=>343.899994, pressure=>1007.800000, temperature=>9.730000, time=>1580569580, windGust=>17.040001, windSpeed=>9.030000}
                summary = data["currently"]["summary"];
                pressure = data["currently"]["pressure"];
                temperature = data["currently"]["temperature"];
                windspeed = data["currently"]["windSpeed"];
                windbearing = data["currently"]["windBearing"];
                weathericon = data["currently"]["icon"];

                // Print the arguments duplicated and returned 
                var keys = data.keys();
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

//  map icon type to font char
    var iconIds = {   
        "clear-day" => "A", 
        "clear-night" => "B", 
        "rain" => "C", 
        "snow" => "D", 
        "sleet" => "E", 
        "wind" => "F", 
        "fog" => "G", 
        "cloudy" => "H", 
        "partly-cloudy-day" => "I",  
        "partly-cloudy-night" => "J", 
        "hail" => "K", 
        "thunderstorm" => "L", 
        "tornado" => "M"
    }
    
  function getIcon(name) {
    return new WatchUi.Bitmap({:rezId=>Rez.Drawables[iconIds[name]]});
  }

  function drawIcon(dc, x, y, symbol) {
    //var icon = getIcon(symbol);
    //icon.setLocation(x, y);
    //icon.draw(dc);
    dc.drawText(x,y,Gfx.FONT_SMALL,iconIds[symbol],Gfx.TEXT_JUSTIFY_CENTER);
  }
}
