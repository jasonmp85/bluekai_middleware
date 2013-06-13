### 0.5.0 / (unreleased)

* Upgrade gem to allow the usage of Faraday 0.8 (tested with 0.8.4)

### 0.4.2 / 2013-04-29

* Query strings using repeated keys (to express arrays) now handled correctly

### 0.4.1 / 2012-09-12

* Relaxed dependency constraint to allow minor versions of ActiveSupport above 3.1

### 0.4.0 / 2012-08-21

* Removed `superuser` parameter from {BlueKaiMiddleware::Authenticate#initialize}

### 0.3.3 / 2012-08-21

* Removed remaining uses of Rails methods (`try`, `Rails.logger`)

* `SigningContext` now has an attribute reader for its `signature`

* Added `CHANGELOG` and thorough YARD documentation

* Added RSpec tests

* Added release script

### 0.3.2 / 2012-08-01

* Removed requirement that superuser calls provide a `bkpid` or `pid` argument

### 0.3.1 / 2012-06-13

* Empty query strings now handled correctly

### 0.3.0 / 2012-05-15

* Added `StatusCodeFix` middleware to add meaningful status codes to responses lacking them

### 0.2.1 / 2012-05-11

* Corrected broken links in `README`

### 0.2.0 / 2012-05-11

* Added `RaiseError` middleware for consistently handling error conditions in BlueKai services

* Added `README` to explain usage

### 0.1.0 / 2012-05-10

* First public release
