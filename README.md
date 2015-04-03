# OFFS Feature Flagging System

OFFS allows new features-in-progress to be constantly integrated with
a project's master or production code branch by allowing the code to
take different branches depending on how the feature flags are
configured.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'offs'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install offs

## Usage

Let's say you are working on an application and are going to add a hot
new feature that is virtually guaranteed to make you millions of
dollars. You want to continuously integrate the new code into the master
branch of the repository to avoid merging-headaches down the line (there
are other developers working on other features at the same time), but
you need to keep the master branch in a deployable state. OFFS allows
you to do just that.

First, you need to decide on the name for your feature flag and tell
OFFS about it when your application loads. For instance, in a Rails app,
you could put the following in `config/initializers/offs_flags.rb`:

```ruby
require 'offs'

OFFS::Flags.instance(
  :use_my_million_dollar_idea,
  :use_this_mostly_done_feature,

  value_sources: [
    ENV,
    FeatureFlag
  ]
)
```

The `value_sources` is an array of Hash-like objects that are keyed on
the flag name (can be lower-case string, upper-case string, or symbol,
i.e. `FeatureFlag['use_my_million_dollar_idea']`,
`FeatureFlag['USE_MY_MILLION_DOLLAR_IDEA']`, or
`FeatureFlag[:use_my_million_dollar_idea]`) and should have a value of
`true` if the flag is to be enabled or `false` if disabled. The sources
are listed in order of precedence; in the above example, if a flag is
disabled in `FeatureFlag` but enabled in `ENV`, then it will be
considered enabled. However, if it is not set at all in `ENV`, then the
value from `FeatureFlag` will be used, and it will be considered
disabled.

In your code, simply do the following in each place where you have new
and/or existing code that should be run or not run depending on the
feature flag setting:

```ruby
class Foo
  def do_something
    OFFS.so_you_want_to(:use_my_million_dollar_idea) do |you|
      you.would_like_to do
        # this is where you put the new code that will run when the flag
        # is *on*.
      end

      you.may_still_need_to do
        # this is where you put the old code that will run when the flag
        # is *off*
      end
    end
  end

  def do_something_for_new_feature
    OFFS.raise_error_unless_we :use_my_million_dollar_idea
    # The following code will only be reached if the feature is enabled.
    # Otherwise we raise an OFFS::FeatureDisabled error
  end
end
```

Note that you are not required to have *both* the `would_like_to` and
`may_still_need_to` blocks present; they simply become a noop if not
present. Shortcuts for this usage are provided via
`OFFS.if_you_would_like_to` and `OFFS.if_you_do_not_want_to`,
respectively.

## Contributing

1. Fork it ( https://github.com/jwilger/offs/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
