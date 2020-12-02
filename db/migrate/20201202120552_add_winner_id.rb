class AddWinnerId < ActiveRecord::Migration[6.0]
  def change
    add_column :polls, :winner_id, :integer
  end
end
