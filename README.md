# Metatron

Metatron in a Ruby library for creating [Metacontroller](https://metacontroller.github.io/metacontroller/)-based custom Kubernetes controllers.

The intention is to make it as easy as possible to use Ruby to manage [custom resources](https://kubernetes.io/docs/concepts/api-extension/custom-resources/) within your Kubernetes infrastructure. No Golang required to listen for and respond to resources based on your own [CustomResourceDefinition](https://kubernetes.io/docs/tasks/access-kubernetes-api/extend-api-custom-resource-definitions/) or to modify existing kubernetes resources via a [DecoratorController](https://metacontroller.github.io/metacontroller/api/decoratorcontroller.html).

Your Ruby code doesn't have to have any _real_ knowledge of the Kubernetes environment in which it operates; Metacontroller takes care of all the Kubernetes interactions and Metatron handles providing the JSON interface. Just write a `sync` method that can receive and respond with the appropriate Hashes and you're on your way!

## Usage

**DRAFT**
### Getting Started

To use Metatron, first decide what type of Metacontroller you'd like to create, mostly based on the type(s) of resource(s) you'll manage. Most of the time, this is a Custom Resource that in term has child resources, which means you'll want a [Composite Controller](https://metacontroller.github.io/metacontroller/api/compositecontroller.html).

Reading the [Metacontroller user's guide](https://metacontroller.github.io/metacontroller/guide.html) will be pretty helpful but isn't strictly required.

You'll need to [install Metacontroller](https://metacontroller.github.io/metacontroller/guide/install.html) into your cluster before proceeding. This guide doesn't provide a recommendation on how to do that, but it isn't very difficult.

### Creating a Composite Controller

As an example, let's suppose we want to simplify launching blogs for users. Each `Blog` resource should have its own application server (as a `Deployment`), a database (as a `StatefulSet`), a Kubernetes `Service`, and an `Ingress`. A `Blog` will probably have a `name`, an `hostname`, and a `username` and `password` (as a `Secret`) to restrict who can author content.

This means we'll want a `Blog` custom resource and it'll need a few basic properties, like those listed above.

Here's how that CRD (let's call it `blog-crd.yaml`) might look:

```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: blog.example.com
spec:
  group: example.com
  names:
    kind: Blog
    plural: blogs
    singular: blog
  scope: Namespaced
  versions:
  - name: v1
    served: true
    storage: true
    subresources:
     status: {}
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            properties:
              hostname:
                type: string
                required: true
              image:
                type: string
              replicas:
                type: integer
                minimum: 1
```

This means we'll be able to query our Kubernetes cluster for `blogs`. You might eventually want to expand the field list, or simplify it and defer to your controller for validating it. You'll also probably want to make `metadata.name` and `spec.group` use a real domain to avoid potential conflicts. This should be safe to `kubectl apply` as the CRD doesn't do much on its own.

Now, you'll need to define a `CompositeController` resource (let's call this `blog-controller.yaml`) that instructs Metacontroller where to send sync requests:

```yaml
apiVersion: metacontroller.k8s.io/v1alpha1
kind: CompositeController
metadata:
  name: blog-controller
spec:
  parentResource:
    apiVersion: example.com/v1
    resource: blogs
  childResources:
  - apiVersion: apps/v1
    resource: deployments
    updateStrategy:
      method: InPlace
  - apiVersion: v1
    resource: services
    updateStrategy:
      method: InPlace
  - apiVersion: networking.k8s.io/v1
    resource: ingresses
    updateStrategy:
      method: InPlace
  - apiVersion: v1
    resource: secrets
    updateStrategy:
      method: InPlace
  hooks:
    sync:
      webhook:
        service:
          name: blog-controller
          namespace: blog-controller
          port: 9292
          protocol: http
        path: /sync
```

**Still in progress**
