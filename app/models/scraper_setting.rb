class ScraperSetting < ApplicationRecord
  validates :key, presence: true, uniqueness: true
  validates :setting_type, presence: true

  # Setting types
  TYPES = %w[text select date_range number_range multiselect].freeze

  validates :setting_type, inclusion: { in: TYPES }

  # Get a setting value by key
  def self.get(key)
    find_by(key: key)&.value
  end

  # Set a setting value by key
  def self.set(key, value, description: nil, setting_type: "text")
    setting = find_or_initialize_by(key: key)
    setting.value = value
    setting.description = description if description
    setting.setting_type = setting_type
    setting.save
    setting
  end

  # Get all settings as a hash
  def self.as_hash
    all.pluck(:key, :value).to_h
  end

  # Initialize default settings
  def self.initialize_defaults
    defaults = {
      "status" => { value: "", description: "Pirkimo būsena", type: "select" },
      "contract_type" => { value: "", description: "Pirkimo objekto tipas", type: "select" },
      "procedure" => { value: "", description: "Pirkimo būdas", type: "select" },
      "cpc_category" => { value: "", description: "SPK kategorija", type: "select" },
      "publication_from_date" => { value: "", description: "Paskelbimo data nuo", type: "date" },
      "publication_to_date" => { value: "", description: "Paskelbimo data iki", type: "date" },
      "submission_from_date" => { value: "", description: "Pasiūlymų terminas nuo", type: "date" },
      "submission_to_date" => { value: "", description: "Pasiūlymų terminas iki", type: "date" },
      "estimated_value_min" => { value: "", description: "Minimali vertė (EUR)", type: "number" },
      "estimated_value_max" => { value: "", description: "Maksimali vertė (EUR)", type: "number" },
      "digest_emails" => { value: "", description: "El. pašto adresai naujienlaiškiui (atskirti kableliais)", type: "text" }
    }

    defaults.each do |key, config|
      set(key, config[:value], description: config[:description], setting_type: config[:type])
    end
  end
end
