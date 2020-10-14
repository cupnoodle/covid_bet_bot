class CreateVotes < ActiveRecord::Migration[6.0]
  def change
    remove_index :users, name: "index_users_on_telegram_id"
    change_column :users, :telegram_id, 'integer USING CAST(telegram_id AS integer)'
    add_index :users, :telegram_id, unique: true

    create_table :votes do |t|
      t.integer :answer
      t.references :poll, null: false, index: true
      t.references :user, null: false, index: true

      t.timestamps
    end
  end
end
