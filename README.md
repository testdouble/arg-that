# arg-that

[![Build Status](https://travis-ci.org/testdouble/arg-that.png?branch=master)](https://travis-ci.org/testdouble/arg-that)

arg-that provides a simple method to create an argument matcher in equality comparisons. This is particularly handy when writing a test to assert the equality of some complex data struct with another and only one component is difficult or unwise to assert exactly.

## wat?

Typically, tests specify exactly what a result should be equal to. If the value of `result` were `5`, then one would probably write an assertion like `result.should == 5` and call it a day.

But sometimes:

* You don't know exactly what the result is, and the part you don't know about doesn't matter a great deal
* A looser specification is preferable to an exact one; suppose a looser specification sufficiently verifies the subject code is working, and greater specificity in the assertion would only serve to constrain changes to future implementation details

## example

Suppose our subject returns a hefty hash of attributes following a `save` operation of a `User` entity.

``` ruby
subject.save #=> {:name => "Bob", :age => 28, :email => "bob@example.com" :created_at => 2013-07-18 21:40:58 -0400}
```

While authoring the test, we neither care much about the value of `created_at`, nor do we know how to specify it exactly. That means we can't just do this:

``` ruby
result = subject.save
expect(result).to eq(:name => "Bob", :age => 28, :email => "bob@example.com" :created_at => Time.new(2013,7,18,21,40,58,"-04:00"))
```

This wouldn't work, because at runtime the value of `created_at` will, of course, differ.

So, one could do this:

``` ruby
result = subject.save
expect(result[:name]).to eq("Bob")
expect(result[:age]).to eq(28)
expect(result[:email]).to eq("bob@example.com")
```

But now we've got three assertions when before we only had one. Alas, we no longer have a clear visual of the *shape* of the data being returned by `save`. Additionally, if the map grows with additional meaningful values in the future, this test would continue to pass by incident.

The `arg_that` matcher can save us this annoyance by retaining the more terse *style* of the first example, while retaining the liberal specification necessitated by the situation:

```
expect(result).to eqish(
  :name => "Bob",
  :age => 28,
  :email => "bob@example.com",
  :created_at => arg_that { true }
)
```

Where `arg_that { true }` would literally pass any equality test. If there's *something* we want to constrain about the `created_at` value, we could do so. Perhaps a type check like `arg_that { |arg| arg.kind_of?(Time) }` would be more appropriate. Also, note that arg-that includes an RSpec matcher called `eqish` which is meant to be used in conjunction with the `arg_that` matcher ([discussion](https://github.com/testdouble/arg-that#whats-up-with-this-eqish-matcher)).

The purpose of releasing something as simple as `arg-that` as a gem is to promote more intentionality about how specific any given equality assertion needs to be. The modus operandi of most Rubyists seems to be "always specify everything exactly, but if that gets hard, specify the remainder arbitrarily." And that's not terrific.

## usage

Here's how you'd use it in RSpec.

In your `spec_helper.rb`, you can make arg-that available to all of your examples by telling RSpec to include it:

``` ruby
require 'arg_that'

RSpec.configure do |config|
  config.include(ArgThat)
end
```

Once included, you can make more liberal assertions as you see fit, like so:

``` ruby
result = {
  :zip_code => 48176,
  :owner => "Fred Jim",
  :last_audit => Time.new(2012, 8, 12)
}

expect(result).to eqish(
  :zip_code => 48176,
  :owner => "Fred Jim",
  :last_audit => arg_that { |arg| arg > Time.new(2012, 1, 1) }
)
```

In this way, the result will verify the two entries we want to specify exactly (`zip_code` and `owner`), but allows us the flexibility of only loosely specifying that we're okay with any value of `last_audit` so long as it was some time after January 1st, 2012.

## what's up with this `eqish` matcher?

**tl;dr whenever you use `arg_that` in an equality RSpec expectation, always use the `eqish` matcher or otherwise ensure that `==` is being called on the object containing the `arg_that` matcher**

As mentioned above, the reason that arg-that includes a matcher called `eqish` is because of the nature of how equality (`==`) tests work in Ruby (and most other OOP languages). The object that receives the message "are you equal?" is responsible for determining whether some other thing this equal to it.

This works fine in most of our programs, because in almost every circumstance, two objects of the same type will adhere to the *symmetric property of equality* contract when asked whether one equals the other.

That is to say, if:

``` ruby
x = 5
y = 5

x == y #=> true
y == x #=> true
```

**However**, it's the very nature of matchers like `arg_that` to *intentionally violate* the symmetric property of equality. We do this because such tests are only concerned about *partial equality*. As a result, to serve the purpose of the test, it's important that the expected value be the object who is asked "are you equal?" to the object being interrogated by the test; if the actual value is asked the question, then our definition of partial equality will never be invoked!

This is a bit of a bummer, because RSpec (and most testing libraries) will invoke `==` on the actual value, and not the expected value. Therefore, if an asymmetric definition of equality is desired, `==` must be invoked on the expected value.

To work around this, arg_that includes an RSpec matcher (which is auto-defined if you include `ArgThat` in an `RSpec.configure` block) called `eqish` [source](https://github.com/testdouble/arg-that/blob/master/lib/arg_that/eqish.rb). The implementation of `eqish` is literally to swap the order of `actual == expected` to `expected == actual`. In all other matters, it delegates to RSpec's built-in `eq` matcher.

