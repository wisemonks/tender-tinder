class CreateProcurementStars < ActiveRecord::Migration[8.1]
  def change
    create_table :procurement_stars do |t|
      t.references :user, null: false, foreign_key: true
      t.references :procurement, null: false, foreign_key: true

      t.timestamps
    end

    add_index :procurement_stars, [ :user_id, :procurement_id ], unique: true
  end
end
