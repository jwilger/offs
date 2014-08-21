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

OFFS::Flags.set do |offs|
  offs.flag :use_my_million_dollar_idea, false
  offs.flag :use_this_mostly_done_feature, true
end
```

You've now defined the flags that your app will use, and you've given
each flag a default value where `true` means you will use the new
feature and `false` means you will use the old code instead.

When running your application, you can override the default flag setting
by setting environment variables. For instance, to reverse both of the
flags above when running `rake` on your application code, you would do
this:

```sh
USE_MY_MILLION_DOLLAR_IDEA=1 USE_THIS_MOSTLY_DONE_FEATURE=0 rake
```

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
end
```

Note that you are not required to have *both* the `would_like_to` and
`may_still_need_to` blocks present; they simply become a noop if not
present.

## Contributing

1. Fork it ( https://github.com/jwilger/offs/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
