# NestedHashBuilder

This Ruby gem allows you to easily build nested Ruby Hashes.

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add nested_hash_builder
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install nested_hash_builder
```

## Usage

You can use the `NestedHashBuilder::build` method to easily
create nested hashed with arrays etc.

```ruby
require 'nested_hash_builder'

hash = NestedHashBuilder.build do |h|
  h.user do
    h.name "John"
    h.address do
      h.street "123 Main St"
      h.city "Anytown"
      h.zip "12345"
    end
    h.key!("SOME:STRANGE:KEY", 2)
    h.array!(:contacts) do |c|
      c << h.entry! do |e|
        e.email "john@example.com"
        e.phone "555-1234"
      end
      c << h.entry! do |e|
        e.email "foo@example.com"
        e.phone "222-1234"
      end
    end
  end
end

# The resulting hash looks like:
# {
#   user: {
#     name: "John",
#     address: {
#       street: "123 Main St",
#       city: "Anytown",
#       zip: "12345"
#     },
#     "SOME:STRANGE:KEY": 2,
#     contacts: [
#       {
#         email: "john@example.com",
#         phone: "555-1234"
#       },
#       {
#         email: "foo@example.com",
#         phone: "222-1234"
#       },
#     ],
#   }
# }
```



## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Verseth/nested_hash_builder.
