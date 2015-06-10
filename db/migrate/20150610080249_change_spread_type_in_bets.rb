class ChangeSpreadTypeInBets < ActiveRecord::Migration
  def change
  	change_column :bets, :spread,  :float
  end
end
