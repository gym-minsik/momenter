# Momenter

Status: **Work In Progress**

## About
Momenter is designed to trigger events at specific moments in time. Its core purpose is to execute predefined actions at precise time intervals (moments). 

Whether you’re building a timer, scheduler, or need to execute tasks based on specific durations, Momenter helps you manage those efficiently.

## Basic Example
```dart
final momenter = Momenter<Moment>();

// Add moments (specific times to trigger events)
momenter.add(Moment(Duration(seconds: 1)));
momenter.add(Moment(Duration(seconds: 2)));

// Add a listener to track when moments are triggered and other state changes
momenter.addListener((event) {
  switch (event) {
    case MomenterPlay():
      print('Momenter started playing');
    case MomenterPause():
      print('Momenter paused');
    case MomenterTriggered<Moment>(:final moment):
      print('Moment triggered: ${moment.value}');
    case MomenterCompleted():
      print('All moments completed');
  }
});

momenter.play();
```
