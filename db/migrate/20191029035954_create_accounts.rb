# frozen_string_literal: true

class CreateAccounts < ActiveRecord::Migration[6.0]
  def change
    create_table :accounts, id: :uuid do |t|
      t.string :name, null: false, index: { unique: true }

      t.timestamps
    end
  end
end
