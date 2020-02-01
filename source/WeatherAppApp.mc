using Toybox.Application;
using Toybox.WatchUi;

class WeatherAppApp extends Application.AppBase {
    hidden var lattitude = null;
	hidden var longitude = null;

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
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
        } else {
            Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
        }
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    // Return the initial view of your application here
    function getInitialView() {
        return [ new WeatherAppView(), new WeatherAppDelegate() ];
    }

    function phoneConnected() {
        return System.getDeviceSettings().phoneConnected;
    }

    function canDoBackground() {
        return (Toybox.System has :ServiceDelegate);
    }

    function onPosition(info) {
        var myLocation = info.position.toDegrees();
        var lattitude = myLocation[0];
        var longitude = myLocation[1];        
        //locationString = lat + "," + long;
        Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
    }

}
