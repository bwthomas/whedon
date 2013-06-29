# whedon - parse crontab syntax

The goal of this gem is to parse a crontab timing specification and the next
scheduled time.

This gem began as an extraction of Rufus::CronLine from the rufus-schedule gem.

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
sch.match?("2020/07/01")

# Give cron string represented as an array
# [seconds minutes hours days months weekdays monthdays timezone]
sch.to_a
```
