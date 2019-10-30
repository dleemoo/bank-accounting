# frozen_string_literal: true

class Transaction < ApplicationRecord
  belongs_to :account
  belongs_to :operation
end
