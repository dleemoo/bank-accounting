# frozen_string_literal: true

module Types
  include Dry.Types()

  UUID = String.constrained(format: /^\h{8}(-\h{4}){3}-\h{12}$/)
end
