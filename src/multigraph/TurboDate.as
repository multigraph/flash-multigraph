/*
 * This file is part of Multigraph
 * by Mark Phillips and Devin Eldreth
 *
 * Copyright (c) 2009,2010  University of North Carolina at Asheville
 * Licensed under the RENCI Open Source Software License v. 1.0.
 * See http://www.multigraph.org/LICENSE.txt for details.
 */
package multigraph
{
  public class TurboDate {
  	
  	public var year:int;
  	public var month:int;
  	public var day:int;
  	public var hour:int;
  	public var minute:int;
  	public var second:int;
  	public var millisecond:Number;

    public static var millisecondsInOneDay:int         = 1000 * 60 * 60 * 24;
    public static var millisecondsInOneHour:int        = 1000 * 60 * 60;
    public static var millisecondsInOneMinute:int      = 1000 * 60;
    public static var millisecondsInOneSecond:int      = 1000;
    public static var millisecondsInOneDecisecond:int  = 100;
    public static var millisecondsInOneCentisecond:int = 10;

    private static var month_days_nonleap:Array = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    private static var month_days_leap   :Array = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

    public function TurboDate(...args) {
      switch (args.length) {
      case 0: // do nothing if no args passed; leave all fields undefined
        break; 
      case 1: // single argument is UTC milliseconds
        this.fromUTCDate(new Date(args[0]));
        break;
      case 2: //     year,   month
        setFields(args[0], args[1]);
        break;
      case 3: //     year,   month,     day
        setFields(args[0], args[1], args[2]);
        break;
      case 4: //     year,   month,     day,    hour
        setFields(args[0], args[1], args[2], args[3]);
        break;
      case 5: //     year,   month,     day,    hour,  minute
        setFields(args[0], args[1], args[2], args[3], args[4]);
        break;
      case 6: //     year,   month,     day,    hour,  minute,  second
        setFields(args[0], args[1], args[2], args[3], args[4], args[5]);
        break;
      default: //    year,   month,     day,    hour,  minute,  second, millisecond
        setFields(args[0], args[1], args[2], args[3], args[4], args[5], args[6]);
        break;
      }
    }

    public function setFields(year:int, month:int = 0, day:int = 1, hour:int = 0,
                              minute:int = 0, second:int = 0, millisecond:Number = 0) {
      this.year         = year;
      this.month        = month;
      this.day          = day;
      this.hour         = hour;
      this.minute       = minute;
      this.second       = second;
      this.millisecond = millisecond;
    }


    public function clone():TurboDate {
      return new TurboDate(this.year, this.month, this.day, this.hour, this.minute, this.second, this.millisecond);
    }

    public function toUTCDate():Date {
      return new Date(getUTCMilliseconds());
    }

    public function getUTCMilliseconds():Number {
      return Date.UTC(this.year,this.month,this.day,this.hour,this.minute,this.second,this.millisecond);
    }

    public function fromUTCDate(date:Date):void {
      this.year         = date.getUTCFullYear();
      this.month        = date.getUTCMonth();
      this.day          = date.getUTCDate();
      this.hour         = date.getUTCHours();
      this.minute       = date.getUTCMinutes();
      this.second       = date.getUTCSeconds();
      this.millisecond  = date.getUTCMilliseconds();
    }

    public function addYears(n:int) {
      this.year += n;
    }

    public function addMonths(n:int) {
      var ym:int = 12*this.year + this.month + n;
      this.month = ym % 12;
      this.year  = Math.floor( ym / 12 );
      var ndays:int = numDaysInCurrentMonth();
      if (this.day > ndays) {
        this.day = ndays;
      }
    }

    public function addDays(n:int) {
      addMilliseconds(n * millisecondsInOneDay);
    }

    public function addHours(n:int) {
      addMilliseconds(n * millisecondsInOneHour);
    }

    public function addMinutes(n:int) {
      addMilliseconds(n * millisecondsInOneMinute);
    }

    public function addSeconds(n:int) {
      addMilliseconds(n * millisecondsInOneSecond);
    }

    public function addMilliseconds(n:Number) {
      var d:Date = toUTCDate();
      var newmilliseconds:Number = d.getTime() + n;
      d = new Date(newmilliseconds);
      this.fromUTCDate(d);
    }

    public function numDaysInCurrentMonth() {
      if (isLeapYear(this.year)) {
        return month_days_leap[this.month];
      }
      return month_days_nonleap[this.month];
    }

    private static function isLeapYear(y:int) {
      return (y%4) ?  0 : (!(y%100) && (y%400)) ?  0 : 1;
    }

    // return the "first tick" date at or after this date, with ticks starting at "start"
    // and occurring every daySpacing days
    public function firstMillisecondSpacingTickAtOrAfter(start:TurboDate, msSpacing:Number):TurboDate {
      var startms:Number = start.getUTCMilliseconds();
      var tms:Number = this.getUTCMilliseconds() - startms;
      var d:Number = Math.floor( tms / msSpacing );
      if (tms % msSpacing != 0) {
        ++d;
      }
      return new TurboDate(startms + d * msSpacing)
    }

    public function firstCentisecondSpacingTickAtOrAfter(start:TurboDate, centisecondSpacing:Number):TurboDate {
      return firstMillisecondSpacingTickAtOrAfter(start, centisecondSpacing * millisecondsInOneCentisecond);
    }

    public function firstDecisecondSpacingTickAtOrAfter(start:TurboDate, decisecondSpacing:Number):TurboDate {
      return firstMillisecondSpacingTickAtOrAfter(start, decisecondSpacing * millisecondsInOneDecisecond);
    }

    public function firstSecondSpacingTickAtOrAfter(start:TurboDate, secondSpacing:Number):TurboDate {
      return firstMillisecondSpacingTickAtOrAfter(start, secondSpacing * millisecondsInOneSecond);
    }

    public function firstMinuteSpacingTickAtOrAfter(start:TurboDate, minuteSpacing:Number):TurboDate {
      return firstMillisecondSpacingTickAtOrAfter(start, minuteSpacing * millisecondsInOneMinute);
    }

    public function firstHourSpacingTickAtOrAfter(start:TurboDate, hourSpacing:Number):TurboDate {
      return firstMillisecondSpacingTickAtOrAfter(start, hourSpacing * millisecondsInOneHour);
    }

    public function firstDaySpacingTickAtOrAfter(start:TurboDate, daySpacing:Number):TurboDate {
      return firstMillisecondSpacingTickAtOrAfter(start, daySpacing * millisecondsInOneDay);
    }

    // return the "first tick" date at or after this date, with ticks starting at "start"
    // and occurring every monthSpacing months
    public function firstMonthSpacingTickAtOrAfter(start:TurboDate, monthSpacing:int):TurboDate {
      var tmonths:int = 12 * (this.year - start.year) + (this.month - start.month);
      var d:int = Math.floor( tmonths / monthSpacing );

      if (tmonths % monthSpacing != 0) { ++d; }
      else if (this.day>start.day) { ++d; }
      else if (this.day==start.day && this.hour>start.hour) { ++d; }
      else if (this.day==start.day && this.hour==start.hour && this.hour>start.hour) { ++d; }
      else if (this.day==start.day && this.hour==start.hour && this.hour==start.hour && this.minute>start.minute) { ++d; }
      else if (this.day==start.day && this.hour==start.hour && this.hour==start.hour && this.minute==start.minute && this.second==start.second && this.millisecond>start.millisecond) { ++d; }

      var firstTick:TurboDate = start.clone();
      firstTick.addMonths(d * monthSpacing);
      return firstTick;
    }

    // return the "first tick" date at or after this date, with ticks starting at "start"
    // and occurring every yearSpacing years
    public function firstYearSpacingTickAtOrAfter(start:TurboDate, yearSpacing:int):TurboDate {
      return firstMonthSpacingTickAtOrAfter(start, yearSpacing*12);
    }

  }

}

      
