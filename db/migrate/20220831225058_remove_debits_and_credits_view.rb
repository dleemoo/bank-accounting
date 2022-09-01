# frozen_string_literal: true

class RemoveDebitsAndCreditsView < ActiveRecord::Migration[6.0]
  def up
    execute <<~SQL
      DROP VIEW IF EXISTS credits;
      DROP VIEW IF EXISTS debits;
    SQL
  end

  def down
    execute <<~SQL
      CREATE OR REPLACE VIEW credits AS (
        SELECT *
        FROM   transactions
        WHERE  transactions.amount > 0
      );

      CREATE OR REPLACE VIEW debits AS (
        SELECT *
        FROM   transactions
        WHERE  transactions.amount < 0
      );
    SQL
  end
end
