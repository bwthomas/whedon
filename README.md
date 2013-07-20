# whedon - parse crontab syntax

The goal of this gem is to parse a crontab timing specification and produce an
object that can be queried about the schedule.

This gem began as an extraction of Rufus::CronLine from the [rufus-scheduler](https://github.com/jmettraux/rufus-scheduler) gem.

[![Build Status](https://travis-ci.org/bwthomas/whedon.png)](https://travis-ci.org/bwthomas/whedon)

## API example

```
sch = Whedon::Schedule.new('30 * * * *')

# Most Recent
sch.last

# Upcoming
sch.next

# Next after date/time argument
sch.next("2020/07/01")

# Given date/time matches cron string
sch.matches?("2020/07/01 14:00:00")

# Time.now matches cron string
sch.now?

# Give cron string represented as an array
# [seconds minutes hours days months weekdays monthdays timezone]
sch.to_a
```

## And ... the Name?

Why 'whedon' ? First, [when](http://rubygems.org/gems/when) was taken. I was
considering variations on 'when do', & it occurred to me that 'whedon' (a la
[Joss Whedon](http://en.wikipedia.org/wiki/Joss_Whedon)) was an obvious anagram
of 'when do'. The pun regarding Whedon::Schedule being that Joss Whedon's
television series tend to get pulled from the network schedule.

## License
[MIT](http://opensource.org/licenses/MIT). See [LICENSE](LICENSE).
