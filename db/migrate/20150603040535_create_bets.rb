class CreateBets < ActiveRecord::Migration
  def change
    create_table :bets do |t|
      t.datetime :match_time
      t.string :sport
      t.string :home_team
      t.string :away_team
      t.boolean :home_picked
      t.integer :spread
      t.integer :odds
      t.float :risk_amount
      t.datetime :result_time
      t.string :result
      t.float :resulting_balance
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
