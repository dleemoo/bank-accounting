# frozen_string_literal: true

class Credit < ApplicationRecord
  belongs_to :account
  belongs_to :operation
end
