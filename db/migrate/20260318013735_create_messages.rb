class CreateMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :messages do |t|
      t.references :user, null: false, foreign_key: true
      t.references :community, null: false, foreign_key: true
      t.references :parent_message, null: true, foreign_key: { to_table: :messages }
      t.text :content, null: false
      t.string :user_ip, null: false
      t.float :ai_sentiment_score

      t.timestamps
    end

    add_index :messages, [ :community_id, :created_at ]
    add_index :messages, :user_ip
    add_index :messages, [ :user_ip, :user_id ]
    add_check_constraint :messages, "ai_sentiment_score IS NULL OR (ai_sentiment_score >= -1.0 AND ai_sentiment_score <= 1.0)", name: "messages_ai_sentiment_score_range"
  end
end
