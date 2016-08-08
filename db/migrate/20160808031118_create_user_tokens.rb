class CreateUserTokens < ActiveRecord::Migration[5.0]
  def change
    create_table :user_tokens do |t|
      t.string :token,              null: false, default: ""

      t.integer :user_id
      t.timestamps
    end

    add_index :user_tokens, :user_id
    add_index :user_tokens, :token
    add_index :user_tokens, [:user_id, :token]
  end
end
