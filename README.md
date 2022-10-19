# Metatron

Metatron is a Ruby library for creating [Metacontroller](https://metacontroller.github.io/metacontroller/)-based custom Kubernetes controllers.

The intention is to make it as easy as possible to use Ruby to manage [custom resources](https://kubernetes.io/docs/concepts/api-extension/custom-resources/) within your Kubernetes infrastructure. No Golang required to listen for and respond to resources based on your own [CustomResourceDefinition](https://kubernetes.io/docs/tasks/access-kubernetes-api/extend-api-custom-resource-definitions/) or to modify existing kubernetes resources via a [DecoratorController](https://metacontroller.github.io/metacontroller/api/decoratorcontroller.html).

Your Ruby code doesn't have to have any _real_ knowledge of the Kubernetes environment in which it operates; Metacontroller takes care of all the Kubernetes interactions and Metatron handles providing the JSON interface. Just write a `sync` method that can receive and respond with the appropriate Hashes and you're on your way!

## Usage

**DRAFT**
### Getting Started

To use Metatron, first decide what type of Metacontroller you'd like to create, mostly based on the type(s) of resource(s) you'll manage. Most of the time, what you want is a Custom Resource that has child resources, which means you'll want a [Composite Controller](https://metacontroller.github.io/metacontroller/api/compositecontroller.html).

Reading the [Metacontroller user's guide](https://metacontroller.github.io/metacontroller/guide.html) will be pretty helpful but isn't strictly required.

You'll need to [install Metacontroller](https://metacontroller.github.io/metacontroller/guide/install.html) into your cluster before proceeding. This guide doesn't provide a recommendation on how to do that, but it isn't very difficult.

### Creating a Composite Controller

As an example, let's suppose we want to simplify launching blogs for users. Each `Blog` resource should have its own application server (as a `Deployment`), a database (as a `StatefulSet`), a Kubernetes `Service`, and an `Ingress`. A `Blog` will probably have a `name`, an `hostname` (which we'll derive based on its name), and a `username` and `password` (as a `Secret`) to restrict who can author content.

This means we'll want a `Blog` custom resource and it'll need a few basic properties, like those listed above. It'll also need to specify a container image, and a number of replicas (so we can scale it up and down).

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
  generateSelector: true
  parentResource:
    apiVersion: example.com/v1
    resource: blogs
  childResources:
  - apiVersion: apps/v1
    resource: deployments
    updateStrategy:
      method: InPlace
  - apiVersion: apps/v1
    resource: statefulsets
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

Before applying the above though, we'll need to actually create a service that can response to sync requests. That's where Metatron comes in!

### Creating a Sync Controller with Metatron

As Metatron is a tool for creating Ruby projects, you'll need a few prerequistes. First, make a directory (and git repo) for your controller:

```sh
$ git init blog_controller && cd blog_controller
```

We'll need a `Gemfile` to ensure we have Metatron installed:

```ruby
# frozen_string_literal: true

source "https://rubygems.org"

gem "metatron"
```

We'll also need a `config.ru` file to instruct [`rack`](https://github.com/rack/rack) how to route requests:

```ruby
# frozen_string_literal: true

# \ -s puma

require "metatron"
require_relative "./lib/blog_controller/sync"

use Rack::ShowExceptions
use Rack::Deflater

mappings = {
  # This one is built-in to Metatron and is useful for monitoring
  "/ping" => Metatron::Controllers::Ping.new,
  # We'll need to make this one
  "/sync" => BlogController::Sync.new
}

run Rack::URLMap.new(mappings)
```

Finally, before we start hacking on some actual Metatron-related code, we'll need a `Dockerfile` to create an image that we can deploy to Kubernetes:

```dockerfile
FROM ruby:3.1

RUN mkdir -p /app

COPY config.ru /app/
COPY Gemfile /app/
COPY Gemfile.lock /app/
COPY lib/ /app/lib/

RUN apt update && apt upgrade -y
RUN useradd appuser -d /app -M -c "App User"
RUN chown appuser /app/Gemfile.lock

USER appuser
WORKDIR /app
RUN bundle install

ENTRYPOINT ["bundle", "exec"]
CMD ["puma"]
```

*Phew*, ok, with all that out of the way, we can get started with our development. We'll need to create a `Metatron::SyncController` subclass with a `sync` method. We'll put this in `lib/blog_controller/sync.rb`:

```ruby
# frozen_string_literal: true

module BlogController
  # The Blog sync controller endpoint
  class Sync < Metatron::SyncController
    # This method needs to return a Hash which will be converted to JSON
    # It should have the keys "status" (a Hash) and "children" (an Array)
    def sync
      # request_body is a convenient way to access the data provided by MetaController
      parent = request_body["parent"]
      desired_children = []

      # first, let's create the DB and its service
      db_stateful_set = construct_db_stateful_set(parent["metadata"])
      desired_children << db_stateful_set
      db_service = construct_service(parent["metadata"], { "app.kubernetes.io/component": "db" })
      desired_children << db_service

      # now let's make the app and its parts
      app_auth_secret = construct_app_secret(parent["metadata"])
      desired_children << app_auth_secret
      desired_children << construct_app_deployment(
        parent["metadata"], parent["spec"], app_auth_secret
      )
      app_service = construct_service(parent["metadata"], { "app.kubernetes.io/component": "app" })
      desired_children << app_service
      desired_children << construct_ingress(parent["metadata"], app_service)

      # We might eventually want a mechanism to build status based on the world:
      #   status = compare_children(request_body["children"], desired_children)
      status = {}

      { status:, children: desired_children.map(&:render) }
    end

    def construct_db_stateful_set(meta)
      stateful_set = Metatron::Templates::StatefulSet.new(meta["name"])
      stateful_set.image = "mysql:8.0"
      stateful_set.additional_pod_labels = {
        "app.kubernetes.io/component": "db"
      }
      # Do other things to setup your DB
      stateful_set
    end

    def construct_app_deployment(meta, spec, auth_secret)
      deployment = Metatron::Templates::Deployment.new(meta["name"], replicas: spec["replicas"])
      deployment.image = spec["image"]
      deployment.additional_pod_labels = {
        "app.kubernetes.io/component": "app"
      }
      deployment.envfrom << auth_secret.name
      # Do other things to setup your App
      deployment
    end

    def construct_ingress(meta, service)
      ingress = Metatron::Templates::Ingress.new(meta["name"])
      ingress.add_rule(
        "#{meta["name"]}.blogs.example.com": { service.name => service.ports.first[:name] }
      )
      ingress.add_tls("#{meta["name"]}.blogs.example.com")
      ingress
    end

    def construct_service(meta, selector_labels, port = "9292")
      service = Metatron::Templates::Service.new(meta["name"], port)
      service.additional_selector_labels = selector_labels
      service
    end

    def construct_app_secret(meta)
      Metatron::Templates::Secret.new(
        meta["name"],
        # Maybe base this off of the name, or pull it from a DB or some external service?
        { "APP_USER" => "author", "APP_PASS" => "sUP3r_S3CREt99" }
      )
    end
  end
end
```

That might seem like a lot of code, but it does a **lot** of heavy lifting for you in creating Kubernetes resources. Try creating all the above Kubernetes resources by hand and you'll see what Metatron is doing for you. It is pretty likely you'll want to adjust a lot of the above code, but it should be a decent starting point.

To use it, you'll need to create your `Gemfile.lock` file then work on your Docker image:

```sh
$ bundle install
$ docker build -t "blogcontroller:latest" .
```

You can test your controller locally by running the image:

```sh
$ docker run -it --rm -p 9292:9292 "blogcontroller:latest"
```

Try POSTing a request via `curl` and inspecting the JSON response to see what your controller is doing for you:

```sh
$ curl \
  -H "Content-Type: application/json" \
  --data '{"parent": {"metadata": {"name": "foo"}, "spec": {"replicas": 1, "image": "nginx:latest"}}}' \
  http://localhost:9292/sync
```

Once we've confirmed this works, we'll need to publish our image somewhere and run it. Make sure you update the Service details in `blog-controller.yaml` to reflect its actual location.

### Using the New Composite Controller

After your Metatron controller is up and running in your Kubernetes cluster, you'll need to actually `kubectl apply` your `blog-controller.yaml` file we created way above. Once that is deployed, you can create new `Blog` resources that look something like this (let's call it `test-blog.yaml`):

```yaml
apiVersion: example.com/v1
kind: Blog
metadata:
  name: test
spec:
  image: my.registry/blog:tag
  replicas: 2
```

Note that `my.registry/blog:tag` should point to some image that is ready to run a blog. This is just an example and, much like the other resources we've created in this guide, it will almost certainly not work as-is.

Let's make a new namespace for this blog and launch it:

```sh
$ kubectl create namespace blog-test
$ kubectl -n blog-test apply -f test-blog.yaml
```

You should be able to inspect the pods, services, etc. in the `blog-test` namespace and see your resources running!
