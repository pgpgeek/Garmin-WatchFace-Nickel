using Toybox.System;
using Toybox.WatchUi as Ui;
using Toybox.SensorHistory;
using Toybox.Lang;
using Toybox.Graphics;
using Toybox.Time;
using Toybox.Time.Gregorian as Calendar;
using Toybox.ActivityMonitor as Monitor;
using Toybox.Math as Math;

class NickelWatchView extends Ui.WatchFace {

    var lowPowerMode = false;
    var lowPowerModeMin = null; // minutes when low power mode got set
    
    function initialize() {
        WatchFace.initialize();
    }
    	
    // Load your resources here
    function onLayout(dc) {
    	setLayout(Rez.Layouts.WatchFace(dc));
    }
    
    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }
    
    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

	// The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
	    lowPowerMode = false;
	    WatchUi.requestUpdate();     
    }

	// Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
	    lowPowerMode = true;
	    WatchUi.requestUpdate();
    }
    
    // Update the view
    function onUpdate(dc) {

        var clockTime  = System.getClockTime();

 		if(lowPowerMode) {
 			if(lowPowerModeMin != null && lowPowerModeMin == clockTime.min) {
 				return;
 			}
 			lowPowerModeMin = clockTime.min;
 		} else {
 			lowPowerModeMin = null;
 		}	
 		
 		refreshDisplay(dc, clockTime);		                
    }

	
	function getIteratorStep() {
	    var steps = ActivityMonitor.getInfo().steps;
        return steps != null ? steps.format("%d") : "--" ;
	}
    
    function getIteratorKcal() {
        var calories = ActivityMonitor.getInfo().calories;
        var caloriesText = "--";
        if (calories != null) {
            caloriesText = calories.format("%d");
        }
        return caloriesText;
    }


    
    function displayStaticTimeIndicator(dc, x, y) {
        var angleHour, angleMin, hour, color, size;
        var time = 1;
        var minute = 1;  

        dc.setPenWidth(1);
        dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(x, y, x-1); 
        while (time <= 12) {
 		    angleHour = ((time * 5.0) / 60.0) * Math.PI * 2;
            color = Graphics.COLOR_ORANGE;
            size  = Graphics.FONT_MEDIUM;
            if ([12, 3, 6, 9].indexOf(time) == -1 ){
                color = Graphics.COLOR_WHITE;
                size  = Graphics.FONT_TINY;
            }
            dc.setColor(color, Graphics.COLOR_TRANSPARENT); 

            drawHandRound(dc, x, y, angleHour, (x - 14), 1, 2, size, time); 
            time += 1;
        }

        while (minute <= 60) {
 		    angleMin = ( minute / 60.0) * Math.PI * 2;
            color = Graphics.COLOR_WHITE;
            if ([3, 7, 13, 17, 23, 27, 33, 37, 43, 47, 53, 57].indexOf(minute) != -1 ){
                drawHandRoundBullet(dc, x, y, angleMin, (x - 14), 1, 1); 
            }
            minute += 1;
        }

    }

    /*
    *
    *   Display Battery Status
    *
    */
    function displayBattery(dc, x, y) {
        dc.setPenWidth(1);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
	    drawBattery(dc, System.getSystemStats().battery, x - 14, y-5, 25, 10);

		dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(x, y,24);  
    }

    /*
    *
    *   Display Steps Status
    *
    */
    function displaySteps(dc, x, y) {
        var steps;
        dc.setPenWidth(1);
        dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(x, y + 20, 25);  

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        steps = getIteratorStep();
        dc.drawText(
            x,
            y,
            Graphics.FONT_XTINY,
            steps + ((steps.toNumber() > 1) ? "\nSteps" : "\nStep"),
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }

    /*
    *
    *   Display Kcal Status
    *
    */
    function displayKcals(dc, x, y) {
        var calories;
        dc.setPenWidth(1);
        dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(x, y + 20, 25);  

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        calories = getIteratorKcal();
        dc.drawText(
            x,
            y,
            Graphics.FONT_XTINY,
            calories + ((calories.toNumber() > 1) ? "\nKcals" : "\nKcal"),
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }

    /*
    *
    *   Display Day
    *
    */

    function displayDay(dc, x, y) {
        var calendar = Calendar.info(Time.now(), Time.FORMAT_LONG);
        var dateString = Lang.format("$1$ $2$", [calendar.day_of_week, calendar.day]);
        dc.setPenWidth(1);
        dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(x, y, 24);  

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            x,
            y-8,
            Graphics.FONT_XTINY,
            dateString,
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }

    /*
    *
    *
    *   Display Logo
    *
    *
    */
    function displayLogo(dc, x, y) {
        var image  = Ui.loadResource(Rez.Drawables.nickel);
        dc.drawBitmap(x, y, image);
    }

    function refreshDisplay(dc, clockTime) {
    	// refresh
 		View.onUpdate(dc);
 		
 		var width      = dc.getWidth();
        var height     = dc.getHeight();
        
        // --- TIME ---
        var angleHour, angleMin, angleSec, image;
 		var hour = ((clockTime.hour % 12) * 60.0 + clockTime.min) / 60.0;        
        angleHour = ((hour * 5.0) / 60.0) * Math.PI * 2;
        angleMin = ( clockTime.min / 60.0) * Math.PI * 2;
        angleSec = ( clockTime.sec / 60.0) * Math.PI * 2;


        var adjustWatchPosWithUp = width * 0.25;
        var adjustWatchPosHeightUp = width * 0.10;

        var adjustWatchPosWithDown = width * 0.17;
        var adjustWatchPosHeightDown = width * 0.08;
        System.println(height);
        // --- Display Time Indicators ---
        displayStaticTimeIndicator(dc, width / 2, height /2);
        // --- Day ---
		displayDay(dc,     width/2 - adjustWatchPosWithUp, height/2 - adjustWatchPosHeightUp);
	    // --- Battery ---
        displayBattery(dc, width / 2 + adjustWatchPosWithUp, height / 2 - adjustWatchPosHeightUp);

        // --- Step ---
        displaySteps(dc,    width /2 + adjustWatchPosWithDown, (height / 2) + adjustWatchPosHeightDown );
        // --- Kcal ---
        displayKcals(dc,    width /2- adjustWatchPosWithDown, (height / 2) + adjustWatchPosHeightDown );
        // -- Logo --- 
        displayLogo(dc, (width / 2)-40, (height / 2) /3);

        drawHand(dc, width/2, height/2, angleHour, 0, 45, 1, 3, Graphics.COLOR_WHITE); 	// hours
    	drawHand(dc, width/2, height/2, angleMin,  0, 70, 1, 3, Graphics.COLOR_WHITE);		// minutes
    	if(!lowPowerMode) {   
            drawHand(dc, width/2, height/2, angleSec, 0, 80, 1, 1, Graphics.COLOR_ORANGE);		// minutes
		}
		        

    }
    
    function drawWithRotate(dc, coords, cos, sin, centerX, centerY) {
    	var coordsRotated = new [coords.size()];

		for (var i = 0; i < coords.size(); i += 1)
        {
            var x = (coords[i][0] * cos) - (coords[i][1] * sin);
            var y = (coords[i][0] * sin) + (coords[i][1] * cos);
            coordsRotated[i] = [ centerX+x, centerY+y];
        }
        dc.fillPolygon(coordsRotated);
    }

    function drawHand(dc, centerX, centerY, angle, distIn, distOut, radius, width, color) {
		
		// Math
		var cos = Math.cos(angle);
		var sin = Math.sin(angle);
		
		// 2 x Arcs		
		var x1 = centerX + (distOut * sin);
        var y1 = centerY - (distOut * cos);
        var x2 = centerX + (distIn * sin);
        var y2 = centerY - (distIn * cos);
                 
        dc.setColor(color, Graphics.COLOR_TRANSPARENT); 
        dc.setPenWidth(width);
              
        var angleArcStart = - ((angle * 360 / (2 * Math.PI)) + 90); 
        dc.drawArc(x1, y1, radius, Graphics.ARC_CLOCKWISE, angleArcStart - 90, angleArcStart + 90);
        dc.drawArc(x2, y2, radius, Graphics.ARC_CLOCKWISE, angleArcStart + 90, angleArcStart + 270);
        
        var length = distOut-distIn+1;
        var coords = [[radius + width/2, -distIn], [radius + width/2, -distIn-length], [radius - width/2, -distIn-length], [radius - width/2, -distIn]];
        drawWithRotate(dc, coords, cos, sin, centerX, centerY);
        
        coords = [[-radius + width/2, -distIn], [-radius + width/2, -distIn-length], [-radius - width/2, -distIn-length], [-radius - width/2, -distIn]];
        drawWithRotate(dc, coords, cos, sin, centerX, centerY);
    }

    function drawHandRound(dc, centerX, centerY, angle, dist, radius, width, size, time) {
        dc.setPenWidth(width);
    
		var cos = Math.cos(angle);
		var sin = Math.sin(angle);
		var x = centerX + (dist * sin);
        var y = centerY - (dist * cos);

        dc.drawText(
	        x,
	        y - 15,
	        size,
	        time,
	        Graphics.TEXT_JUSTIFY_CENTER
	    );

        //dc.drawCircle(x,y,radius);        
    }
    
    function drawHandRoundBullet(dc, centerX, centerY, angle, dist, radius, width) {
        dc.setPenWidth(width);
    
		var cos = Math.cos(angle);
		var sin = Math.sin(angle);
		var x = centerX + (dist * sin);
        var y = centerY - (dist * cos);
        
        dc.drawCircle(x,y,radius);        
    }


    function drawBattery(dc, batteryLevel, xStart, yStart, width, height) {                
        var color = Graphics.COLOR_WHITE;


        dc.setColor(color, Graphics.COLOR_TRANSPARENT);

        dc.setPenWidth(1);
        dc.drawRectangle(xStart, yStart, width+ 2, height);
        dc.fillRectangle(xStart + width +2, yStart + 2, 2, height -3); 
        if (batteryLevel <= 20) {
            color = Graphics.COLOR_DK_RED;
        }
        else if (batteryLevel <= 40) {
            color = Graphics.COLOR_YELLOW;
        }
        else  {
            color = Graphics.COLOR_ORANGE;
        }
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
       	
        dc.fillRectangle(xStart + 2, yStart + 2, (width-2) * batteryLevel / 100, height - 4);
    }

}
