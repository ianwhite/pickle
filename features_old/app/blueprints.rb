# Blueprints
require 'machinist/active_record'

Sham.spoon_name { |i| "Spoon #{i}" }

Spoon.blueprint do
  name { Sham.spoon_name }
end

# reset shams between scenarios
Before { Sham.reset }