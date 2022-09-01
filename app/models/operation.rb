# frozen_string_literal: true

class Operation < ApplicationRecord
  has_many :transactions
  has_many :accounts, through: :transactions

  has_one :debt, -> { where(Transaction.arel_table[:amount].lt(0)) }, class_name: "Transaction"
  has_one :credit, -> { where(Transaction.arel_table[:amount].gt(0)) }, class_name: "Transaction"

  has_one :source_account, through: :debt, source: :account
  has_one :target_account, through: :credit, source: :account
end
