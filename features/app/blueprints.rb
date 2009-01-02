# Blueprints
require 'machinist'

Sham.spoon_name { |i| "Spoon #{i}" }

Spoon.blueprint do
  name { Sham.spoon_name }
end
