class RemoveIsStarredFromProcurements < ActiveRecord::Migration[8.1]
  def change
    remove_column :procurements, :is_starred, :boolean
  end
end
