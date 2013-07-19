# arg-that

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

While authoring the test, we neither care much about the value of `created_time`, nor do we know how to specify it exactly. That means we can't just do this:

``` ruby
result = subject.save
result.should == {:name => "Bob", :age => 28, :email => "bob@example.com" :created_at => 2013-07-18 21:40:58 -0400}
```

This wouldn't work, because at runtime the value of `created_at` will, of course, differ.

So, one could do this:

``` ruby
result = subject.save
result[:name].should == "Bob"
result[:age].should == 28
result[:email].should == "bob@example.com"
```

But now we've got three assertions when before we had one. Alas, we no longer have a clear visual of the *shape* of the data being returned by `save`. Additionally, if the map grows with additional meaningful values in the future, this test would continue to pass by incident.

The `arg_that` matcher can save us this annoyance by retaining the more terse *style* of the first example, while retaining the liberal specification necessitated by the situation:

```
result.should == {
  :name => "Bob",
  :age => 28,
  :email => "bob@example.com",
  :created_at => arg_that { true }
}
```

Where `arg_that { true }` would literally pass any equality test. If there's *something* we want to constrain about the `created_at` value, we could do so. Perhaps a type check like `arg_that { |arg| arg.kind_of?(Time) }` would be more appropriate.

The purpose of releasing something as simple as `arg-that` as a gem is to promote the intentionality about how specific any given equality assertion needs to be. The status quo seems to be to either "always specify everything exactly, but if that gets hard, specify the remainder arbitrarily." And that's not terrific.

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

result.should == {
  :zip_code => 48176,
  :owner => "Fred Jim",
  :last_audit => arg_that { |arg| arg > Time.new(2012, 1, 1) }
}
```

In this way, the result will verify the two entries we want to specify exactly (`zip_code` and `owner`), but allows us the flexibility of only loosely specifying that we're okay with any value of `last_audit` so long as it was some time after January 1st, 2012.

## known issues

`arg_that` does you no good on symbols, as the equality check short-circuits the call to `==` on the receiver.

Any ideas on how to make this pass?

``` ruby
:foo.should == arg_that { true }
```
