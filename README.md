# Metatron

Metatron in a Ruby library for creating [Metacontroller](https://metacontroller.github.io/metacontroller/)-based custom Kubernetes controllers.

The intention is to make it as easy as possible to use Ruby to manage [custom resources](https://kubernetes.io/docs/concepts/api-extension/custom-resources/) within your Kubernetes infrastructure. No Golang required to listen for and respond to resources based on your own [CustomResourceDefinition](https://kubernetes.io/docs/tasks/access-kubernetes-api/extend-api-custom-resource-definitions/) or to modify existing kubernetes resources via a [DecoratorController](https://metacontroller.github.io/metacontroller/api/decoratorcontroller.html).

Your Ruby code doesn't have to have any _real_ knowledge of the Kubernetes environment in which it operates; Metacontroller takes care of all the Kubernetes interactions and Metatron handles providing the JSON interface. Just write a `sync` method can receive and respond with the appropriate Hashes and you're on your way!

## Usage

TODO (still a very early draft)
