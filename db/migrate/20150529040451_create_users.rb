class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username
      t.string :password_digest
      t.float :balance
      t.float :max_balance
      t.float :ten_day_profit
      t.float :thirty_day_profit
      t.float :total_profit
      t.boolean :admin

      t.timestamps null: false
    end
  end
end
