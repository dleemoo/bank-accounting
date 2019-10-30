# frozen_string_literal: true

class Account < ApplicationRecord
  has_many :transactions
  has_many :operations, through: :transactions

  has_many :debits
  has_many :credits
end
