# whedon - parse crontab syntax

The goal of this gem is to parse a crontab timing specification and the next
scheduled time.

## API example

```
parser = Whedon::Parser.new('30 * * * *')

# Most Recent
parser.last

# Upcoming
parser.next

# Next after date/time argument
parser.next("2020/07/01")

# Given date/time matches cron string
parser.match?("2020/07/01")

# Give cron string represented as an array
# [seconds minutes hours days months weekdays monthdays timezone]
parser.to_a
```
