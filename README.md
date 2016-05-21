# ReactiveGitter

A ReactiveKit demo app.

## Installation

1. Clone the repo.
2. Run `pod install`.
3. Open _ReactiveGitter.xcworkspace_.
4. Have fun and make sure you have [Gitter](https://gitter.im) account!

## Project structure

Project is organized in modules like _Home_, _Room_, _Login_, etc. API code is located in module _API_. Common stuff is in module _Common_.

## Architecture

Modules that correspond to screens adhere to the architecture I call **Scene - Director - Stage**. It's a variation of MVVM with the additon of component that manages navigation (view controller presentation).

### Stage

Stage is what user sees on the screen. Corresponds to the View in MVVM. Usually a subclass of UIViewController. Has a director that manages its content and handles its actions. Observes the director outputs. 

### Director

Corresponds to the ViewModel in MVVM. It should be purely reactive. It can have streams, operations and dependencies on the input, but is should have only streams on the output.

### Scene

Knows to present its stage onto a context (window, navigation controller, etc). Presents other scenes by observing the director outputs for presentation events.

### Model

Model is represented by the API module. It could also be called a service.
