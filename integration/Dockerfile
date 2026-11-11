FROM ruby:4.0-slim

ENV BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3 \
    RACK_ENV=production

RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Keep the gemspec's `git ls-files` call from warning when the build context
# has no .git directory.
RUN git init --quiet

# Copy just enough of the gem for `bundle install` to resolve the path
# dependency, then the fixture app itself.
COPY metatron.gemspec ./
COPY lib ./lib
COPY integration/controller ./integration/controller

WORKDIR /app/integration/controller

RUN bundle install

EXPOSE 9292

CMD ["bundle", "exec", "puma", "-b", "tcp://0.0.0.0:9292", "config.ru"]
