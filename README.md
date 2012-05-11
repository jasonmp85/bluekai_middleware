BlueKai Middleware
==================

The purpose of the `bluekai_middleware` gem is to provide code useful
when interacting with any number of BlueKai services. This gem will be
most useful when using [Faraday][] to make service calls; additionally,
some components may not be very useful outside of a Rails app. The main
areas of concern here are logging, error-handling, and authentication.

Usage
-----

Pretty straightforward. Add this gem to your `Gemfile`. At the moment
there are really only three useful components:

### `BlueKaiMiddleware::Authenticate`

This class provides an easy way to sign requests using your BlueKai
keys. Within your Faraday connection configuration block, do something
like this, where `key` is your user's web service key and `private_key`
is your user's private web service key:

```ruby
@conn = Faraday.new(:url => "http://example.bluekai.com/") do |builder|
  builder.use BlueKaiMiddleware::Authenticate, key, private_key

  builder.adapter  :net_http
end
```

Requests made through `@conn` will be signed for easy authentication.

### `BlueKaiMiddleware::LogSubscriber`

The [FaradayMiddleware gem][] contains a piece of middleware that'll
emit Rails events during each request but nothing to do anything
interesting with those events. We fixed that. In your connection block,
do something like:

```ruby
@conn = Faraday.new(:url => "http://example.bluekai.com/") do |builder|
  builder.use      FaradayMiddleware::Instrumentation

  builder.adapter  :net_http
end
```

That'll set up the events. Our contribution is a log subscriber. Set it
up with something like this in an initializer file:

```ruby
Faraday::LogSubscriber.attach_to :faraday
```

Now your log'll have stuff like this:

```
Faraday GET (397.6ms)  http://example.bluekai.com/Services/WS/foo
```

The lines'll even be in alternating colors if you have that enabled.

### `BlueKaiMiddleware::RaiseError`

This is just to automatically raise errors when a response has a status
code ≥ 400. You'd think this'd be built-in, right?

```ruby
@conn = Faraday.new(:url => "http://example.bluekai.com/") do |builder|
  builder.use      BlueKaiMiddleware::RaiseError

  builder.adapter  :net_http
end
```

You can catch `BlueKaiMiddleware::HTTPError` for all errors, or pick
between `BlueKaiMiddleware::ClientError` for 400-class errors and 
`BlueKaiMiddleware::ServerError` for 500-class ones. All errors provide
the response body and status as attributes and have the standard HTTP
message for their status as their exception message.

[Faraday]: https://github.com/technoweenie/faraday
[FaradayMiddleware gem]: https://github.com/pengwynn/faraday_middleware
