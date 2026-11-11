# Contributing

## How to Contribute Code

I'm so glad you're reading this, because we need volunteer developers to help this project grow and thrive!

Before you begin, ensure that your contribution is associated with a [GitHub issue](https://github.com/jgnagy/metatron/issues). If there isn't an existing issue, please create one.

1. Fork the repository
2. Create a new branch (`git checkout -b feature-branch`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin feature-branch`)
5. Create a new [Pull Request](http://help.github.com/pull-requests/)

### Testing

Please make sure that your code passes the existing tests and add tests for any new functionality. Please write [RSpec](https://rspec.info/) examples for new features you add or modify.

To execute the unit tests, run `bundle exec rake spec`.

#### Integration Testing

Metatron also has a cluster-backed suite that runs a fixture controller against a
real [Metacontroller](https://metacontroller.github.io/metacontroller/)
installation. It requires Docker, [`k3d`](https://k3d.io/), and `kubectl`.

```sh
bundle exec rake integration
```

The task builds the fixture image, creates a throwaway k3d cluster, installs a
pinned Metacontroller release, runs `spec/integration`, and deletes the cluster.
Useful options:

```sh
script/integration --keep                          # leave the cluster running
script/integration --metacontroller-version v4.17.5
script/integration --k3d-version v5.9.0
```

Set `METACONTROLLER_VERSION` to test another Metacontroller release and
`K3D_VERSION` to assert the expected k3d binary is installed. CI currently pins
the latest k3d and Metacontroller releases, using a matrix that is ready for
additional versions. The integration job runs only after the faster lint,
test, security, and docs jobs succeed.
If a local Metacontroller clone exists at
`$HOME/Development/golang/metacontroller` with the requested tag, its manifests
are used instead of downloading them; otherwise the pinned release manifests
are fetched from GitHub. The normal `rake spec` task skips these examples
unless `RUN_INTEGRATION=1` is set.

### Coding Style

This project uses [Rubocop](https://rubocop.org/) to enforce a consistent coding style. Please make sure that your code passes the Rubocop checks.

To execute Rubocop, run `bundle exec rake rubocop`.

### Documentation

Please make sure that your code is well documented. If you add new features, please add documentation for them. This project uses [YARD](https://yardoc.org/) for documentation, so please add YARD tags to your code when appropriate.

### License

By contributing your code, you agree to license your contribution under the terms of the [MIT License](LICENSE.txt).

## Code of Conduct

By participating in this project, you agree to abide by our [Code of Conduct](CODE_OF_CONDUCT.md).

## Reporting Bugs

Please use the [GitHub issue tracker](https://github.com/jgnagy/metatron/issues) to report any bugs.

## Suggesting Enhancements

If you have ideas for enhancements or improvements please use the [GitHub issue tracker](https://github.com/jgnagy/metatron/issues) to suggest them.

Thank you for your interest in contributing!
