# Bucketpdf

This gem allows you to use easily sign URLs to be used with the BucketPDF service.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bucketpdf'
```

And then execute:

```sh
$ bundle
```

## Usage

To sign a URL in your code instantiate a signer object and use its sign method (the new signer will use `BUCKET_PDF_API_KEY` and `BUCKET_PDF_API_SECRET` ENV vars):

```ruby
signer = Bucketpdf::Signer.new

# You can also explicitly set the api credentials like this
other_signer = Bucketpdf::Signer.new(api_key: '123', api_secret: '321')

# And you get the signed_url using the sign method
signed_url = signer.sign('http://example.com', :landscape, :a4)
```

* Possible values for orientation: :landscape, :portrait
* Possible values for page size: :letter, :a4

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).
