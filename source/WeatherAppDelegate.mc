using Toybox.WatchUi;

class WeatherAppDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new WeatherAppMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

}