# frozen_string_literal: true

class CreateTransactions < ActiveRecord::Migration[6.0]
  def up
    create_table :transactions, id: :uuid do |t|
      t.references :account, null: false, foreign_key: true, type: :uuid
      t.references :operation, null: false, foreign_key: true, type: :uuid
      t.decimal :amount, null: false

      t.timestamps
    end

    execute <<~SQL
      ALTER TABLE transactions
      ADD CONSTRAINT non_zero_amount_on_transactions
      CHECK (amount != 0)
    SQL
  end

  def down
    drop_table :transactions
  end
end
