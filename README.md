# Metatron

Metatron is a Ruby library for creating [Metacontroller](https://metacontroller.github.io/metacontroller/)-based custom Kubernetes controllers.

The intention is to make it as easy as possible to use Ruby to manage [custom resources](https://kubernetes.io/docs/concepts/api-extension/custom-resources/) within your Kubernetes infrastructure. No Golang required! Use simple, Rack-based controllers to provide the logic for your custom resources. Metatron templates provide most Kubernetes boilerplate code for you, so you can focus on the logic that enables your custom resources to do what you need them to do.

For more information, see the [Metatron Wiki on GitHub](https://github.com/jgnagy/metatron/wiki)!

For help on how to get started, take a look at the [User Guide](https://github.com/jgnagy/metatron/wiki/User-Guide) in the Wiki!

## Security

Metatron controllers are HTTP endpoints. By default they answer any request that
looks like a Metacontroller sync request, which means any pod that can reach the
webhook port can drive your controller — and in controllers that re-render
existing child `Secrets`, can read credentials.

Metatron ships two opt-in middleware for the two things that matter most:

```ruby
use Metatron::Middleware::BodyLimit # rejects bodies over 1 MiB with a 413
use Metatron::Middleware::Auth      # requires the Bearer token shared with Metacontroller
```

Both are configurable: `METATRON_AUTH_SECRET` (leave it unset and the auth
middleware stays inert) and `METATRON_MAX_REQUEST_BODY_BYTES` (1 MiB by default,
which is generous for sync payloads). See the
[User Guide](https://github.com/jgnagy/metatron/wiki/User-Guide#securing-the-webhook-endpoint)
for the full setup, including the `webhook.authorization.secretRef` half of the
handshake on the Metacontroller side.

Errors raised inside `sync`, `customize`, or `finalize` are caught and returned
as generic JSON `500` problem documents, with the details written to
`Metatron.logger`. Do not add `Rack::ShowExceptions` to a production stack.

## Contributing

If you're interested in contributing to Metatron, please see the [Contributing Guide](CONTRIBUTING.md) in the repository! Be sure to check out the [Code of Conduct](CODE_OF_CONDUCT.md) as well!
