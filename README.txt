= dynamicwind

* http://github.com/mame/dynamicwind/tree/master

== DESCRIPTION:

An implementation of dynamic-wind for ruby's continuation.
See R6RS 11.15 Control features for detail.
http://www.r6rs.org/final/html/r6rs/r6rs-Z-H-14.html#node_idx_764

== FEATURES/PROBLEMS:

* callcc becomes robust!

== SYNOPSIS:

require "dynamicwind"

callcc do |c|
  dynamicwind(
    proc { p :before },
    proc { p :thunk; c.call },
    proc { p :after }
  )
end
#=> :before, :thunk, :after

dynamicwind(
  proc { p :before },
  proc { callcc {|c| $c = c }; p :thunk },
  proc { p :after }
)
#=> :before, :thunk, :after

$c.call #=> :before, :thunk, :after, ...(infinite loop)

== REQUIREMENTS:

None

== INSTALL:

* gem install mame-dynamicwind

== LICENSE:

Copyright:: Yusuke Endoh <mame@tsg.ne.jp>
License:: Ruby's
