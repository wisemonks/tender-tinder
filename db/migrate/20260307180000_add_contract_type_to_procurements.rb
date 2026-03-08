class AddContractTypeToProcurements < ActiveRecord::Migration[8.1]
  def change
    add_column :procurements, :contract_type, :string
  end
end
