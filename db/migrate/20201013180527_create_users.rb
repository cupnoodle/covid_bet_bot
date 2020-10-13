class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :telegram_id
      t.string :name
      t.index ['telegram_id'], name: 'index_users_on_telegram_id', unique: true

      t.timestamps
    end
  end
end
