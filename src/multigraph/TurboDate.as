/*
 * This file is part of Multigraph
 * by Mark Phillips and Devin Eldreth
 *
 * Copyright (c) 2009  University of North Carolina at Asheville
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
  	public var ms:int;

    private static var msInOneDay:int    = 1000 * 60 * 60 * 24;
    private static var msInOneHour:int   = 1000 * 60 * 60;
    private static var msInOneMinute:int = 1000 * 60;
    private static var msInOneSecond:int = 1000;

    private static var month_days_nonleap:Array = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    private static var month_days_leap   :Array = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

    public function TurboDate(year:int, month:int, day:int = 1, hour:int = 0,
                     minute:int = 0, second:int = 0, ms:int = 0) {
      this.year        = year;
      this.month       = month;
      this.day         = day;
      this.hour        = hour;
      this.minute      = minute;
      this.second      = second;
      this.ms          = ms;
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

    public function toUTCDate():Date {
      return new Date(Date.UTC(this.year,this.month,this.day,this.hour,this.minute,this.second,this.ms));
    }

    public function fromUTCDate(date:Date):void {
      this.year   = date.getUTCFullYear();
      this.month  = date.getUTCMonth();
      this.day    = date.getUTCDate();
      this.hour   = date.getUTCHours();
      this.minute = date.getUTCMinutes();
      this.second = date.getUTCSeconds();
      this.ms     = date.getUTCMilliseconds();
    }

    public function addDays(n:int) {
      var d:Date = toUTCDate();
      var newms:Number = d.getTime() + n * msInOneDay;
      d = new Date(newms);
      this.fromUTCDate(d);
    }

    public function addHours(n:int) {
      var d:Date = toUTCDate();
      var newms:Number = d.getTime() + n * msInOneHour;
      d = new Date(newms);
      this.fromUTCDate(d);
    }

    public function addYears(n:int) {
      this.year += n;
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

  }

}

      
