# frozen_string_literal: true

class CreateDebits < ActiveRecord::Migration[6.0]
  def change
    create_view :debits
  end
end
