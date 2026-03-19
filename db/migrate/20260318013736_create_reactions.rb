class CreateReactions < ActiveRecord::Migration[8.1]
  def change
    create_table :reactions do |t|
      t.references :message, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :reaction_type, null: false

      t.timestamps
    end

    add_index :reactions, [ :message_id, :user_id, :reaction_type ], unique: true, name: "index_reactions_unique_per_user_type"
    add_check_constraint :reactions, "reaction_type IN ('like', 'love', 'insightful')", name: "reactions_type_allowed"
  end
end
