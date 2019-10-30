# frozen_string_literal: true

class CreateOperations < ActiveRecord::Migration[6.0]
  def change
    create_table :operations, id: :uuid do |t|
      t.string :kind, null: false

      t.timestamps
    end
  end
end
