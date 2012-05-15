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

#### `BlueKaiMiddleware::RaiseError::StatusCodeFix`

Unfortunately, some APIs return a 200 status code even for requests no
sane developer would consider "successful". They instead put a status
field in the response body. This is being worked on, but until it's
fixed, users can add the `StatusCodeFix` middleware, which will check
the body status and fix the HTTP status when necessary:

```ruby
@conn = Faraday.new(:url => "http://example.bluekai.com/") do |builder|
  builder.use      BlueKaiMiddleware::RaiseError
  builder.use      FaradayMiddleware::RaiseError::StatusCodeFix
  builder.use      FaradayMiddleware::ParseJson, :content_type => /\bjson\z/

  builder.adapter  :net_http
end
```

Remember that response middleware is read bottom-to-top, so here we see
the response first being parsed as JSON (if possible). Then the status
code fix will look in the parsed body (if it's a Hash and the HTTP code
was 200) for a status field. If the value does not represent a success,
the HTTP code is changed to a 400 so that the RaiseError middleware can
do the right thing.

[Faraday]: https://github.com/technoweenie/faraday
[FaradayMiddleware gem]: https://github.com/pengwynn/faraday_middleware
