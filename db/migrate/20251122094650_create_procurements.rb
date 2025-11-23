class CreateProcurements < ActiveRecord::Migration[8.1]
  def change
    create_table :procurements do |t|
      t.string :external_id
      t.text :title
      t.string :authority_name
      t.text :description
      t.string :status
      t.datetime :publication_date
      t.datetime :deadline_date
      t.decimal :estimated_value
      t.string :url
      t.text :raw_html
      t.boolean :is_starred, default: false

      t.timestamps
    end

    add_index :procurements, :external_id, unique: true
    add_index :procurements, :is_starred
    add_index :procurements, :publication_date
  end
end
