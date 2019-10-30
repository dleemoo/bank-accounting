# frozen_string_literal: true

class Operation < ApplicationRecord
  has_many :transactions
  has_many :accounts, through: :transactions
end
