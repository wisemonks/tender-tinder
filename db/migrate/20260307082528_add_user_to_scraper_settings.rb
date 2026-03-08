class AddUserToScraperSettings < ActiveRecord::Migration[8.1]
  def change
    add_reference :scraper_settings, :user, foreign_key: true

    remove_index :scraper_settings, :key if index_exists?(:scraper_settings, :key)
    add_index :scraper_settings, [ :user_id, :key ], unique: true
  end
end
