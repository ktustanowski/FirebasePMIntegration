# 🚀 DurationReporter
[![Build Status](https://travis-ci.org/ktustanowski/DurationReporter.svg?branch=master)](https://travis-ci.org/ktustanowski/DurationReporter)
![Carthage compatibile](https://camo.githubusercontent.com/3dc8a44a2c3f7ccd5418008d1295aae48466c141/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f43617274686167652d636f6d70617469626c652d3442433531442e7376673f7374796c653d666c6174)

Have you ever wanted to know how long:
* does it take for your app to finish initial configuration
* user has to wait after tapping play to actually see the video
* your view controller is doing stuff before user can see it

Measuring how long does it take for a function to *do stuff* is easy. Measuring duration of whole **flows** in the application is much more complex. Especially if it has to work across different components and screens. 

Take a look at this console log. If this looks useful to you keep reading. You will see how easy you can generate similar reports with **DurationReporter**.
```
🚀 Application Start - 3207ms
1. Loading        1006ms 31.37%
2. Loading Home   2001ms 62.39%
3. Preparing Home 200ms  6.24%

🚀 Video - 33003ms
1. Loading   2001ms  6.06%
2. Buffering 1001ms  3.03%
3. Playing   30001ms 90.90%

🚀 Share Video - 1302ms
1. Loading providers 501ms 38.48% 
2. Sending           801ms 61.52% 
```

## Cocoapods
```
pod 'DurationReporter'
```

## Carthage
```
github "ktustanowski/DurationReporter"
```

## How it works
First you indicate action start:

```
DurationReporter.begin(event: "ApplicationStart", action: "Loading")
```

When it's done you indicate that action did end:

```
DurationReporter.end(event: "ApplicationStart", action: "Loading")
```
When you want to see the results you just print the report:
```
print(DurationReporter.generateReport())
```
```
🚀 ApplicationStart - 1005ms
1. Loading 1005ms 100.00%
```

## Units
Measurement is done using `mach_absolute_time()` because it provides more accurate data than regular Date objects. Milliseconds are used as default unit when creating the report but you can easily change this:
```
DurationReporter.timeUnit = Nanosecond()
```
```
🚀 Application Start - 1006253263ns
1. Loading 1006253263ns 100.00%
```
Please note that when working on raw report data **seconds** are the default unit used.
## Grouped reporting
Events gathers actions so instead of just knowing how long did whole application configuration take we can do this:
```
[...]
DurationReporter.begin(event: "ApplicationStart", action: "Load config from API")
[...]
DurationReporter.end(event: "ApplicationStart", action: "Load config from API")
[...]
DurationReporter.begin(event: "ApplicationStart", action: "Save configuration")
[...]
DurationReporter.end(event: "ApplicationStart", action: "Save configuration")
[...]
```
And the result:
```
🚀 ApplicationStart - 3041ms
1. Load config from API 2041ms 67.12%
2. Save configuration   1000ms 32.88%
```
## Grouped reporting with duplications
Starting of another already reported action results in creation of another action for the event with addition of incremental counter. When trying to begin action for which previous one didn't finish yet:
- previous, unfinished will show as incomplete in the report since it can't be finished with believable duration
- `fresh` next action will be started with separate counter etc.

Tracking of multiple actions in the same time at this point is not possible.
```
DurationReporter.begin(event: "Video", action: "Play")
[...]
DurationReporter.begin(event: "Video", action: "Play")
[...]
DurationReporter.end(event: "Video", action: "Play")
[...]
DurationReporter.begin(event: "Video", action: "Play")
[...]
DurationReporter.end(event: "Video", action: "Play")
[...]
DurationReporter.begin(event: "Video", action: "Play")
[...]
DurationReporter.end(event: "Video", action: "Play")

```
Duplicated actions have 2, 3, 4... suffix:
```
🚀 Video - 3008ms
1. 🔴 Play - ?
2. Play2 1006ms 33%
3. Play3 1001ms 33%
4. Play4 1001ms 33%
```
## Reporting with custom payload
There might be sutuations like:
* making reporting calls to analytics after report is finished
* making more detailed reports

where passing event and action name `just isn't enough`. For situations like this you can pass your custom `payload` on `begin` & `end`. Then you just have to retrieve this payload from report using `beginPayload` and `endPayload`.
```
DurationReporter.begin(event: "Video", action: "Watch", payload: "Sherlock S01E01")
[...]
DurationReporter.end(event: "Video", action: "Watch")
[...]
DurationReporter.begin(event: "Video", action: "Watch", payload: "Sherlock S01E02")
[...]
DurationReporter.end(event: "Video", action: "Watch")
[...]
DurationReporter.begin(event: "Video", action: "Watch", payload: "Sherlock S01E03")
[...]
DurationReporter.end(event: "Video", action: "Watch")
```
In normal report you will see no difference
```
🚀 Video - 3009ms
1. Watch  1007ms 33.47%
2. Watch2 1001ms 33.27%
3. Watch3 1001ms 33.27%
```
But if you replace default reporting (check below) algorithm with slightly modified version (just add `\((report.beginPayload as? String) ?? "")` when reporting actions) you will see this:
```
🚀 Video - 3009ms
1. Watch  1007ms 33.47% Sherlock S01E01
2. Watch2 1001ms 33.27% Sherlock S01E02
3. Watch3 1001ms 33.27% Sherlock S01E03
```
You can pass literally anything as a paylod.


## Reports
You can create custom reports. Just get collected data:
```
let collectedData = DurationReporter.reportData()
```
and use it to create custom report that suits your needs best.

You can also replace default report generator code:
```
DurationReporter.reportGenerator = { collectedData in
    var output = ""
    
    collectedData.forEach { eventName, reports in
        reports.enumerated().forEach { index, report in
            if let reportDuration = report.duration {
                output += "\(eventName) → \(index). \(report.title) ⏱ \(reportDuration)ms\n"
            } else {
                output += "\(eventName) → \(index). 😱 \(report.title) - ?\n"
            }
            
        }
    }
    
    return output
}
```
to get any kind of report you need with just calling `DurationReporter.generateReport()`:
```
Application Start → 1. Loading ⏱ 1008ms 
Application Start → 2. Loading Home ⏱ 2001ms 
Application Start → 3. Preparing Home ⏱ 201ms 
```

## Handling report begin & end
Right after dispatching `begin` for action
```
public static var onReportBegin: ((String, DurationReport) -> ())?
```
closure is called. After dispatching `end` for action
```
public static var onReportEnd: ((String, DurationReport) -> ())?
```
is called.
This basically mean that you can make custom actions while report is being created. Let's consider the example with application configuration again but let's set this two closures before
```
DurationReporter.onReportBegin = { name, report in print("\(name)::\(report.title) 🚀") }
DurationReporter.onReportEnd = { name, report in print("\(name)::\(report.title) 🎉") }
```
and the result we get:
```
ApplicationStart::Load config from API 🚀
ApplicationStart::Load config from API 🎉
ApplicationStart::Save configuration 🚀
ApplicationStart::Save configuration 🎉

🚀 ApplicationStart - 3007ms
1. Load config from API 2006ms 66.71%
2. Save configuration  1001ms 33.29%
```
This is just simple example of how to add simple console logging. But why just print to console when we can do so much better i.e.:
* Persist report data
* Upload measured durations to external analytics
## Lost actions
If action is not completed it appear with 🔴 in report:
```
🚀 ApplicationStart - 2006ms
1. Load config from API 2006ms 100.00%
2. 🔴 Save configuration - ?
```
## Clear
You can purge current reporting data and start collecting new one:
```
DurationReporter.clear()
```
## Playground
If you want to try it out just clone the repository open playground and see whether this works for you.
