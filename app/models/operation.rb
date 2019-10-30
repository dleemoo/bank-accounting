# frozen_string_literal: true

class Operation < ApplicationRecord
  has_many :transactions
  has_many :accounts, through: :transactions

  has_one :debit
  has_one :credit

  has_one :source_account, through: :debit, source: :account
  has_one :target_account, through: :credit, source: :account
end
