# frozen_string_literal: true

class CreateCredits < ActiveRecord::Migration[6.0]
  def change
    create_view :credits
  end
end
