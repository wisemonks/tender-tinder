class CreateScraperSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :scraper_settings do |t|
      t.string :key, null: false
      t.text :value
      t.string :description
      t.string :setting_type, null: false

      t.timestamps
    end

    add_index :scraper_settings, :key, unique: true
  end
end
