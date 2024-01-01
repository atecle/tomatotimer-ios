# Tomato Timer

This is most of the source code for an iOS app I had on the App Store for a few years.

I'm leaving this up as a read-only archive in case someone someday might find the code useful for their own project 🤗

## Things This Repository Demonstrates

- TCA + CoreData for a simple yet "real" production app. Check out the "Modules" folder for the features, and the "Services" folder for all the CoreData related code. Tests are co-located with the code and associated with the correct target using tuist.
- State-driven and sequenced animations. When you tap the timer, it has a few animation phases one after the other that are modeled as state on the Reducer. The timer state can trigger another animation to run. Check out TimerView/TimerReducer for more.
- Swipeable Calendar week view (a la native Calendar app) - the code is adapted from an open-source example
- A tuist generated project

## Other Notes

- Tests don't run and not all the functionality works in this repo - due to a combination of me breaking things while making this repo public and existing bugs.
- It's a monolithic target despite what a folder called "Modules" may suggest

## Set up

You'll need to install [tuist](http://tuist.io)

1. Run `tuist fetch && tuist generate`
2. Open the generated workspace file

You can run `tuist edit` to check out how the project is configured.
