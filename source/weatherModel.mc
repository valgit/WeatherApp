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
