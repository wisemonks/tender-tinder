class AddDetailFieldsToProcurements < ActiveRecord::Migration[8.1]
  def change
    add_column :procurements, :plan_reference, :string           # Pirkimų suvestinės nuoroda
    add_column :procurements, :cpc_category, :string             # SPK kategorija
    add_column :procurements, :procedure_type, :string           # Pirkimo būdas
    add_column :procurements, :cpv_codes, :text                  # BVPŽ kodai
    add_column :procurements, :contract_duration, :string        # Sutarties trukmė mėnesiais arba metais
    add_column :procurements, :evaluation_criteria, :string      # Pasiūlymų vertinimo kriterijai
  end
end
