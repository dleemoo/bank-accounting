# frozen_string_literal: true

require "dry/schema"
require "dry/monads"
require "dry/monads/do"
require "dry/types"
require "dry/struct"

Dry::Schema.load_extensions(:monads)
