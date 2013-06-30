
#
# Specifying rufus-scheduler
#
# Sat Mar 21 12:55:27 JST 2009
#

#require 'spec_base'
require "spec_helper"
require "whedon/schedule"

describe Whedon::Schedule do
  #
  # See spec_helper.rb for definitions for the class & methods
  # used in these tests. This includes Ex, local, utc, cl,
  # match, no_match, and compare

  describe '.new' do

    it 'interprets cron strings correctly' do

      compare '* * * * *', [ [0], nil, nil, nil, nil, nil, nil, nil ]
      compare '10-12 * * * *', [ [0], [10, 11, 12], nil, nil,  nil, nil, nil, nil ]
      compare '* * * * sun,mon', [ [0], nil, nil, nil, nil, [0, 1], nil, nil ]
      compare '* * * * mon-wed', [ [0], nil, nil, nil, nil, [1, 2, 3], nil, nil ]
      compare '* * * * 7', [ [0], nil, nil, nil, nil, [0], nil, nil ]
      compare '* * * * 0', [ [0], nil, nil, nil, nil, [0], nil, nil ]
      compare '* * * * 0,1', [ [0], nil, nil, nil, nil, [0,1], nil, nil ]
      compare '* * * * 7,1', [ [0], nil, nil, nil, nil, [0,1], nil, nil ]
      compare '* * * * 7,0', [ [0], nil, nil, nil, nil, [0], nil, nil ]
      compare '* * * * sun,2-4', [ [0], nil, nil, nil, nil, [0, 2, 3, 4], nil, nil ]

      compare '* * * * sun,mon-tue', [ [0], nil, nil, nil, nil, [0, 1, 2], nil, nil ]

      compare '* * * * * *', [ nil, nil, nil, nil, nil, nil, nil, nil ]
      compare '1 * * * * *', [ [1], nil, nil, nil, nil, nil, nil, nil ]
      compare '7 10-12 * * * *', [ [7], [10, 11, 12], nil, nil, nil, nil, nil, nil ]
      compare '1-5 * * * * *', [ [1,2,3,4,5], nil, nil, nil, nil, nil, nil, nil ]

      compare '0 0 1 1 *', [ [0], [0], [0], [1], [1], nil, nil, nil ]

      compare '0 23-24 * * *', [ [0], [0], [23, 0], nil, nil, nil, nil, nil ]
        #
        # as reported by Aimee Rose in
        # https://github.com/jmettraux/rufus-scheduler/issues/56

      compare '0 23-2 * * *', [ [0], [0], [23, 0, 1, 2], nil, nil, nil, nil, nil ]
    end

    it 'rejects invalid weekday expressions' do

      lambda { cl '0 17 * * MON_FRI' }.should raise_error
        # underline instead of dash

      lambda { cl '* * * * 9' }.should raise_error
      lambda { cl '* * * * 0-12' }.should raise_error
      lambda { cl '* * * * BLABLA' }.should raise_error
    end

    it 'rejects invalid cronlines' do

      lambda { cl '* nada * * 9' }.should raise_error(Whedon::ParseError)
    end

    it 'interprets cron strings with TZ correctly' do

      compare '* * * * * EST', [ [0], nil, nil, nil, nil, nil, nil, 'EST' ]
      compare '* * * * * * EST', [ nil, nil, nil, nil, nil, nil, nil, 'EST' ]

      lambda { cl '* * * * * NotATimeZone' }.should raise_error
      lambda { cl '* * * * * * NotATimeZone' }.should raise_error
    end

    it 'interprets cron strings with / (slashes) correctly' do

      compare(
        '0 */2 * * *',
        [ [0], [0], (0..11).collect { |e| e * 2 }, nil, nil, nil, nil, nil ])
      compare(
        '0 7-23/2 * * *',
        [ [0], [0], (7..23).select { |e| e.odd? }, nil, nil, nil, nil, nil ])
      compare(
        '*/10 * * * *',
        [ [0], [0, 10, 20, 30, 40, 50], nil, nil, nil, nil, nil, nil ])
    end

    it 'does not support ranges for monthdays (sun#1-sun#2)' do

      lambda {
        Whedon::Schedule.new('* * * * sun#1-sun#2')
      }.should raise_error(Whedon::ParseError)
    end

    it 'accepts items with initial 0' do

      compare '09 * * * *', [ [0], [9], nil, nil, nil, nil, nil, nil ]
      compare '09-12 * * * *', [ [0], [9, 10, 11, 12], nil, nil, nil, nil, nil, nil ]
      compare '07-08 * * * *', [ [0], [7, 8], nil, nil, nil, nil, nil, nil ]
      compare '* */08 * * *', [ [0], nil, [0, 8, 16], nil, nil, nil, nil, nil ]
      compare '* */07 * * *', [ [0], nil, [0, 7, 14, 21], nil, nil, nil, nil, nil ]
      compare '* 01-09/04 * * *', [ [0], nil, [1, 5, 9], nil, nil, nil, nil, nil ]
      compare '* * * * 06', [ [0], nil, nil, nil, nil, [6], nil, nil ]
    end

    it 'ignores duplicates by default' do

      compare '* * L,L * *', [[0], nil, nil, ['L'], nil, nil, nil, nil ]
      compare '*/20,40 * * * *', [ [0], [0, 20, 40 ], nil, nil, nil, nil, nil, nil ]
    end

    it 'raises an error for duplicates when configured to do so' do

      lambda { Ex.new('* * L,L * *') }.should raise_error(Whedon::ParseError)
    end

    it 'interprets cron strings with L correctly' do

      compare '* * L * *', [[0], nil, nil, ['L'], nil, nil, nil, nil ]
      compare '* * 2-5,L * *', [[0], nil, nil, [2,3,4,5,'L'], nil, nil, nil, nil ]
      compare '* * */8,L * *', [[0], nil, nil, [1,9,17,25,'L'], nil, nil, nil, nil ]
    end

    it 'does not support ranges for L' do

      lambda { cl '* * 15-L * *'}.should raise_error(Whedon::ParseError)
      lambda { cl '* * L/4 * *'}.should raise_error(Whedon::ParseError)
    end

    it 'raises if L is used for something else than days' do

      lambda { cl '* L * * *'}.should raise_error(Whedon::ParseError)
    end

    it 'raises for out of range input' do

      lambda { cl '60-62 * * * *'}.should raise_error(Whedon::ParseError)
      lambda { cl '62 * * * *'}.should raise_error(Whedon::ParseError)
      lambda { cl '60 * * * *'}.should raise_error(Whedon::ParseError)
      lambda { cl '* 25-26 * * *'}.should raise_error(Whedon::ParseError)
      lambda { cl '* 25 * * *'}.should raise_error(Whedon::ParseError)
        #
        # as reported by Aimee Rose in
        # https://github.com/jmettraux/rufus-scheduler/pull/58
    end
  end

  describe '#next_time' do

    def nt(cronline, now)
      Whedon::Schedule.new(cronline).next_time(now)
    end

    it 'computes the next occurence correctly' do

      now = Time.at(0).getutc # Thu Jan 01 00:00:00 UTC 1970

      nt('* * * * *', now).should == now + 60
      nt('* * * * sun', now).should == now + 259200
      nt('* * * * * *', now).should == now + 1
      nt('* * 13 * fri', now).should == now + 3715200

      nt('10 12 13 12 *', now).should == now + 29938200
        # this one is slow (1 year == 3 seconds)
        #
        # historical note:
        # (comment made in 2006 or 2007, the underlying libs got better and
        # that slowness is gone)

      nt('0 0 * * thu', now).should == now + 604800

      nt('0 0 * * *', now).should == now + 24 * 3600
      nt('0 24 * * *', now).should == now + 24 * 3600

      now = local(2008, 12, 31, 23, 59, 59, 0)

      nt('* * * * *', now).should == now + 1
    end

    it 'computes the next occurence correctly in UTC (TZ not specified)' do

      now = utc(1970, 1, 1)

      nt('* * * * *', now).should == utc(1970, 1, 1, 0, 1)
      nt('* * * * sun', now).should == utc(1970, 1, 4)
      nt('* * * * * *', now).should == utc(1970, 1, 1, 0, 0, 1)
      nt('* * 13 * fri', now).should == utc(1970, 2, 13)

      nt('10 12 13 12 *', now).should == utc(1970, 12, 13, 12, 10)
        # this one is slow (1 year == 3 seconds)
      nt('* * 1 6 *', now).should == utc(1970, 6, 1)

      nt('0 0 * * thu', now).should == utc(1970, 1, 8)
    end

    it 'computes the next occurence correctly in local TZ (TZ not specified)' do

      now = local(1970, 1, 1)

      nt('* * * * *', now).should == local(1970, 1, 1, 0, 1)
      nt('* * * * sun', now).should == local(1970, 1, 4)
      nt('* * * * * *', now).should == local(1970, 1, 1, 0, 0, 1)
      nt('* * 13 * fri', now).should == local(1970, 2, 13)

      nt('10 12 13 12 *', now).should == local(1970, 12, 13, 12, 10)
        # this one is slow (1 year == 3 seconds)
      nt('* * 1 6 *', now).should == local(1970, 6, 1)

      nt('0 0 * * thu', now).should == local(1970, 1, 8)
    end

    it 'computes the next occurence correctly in UTC (TZ specified)' do

      zone = 'Europe/Stockholm'
      tz = TZInfo::Timezone.get(zone)
      now = tz.local_to_utc(local(1970, 1, 1))
        # Midnight in zone, UTC

      nt("* * * * * #{zone}", now).should == utc(1969, 12, 31, 23, 1)
      nt("* * * * sun #{zone}", now).should == utc(1970, 1, 3, 23)
      nt("* * * * * * #{zone}", now).should == utc(1969, 12, 31, 23, 0, 1)
      nt("* * 13 * fri #{zone}", now).should == utc(1970, 2, 12, 23)

      nt("10 12 13 12 * #{zone}", now).should == utc(1970, 12, 13, 11, 10)
      nt("* * 1 6 * #{zone}", now).should == utc(1970, 5, 31, 23)

      nt("0 0 * * thu #{zone}", now).should == utc(1970, 1, 7, 23)
    end

    #it 'computes the next occurence correctly in local TZ (TZ specified)' do
    #  zone = 'Europe/Stockholm'
    #  tz = TZInfo::Timezone.get(zone)
    #  now = tz.local_to_utc(utc(1970, 1, 1)).localtime
    #    # Midnight in zone, local time
    #  nt("* * * * * #{zone}", now).should == local(1969, 12, 31, 18, 1)
    #  nt("* * * * sun #{zone}", now).should == local(1970, 1, 3, 18)
    #  nt("* * * * * * #{zone}", now).should == local(1969, 12, 31, 18, 0, 1)
    #  nt("* * 13 * fri #{zone}", now).should == local(1970, 2, 12, 18)
    #  nt("10 12 13 12 * #{zone}", now).should == local(1970, 12, 13, 6, 10)
    #  nt("* * 1 6 * #{zone}", now).should == local(1970, 5, 31, 19)
    #  nt("0 0 * * thu #{zone}", now).should == local(1970, 1, 7, 18)
    #end

    it 'computes the next time correctly when there is a sun#2 involved' do

      nt('* * * * sun#1', local(1970, 1, 1)).should == local(1970, 1, 4)
      nt('* * * * sun#2', local(1970, 1, 1)).should == local(1970, 1, 11)

      nt('* * * * sun#2', local(1970, 1, 12)).should == local(1970, 2, 8)
    end

    it 'computes the next time correctly when there is a sun#2,sun#3 involved' do

      nt('* * * * sun#2,sun#3', local(1970, 1, 1)).should == local(1970, 1, 11)
      nt('* * * * sun#2,sun#3', local(1970, 1, 12)).should == local(1970, 1, 18)
    end

    it 'understands sun#L' do

      nt('* * * * sun#L', local(1970, 1, 1)).should == local(1970, 1, 25)
    end

    it 'understands sun#-1' do

      nt('* * * * sun#-1', local(1970, 1, 1)).should == local(1970, 1, 25)
    end

    it 'understands sun#-2' do

      nt('* * * * sun#-2', local(1970, 1, 1)).should == local(1970, 1, 18)
    end

    it 'computes the next time correctly when "L" (last day of month)' do

      nt('* * L * *', lo(1970, 1, 1)).should == lo(1970, 1, 31)
      nt('* * L * *', lo(1970, 2, 1)).should == lo(1970, 2, 28)
      nt('* * L * *', lo(1972, 2, 1)).should == lo(1972, 2, 29)
      nt('* * L * *', lo(1970, 4, 1)).should == lo(1970, 4, 30)
    end
  end

  describe '#previous_time' do

    def pt(cronline, now)
      Whedon::Schedule.new(cronline).previous_time(now)
    end

    it 'returns the previous time the cron should have triggered' do

      pt('* * * * sun', lo(1970, 1, 1)).should == lo(1969, 12, 28, 23, 59, 00)
      pt('* * 13 * *', lo(1970, 1, 1)).should == lo(1969, 12, 13, 23, 59, 00)
      pt('0 12 13 * *', lo(1970, 1, 1)).should == lo(1969, 12, 13, 12, 00)

      pt('* * * * * sun', lo(1970, 1, 1)).should == lo(1969, 12, 28, 23, 59, 59)
    end
  end

  describe '#matches?' do


    [ ['* * * * *',     utc(1970, 1, 1, 0, 1),      true],
      ['* * * * sun',   utc(1970, 1, 4),            true],
      ['* * * * * *',   utc(1970, 1, 1, 0, 0, 1),   true],
      ['* * 13 * fri',  utc(1970, 2, 13),           true],
      ['10 12 13 12 *', utc(1970, 12, 13, 12, 10),  true],
      ['* * 1 6 *',     utc(1970, 6, 1),            true],
      ['0 0 * * thu',   utc(1970, 1, 8),            true],
      ['0 0 1 1 *',     utc(2012, 1, 1),            true],
      ['0 0 1 1 *',     utc(2012, 1, 1, 1, 0),      false]
    ].each do |line, time, result|
      it 'matches correctly in UTC (TZ not specified)' do
        cl(line).matches?(time).should eql(result)
      end
    end

    [ ['* * * * *',     local(1970, 1, 1, 0, 1), true],
      ['* * * * sun',   local(1970, 1, 4), true],
      ['* * * * * *',   local(1970, 1, 1, 0, 0, 1), true],
      ['* * 13 * fri',  local(1970, 2, 13), true],
      ['10 12 13 12 *', local(1970, 12, 13, 12, 10), true],
      ['* * 1 6 *',     local(1970, 6, 1), true],
      ['0 0 * * thu',   local(1970, 1, 8), true],
      ['0 0 1 1 *',     local(2012, 1, 1), true],
      ['0 0 1 1 *',     local(2012, 1, 1, 1, 0), false]
    ].each do |line, time, result|
      it 'matches correctly in local TZ (TZ not specified)' do
        cl(line).matches?(time).should eql(result)
      end
    end

    zone = 'Europe/Stockholm'
    [ ["* * * * * #{zone}",     utc(1969, 12, 31, 23, 1),     true],
      ["* * * * sun #{zone}",   utc(1970, 1, 3, 23),          true],
      ["* * * * * * #{zone}",   utc(1969, 12, 31, 23, 0, 1),  true],
      ["* * 13 * fri #{zone}",  utc(1970, 2, 12, 23),         true],
      ["10 12 13 12 * #{zone}", utc(1970, 12, 13, 11, 10),    true],
      ["* * 1 6 * #{zone}",     utc(1970, 5, 31, 23),         true],
      ["0 0 * * thu #{zone}",   utc(1970, 1, 7, 23),          true],
    ].each do |line, time, result|
      it 'matches correctly in UTC (TZ specified)' do
        cl(line).matches?(time).should eql(result)
      end
    end

    it 'matches correctly when there is a sun#2 involved' do

      cl('* * 13 * fri#2').matches?(utc(1970, 2, 13)).should be_true
      cl('* * 13 * fri#2').matches?(utc(1970, 2, 20)).should be_false
    end

    it 'matches correctly when there is a L involved' do

      cl('* * L * *').matches?(utc(1970, 1, 31)).should be_true
      cl('* * L * *').matches?(utc(1970, 1, 30)).should be_false
    end

    it 'matches correctly when there is a sun#2,sun#3 involved' do

      cl('* * * * sun#2,sun#3').matches?( local(1970, 1, 4) ).should be_false
      cl('* * * * sun#2,sun#3').matches?( local(1970, 1, 11) ).should be_true
      cl('* * * * sun#2,sun#3').matches?( local(1970, 1, 18) ).should be_true
      cl('* * * * sun#2,sun#3').matches?( local(1970, 1, 25) ).should be_false
    end
  end

  describe '#monthdays' do

    it 'returns the appropriate "sun#2"-like string' do

      class Whedon::Schedule
        public :monthdays
      end

      cl = Whedon::Schedule.new('* * * * *')

      cl.monthdays(local(1970, 1, 1)).should == %w[ thu#1 thu#-5 ]
      cl.monthdays(local(1970, 1, 7)).should == %w[ wed#1 wed#-4 ]
      cl.monthdays(local(1970, 1, 14)).should == %w[ wed#2 wed#-3 ]

      cl.monthdays(local(2011, 3, 11)).should == %w[ fri#2 fri#-3 ]
    end
  end
end

