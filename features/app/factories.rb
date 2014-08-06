# Factories
require 'factory_girl'

FactoryGirl.define do
  sequence :fork_name do |n|
    "fork %d04" % n
  end

  factory :fork do |f|
    f.name { FactoryGirl.generate(:fork_name) }
  end

  factory :tine do |t|
    t.association :fork
  end

  factory :rusty_tine, :class => Tine do |t|
    t.association :fork
    t.rusty true
  end

  factory :fancy_fork, :class => Fork do |t|
    t.name { "Fancy " + FactoryGirl.generate(:fork_name) }
  end
end
