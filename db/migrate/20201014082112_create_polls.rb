class CreatePolls < ActiveRecord::Migration[6.0]
  def change
    create_table :polls do |t|
      t.integer :correct_answer
      t.boolean :ended, default: false
      t.integer :chat_id, nil: false

      t.timestamps
    end
  end
end
