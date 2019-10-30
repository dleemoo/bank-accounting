# frozen_string_literal: true

class Debit < ApplicationRecord
  belongs_to :account
  belongs_to :operation
end
