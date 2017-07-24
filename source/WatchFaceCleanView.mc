using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Calendar;
using Toybox.ActivityMonitor as ActivityMonitor;

class WatchFaceCleanView extends Ui.WatchFace {

	// fonts
	var fontRegular;
	var fontBold;
	// settings
	var hourMode24;
	var distanceMetric;
	// icons
	var batteryIcon;
	var batteryLowIcon;
	var msgIcon;
	var distanceIcon;
	var connectionIcon;
	
    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc) {
        // fonts
        fontRegular = Ui.loadResource(Rez.Fonts.font_numbers);
        fontBold = Ui.loadResource(Rez.Fonts.font_numbers_bold);
        // icons
        batteryIcon = Ui.loadResource(Rez.Drawables.batteryIcon);
        batteryLowIcon = Ui.loadResource(Rez.Drawables.batteryLowIcon);
        msgIcon = Ui.loadResource(Rez.Drawables.msgIcon);
		distanceIcon = Ui.loadResource(Rez.Drawables.distanceIcon);
		connectionIcon = Ui.loadResource(Rez.Drawables.connectionIcon);
        // settings
        var settings = Sys.getDeviceSettings();
        hourMode24 = false;
        if(settings.is24Hour) {
        	hourMode24 = true;
        }
        distanceMetric = true;
        if(settings.distanceUnits == settings.UNIT_STATUTE) {
        	distanceMetric = false;
        }
    }

    function onUpdate(dc) {
    	var settings = Sys.getDeviceSettings();
    
        // clear
    	dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_WHITE);
        dc.fillRectangle(0, 0, dc.getWidth(), dc.getHeight());
    	
    	// time
        var time = Sys.getClockTime();
        var h = time.hour;
        if(!hourMode24 and h > 12) {
        	h -= 12;
        }
        var hour = Lang.format("$1$", [h.format("%02d")]);
        var hourWidth = dc.getTextWidthInPixels(hour, fontBold);
        var min = Lang.format("$1$", [time.min.format("%02d")]);
        var minWidth = dc.getTextWidthInPixels(min, fontRegular);
		var x = (dc.getWidth() - hourWidth - minWidth) / 2 + hourWidth;
		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
		dc.drawText(x-2, -2, fontBold, hour, Gfx.TEXT_JUSTIFY_RIGHT);
		dc.drawText(x+2, -2, fontRegular, min, Gfx.TEXT_JUSTIFY_LEFT);
		
		// date and connection
		var cal = Calendar.info(Time.now(), Time.FORMAT_LONG);
        var date = Lang.format("$1$ $2$ $3$", [cal.day_of_week.substring(0, 3).toUpper(), cal.month.toUpper(), cal.day]);
        var dateWidth = dc.getTextWidthInPixels(date, Gfx.FONT_SMALL);
        x = (dc.getWidth() - dateWidth) / 2;
        dc.drawText(x, 10, Gfx.FONT_SMALL, date, Gfx.TEXT_JUSTIFY_LEFT);
		
		x = dc.getWidth() / 2;
		// msgs or disconnect
		if(settings.phoneConnected) {
			dc.drawBitmap(x - 16 - 4, dc.getHeight() - 40, msgIcon);
			dc.drawText(x - 16 - 4 - 6, dc.getHeight() - 43, Gfx.FONT_SMALL, settings.notificationCount.toString(), Gfx.TEXT_JUSTIFY_RIGHT);
		} else {
			dc.drawBitmap(x - 16 - 4, dc.getHeight() - 40, connectionIcon);
		}
		// battery
		x = dc.getWidth() / 2;
		var stats = Sys.getSystemStats();
		var bat = Lang.format("$1$ %", [stats.battery.format("%d")]);
		if(stats.battery <= 10) {
			dc.drawBitmap(x + 4, dc.getHeight() - 40, batteryLowIcon);
			dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
		} else {
			dc.drawBitmap(x + 4, dc.getHeight() - 40, batteryIcon);
		}
		dc.drawText(x + 4 + 16 + 6, dc.getHeight() - 43, Gfx.FONT_SMALL, bat, Gfx.TEXT_JUSTIFY_LEFT);
		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
		// distance and steps
		var act = ActivityMonitor.getInfo();
		dc.drawBitmap(x - 8, dc.getHeight() - 20, distanceIcon);
		var distance = "";
		if(distanceMetric) {
			distance = Lang.format("$1$ km", [(act.distance/100000.0).format("%.1f")]);
		} else {
			distance = Lang.format("$1$ mi", [(act.distance/160934.4).format("%.1f")]);
		}
		dc.drawText(x - 8 - 6, dc.getHeight() - 23, Gfx.FONT_SMALL, distance, Gfx.TEXT_JUSTIFY_RIGHT);
		var steps = Lang.format("$1$/$2$", [act.steps, act.stepGoal]);
		dc.drawText(x + 8 + 6, dc.getHeight() - 23, Gfx.FONT_SMALL, steps, Gfx.TEXT_JUSTIFY_LEFT);
    }

    function onShow() {}
    function onHide() {}
    function onExitSleep() {}
    function onEnterSleep() {}

}
