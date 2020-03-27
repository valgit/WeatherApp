/*
 	Copyright (c) 2020, vbrasseur at gmail dot com
	All rights reserved.
	
	Redistribution and use in source and binary forms, with or without
	modification, are permitted provided that the following conditions are met:
	    * Redistributions of source code must retain the above copyright
	      notice, this list of conditions and the following disclaimer.
	    * Redistributions in binary form must reproduce the above copyright
	      notice, this list of conditions and the following disclaimer in the
	      documentation and/or other materials provided with the distribution.
	    * Neither the name of the <organization> nor the
	      names of its contributors may be used to endorse or promote products
	      derived from this software without specific prior written permission.
	
	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
	ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
	DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
	DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
	(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
	ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

/*
 * Weather Model
 * comm tools to Darksky API
 */
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Communications;
using Toybox.Application as App;

using Toybox.Math; 

using Toybox.Time;
using Toybox.Time.Gregorian;

class weatherModel {
    private var units = null;
    private var latitude = null;
	private var longitude = null;

    private var _status = null;

	private var summary = null;
	private var pressure = null;
    private var temperature = null;
    private var windspeed = null;
    private var windbearing = null;
    private var weathericon = null;
	private var apparentTemperature = null;
    private var proba = null;
    private var writer = null;

    private var hourly = null;

    function initialize() {
    	System.println("weather model initialize");
        latitude = 50.4747;
        longitude = 3.061;
        units =(System.getDeviceSettings().temperatureUnits==System.UNIT_STATUTE) ? "us" : "si";
    }

    function setPosition(_latitude,_longitude) {
        latitude = _latitude;
        longitude = _longitude;
    }

    function setLocation(lon,lat) {
        latitude = lat;
        longitude = lon;
    }

   function freshness() {
        var freshen = null;
        
        var lastFetchTime = getLastRefresh();
        if (lastFetchTime != null) {
            var _now = Time.now().value();
        	//freshen = _now - lastFetchTime;
            //System.println("now h : "+getHour(_now)+" / last : "+getHour(lastFetchTime));
            freshen = getHour(_now) - getHour(lastFetchTime);            
        } else {
        	freshen = 24;
        }
        return freshen;
    }
    
    function makeCurrentWeatherRequest() {
            System.println("makeCurrentWeatherRequest");
            if (System.getDeviceSettings().phoneConnected) {

                var appid = getAPIkey();              
            
                // currently,  daily, hourly
                var params = {
                        "units" => units,
                        "lang" => "fr",
                        "exclude" => "[minutely,hourly,daily,alerts,flags]"
                        };

                var url = "https://api.darksky.net/forecast/"+appid+"/"+latitude+","+longitude;
        
                var options = {
                        :methods => Communications.HTTP_REQUEST_METHOD_GET,
                        :headers => {"Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED},
                        :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
                };
            
                Communications.makeWebRequest(
                        url,
                        params,
                        options,
                        method(:receiveCurrentWeather));
                _status = 1;
            } else {
                System.println("no phone connection");
            }        
        WatchUi.requestUpdate();
    }   

    function makeHourlyWeatherRequest() {
 		System.println("makeCurrentWeatherRequest");
        if (System.getDeviceSettings().phoneConnected) {

            var appid = getAPIkey();              
        
            // currently,  daily, hourly
            var params = {
                    "units" => units,
                    "lang" => "fr",
                    "exclude" => "[minutely,daily,alerts,flags]"
                    };

            var url = "https://api.darksky.net/forecast/"+appid+"/"+latitude+","+longitude;
    
            var options = {
                    :methods => Communications.HTTP_REQUEST_METHOD_GET,
                    :headers => {"Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED},
                    :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
            };
        
            Communications.makeWebRequest(
                    url,
                    params,
                    options,
                    method(:receiveHourlyWeather));
            _status = 1;
        } else {
            System.println("no phone connection");
        }        
        WatchUi.requestUpdate();
    }


	 // parse JSON weather data    
    function parseCurrentWeather(data) {
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
		proba = data["currently"]["precipProbability"];
		apparentTemperature = data["currently"]["apparentTemperature"];				   
    
    }
	

    function receiveCurrentWeather(responseCode, data) {
   		System.println("receiveCurrentWeather");
        if (responseCode == 200) {
             if (data instanceof Lang.String && data.equals("Forbidden")) {
                var dict = { "msg" => "WRONG KEY" };
                System.println("wrong API key");
                //Background.exit(dict);
            } else {
                if (data instanceof Dictionary) {                                    
                    // TODO: persist receive data                  
                    var lastData = data;
                    var lastFetchTime = Time.now().value();
                    //setLastData(lastData);
                    setLastRefresh(lastFetchTime);
                    _status = 0;
                    parseCurrentWeather(data);
                }   
            }
        } else {
            System.println("Current weather response code " + responseCode);
            //maybe null !  + " message " + data.get("message"));   
            //App.Storage.deleteValue(  
            var lastFetchTime = null;                  
            setLastRefresh(lastFetchTime);
        }
        WatchUi.requestUpdate();
    }

  	// parse JSON weather data
    function parseHourlyWeather(data) {
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
		proba = data["currently"]["precipProbability"];
		apparentTemperature = data["currently"]["apparentTemperature"];
				 
        // check hourly data
        // TODO: better way
        // first slot is actual time then next 24 hours
        System.println("next : "+data["hourly"]["summary"]);
        var _hdata = data["hourly"]["data"]; // table ?
        hourly = data["hourly"]["data"];

        /*
        var _time=new Time.Moment(data["hourly"]["time"]);
        var _current = Gregorian.info(_time, Time.FORMAT_MEDIUM);
        System.println(_current.hour+":"+_current.min);
        */
        // Print the arguments duplicated and returned 
        /*
        var keys = _hdata.keys();
        for( var i = 0; i < keys.size(); i++ ) {
            //mMessage += Lang.format("$1$: $2$\n", [keys[i], args[keys[i]]]);
            System.println(keys[i] + " => " + data[keys[i]]);
        }
        */

        var _time;
        var _current;
        for(var i = 0; i<25;i++) {
            //System.println(i+" : "+_hdata[i]);
            _time=new Time.Moment(_hdata[i]["time"]);
            _current = Gregorian.info(_time, Time.FORMAT_MEDIUM);
            System.println(i + " => "+_current.day + " - "+_current.hour+":"+_current.min);
            System.println("icon: " + _hdata[i]["icon"] + " T: " +_hdata[i]["temperature"]+ " Pre : "+(_hdata[i]["precipProbability"] * 100)+
            	" summary: " + _hdata[i]["summary"]);
        }
    
    }


    function receiveHourlyWeather(responseCode, data) {
   		System.println("receiveHourlyWeather");
        if (responseCode == 200) {
             if (data instanceof Lang.String && data.equals("Forbidden")) {
                //var dict = { "msg" => "WRONG KEY" };
                System.println("wrong API key");
                //Background.exit(dict);
            } else {
                if (data instanceof Dictionary) {                                    
                    // TODO: persist receive data
                    var lastData = data;
                    var lastFetchTime = Time.now().value();
                    //setLastData(lastData);
                    setLastRefresh(lastFetchTime);
                    _status = 0;
                    parseHourlyWeather(data);
                }   
            }
        } else {
            System.println("Current weather response code " + responseCode);
            //maybe null !  + " message " + data.get("message"));   
            //App.Storage.deleteValue(      
            var lastFetchTime = null;                  
            setLastRefresh(lastFetchTime);
        }
        WatchUi.requestUpdate();
    }

}
