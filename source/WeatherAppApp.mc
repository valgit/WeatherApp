using Toybox.Application;
using Toybox.WatchUi;

class WeatherAppApp extends Application.AppBase {
    private var lattitude = null;
	private var longitude = null;

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
        // get last know info
        var activityInfo = Activity.getActivityInfo();
        if (activityInfo != null) {
            positionInfo = activityInfo.currentLocation;
            quality = activityInfo.currentLocationAccuracy;
        }

        if (positionInfo != null && quality > Position.QUALITY_NOT_AVAILABLE) {
          lattitude = positionInfo.toDegrees()[0];
          longitude = positionInfo.toDegrees()[1];
          System.println("Refresh location " + lattitude + ", " + longitude + " quality : " + quality);
        } else {
            System.println("no know position ?");
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
        lattitude = myLocation[0];
        longitude = myLocation[1];        
        //locationString = lat + "," + long;
        Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
    }

    function getLocation() {
        _locationString = lattitude + "," + longitude;
        return _locationString;
    }
}
