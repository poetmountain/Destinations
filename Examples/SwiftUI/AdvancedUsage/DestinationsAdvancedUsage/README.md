# Destinations Advanced Usage Examples

This project contains examples demonstrating advanced usage patterns of the [Destinations](https://github.com/poetmountain/Destinations) framework.

## Dynamic Routes

This example shows how to dynamically change the destination type of a `DestinationPresentation` at runtime.

In a typical Destinations setup, each `DestinationPresentation` is configured with a fixed `destinationType` at compile-time that determines which destination is presented. This provides better type safety and reliable routing, however it can be limiting in more complex use-cases where the possible routes from a Destination can be variable, especially if the routing in your app is server-driven.

 In this example, instead of each `DestinationPresentation` being statically bound to a single route type, the custom `DynamicRouteAssistant` assistant reads the route from the request's `ContentType` and overrides the route before the Flow object presents the Destination.

### Dynamic Destination paths

This same pattern can be extended to build dynamic destination paths. Instead of passing a single route via the `ContentType`, you can construct a `destinationPath` presentation whose path is assembled dynamically and handled via a similar custom assistant.

This pattern would allow a server response, user configuration, or any other runtime data source can supply a sequence of destinations to navigate through, enabling fully dynamic deep linking and navigation flows.
