# Factories
require 'factory_girl'

Factory.sequence :fork_name do |n|
  "fork %d04" % n
end

Factory.define :fork do |f|
  f.name { Factory.next(:fork_name) }
end

Factory.define :tine do |t|
  t.association :fork
end

Factory.define :rusty_tine, :class => Tine do |t|
  t.association :fork
  t.rusty true
end

Factory.define :fancy_fork, :class => Fork do |t|
  t.name { "Fancy " + Factory.next(:fork_name) }
end
