class ScraperSetting < ApplicationRecord
  STATUS_OPTIONS = [
    [ "-Pasirinkite pirkimo būseną-", "" ],
    [ "Vertinimas", "cft.status.evaluation" ],
    [ "Sukurta", "cft.status.established" ],
    [ "Pasiūlymų teikimas", "cft.status.tender.submission" ],
    [ "Archyvuotas", "cft.status.archived" ],
    [ "Atšauktas", "cft.status.cancelled" ],
    [ "Laukiama susipažinimo su pasiūlymais", "cft.status.awaiting.tender.opening" ],
    [ "Nustatytas laimėtojas", "cft.status.award" ],
    [ "Nutrauktas", "cft.status.terminated" ]
  ].freeze

  CONTRACT_TYPE_OPTIONS = [
    [ "-Pasirinkite pirkimo objekto tipą-", "" ],
    [ "Paslaugos", "cft.contract.type.services" ],
    [ "Darbai", "cft.contract.type.works" ],
    [ "Prekės", "cft.contract.type.supplies" ]
  ].freeze

  PROCEDURE_OPTIONS = [
    [ "-Pasirinkite pirkimo būdą-", "" ],
    [ "Atviras konkursas", "cft.procedure.type.open" ],
    [ "Ribotas konkursas", "cft.procedure.type.restricted" ],
    [ "Neskelbiama apklausa", "cft.procedure.type.simplified" ],
    [ "Skelbiama apklausa", "cft.procedure.type.simplified.open" ],
    [ "Konkurencinis dialogas", "cft.procedure.type.competitive.dialogue" ],
    [ "Skelbiamos derybos", "cft.procedure.type.competitive.negotiation" ],
    [ "Neskelbiamos derybos", "cft.procedure.type.negotiated.without.publication" ]
  ].freeze

  CPC_CATEGORY_OPTIONS = [
    [ "-Pasirinkite Svarbiausio produktų klasifikatoriaus (SPK) kategoriją-", "" ],
    [ "Techninės priežiūros ir remonto paslaugos", "1" ],
    [ "Sausumos transporto paslaugos, įskaitant šarvuotų automobilių paslaugas ir pasiuntinių paslaugas, išskyrus pašto pervežimą", "2" ],
    [ "Keleivių ir krovinių vežimo oro transportu paslaugos, išskyrus pašto vežimą", "3" ],
    [ "Pašto gabenimas sausuma ir oru", "4" ],
    [ "Telekomunikacijų paslaugos", "5" ],
    [ "Finansinės paslaugos: a) draudimo paslaugos, b) bankininkystės ir investicinės paslaugos", "6" ],
    [ "Kompiuterių ir susijusios paslaugos", "7" ],
    [ "Mokslinių tyrimų ir plėtros paslaugos", "8" ],
    [ "Apskaitos, audito ir fiskalinės paslaugos", "9" ],
    [ "Rinkos tyrimų ir viešosios nuomonės apklausų paslaugos", "10" ],
    [ "Vadybos konsultacinės paslaugos ir susijusios paslaugos", "11" ],
    [ "Architektūros paslaugos; inžinerijos paslaugos ir integruotos inžinerijos paslaugos...", "12" ],
    [ "Reklamos paslaugos", "13" ],
    [ "Pastatų valymo paslaugos ir nekilnojamojo turto valdymo paslaugos", "14" ],
    [ "Leidybos ir spausdinimo paslaugos už atlygį arba pagal sutartį", "15" ],
    [ "Nuotekų ir šiukšlių šalinimo paslaugos; sanitarijos ir panašios paslaugos", "16" ],
    [ "Viešbučių ir restoranų paslaugos", "17" ],
    [ "Geležinkelių transporto paslaugos", "18" ],
    [ "Vandens transporto paslaugos", "19" ],
    [ "Papildomosios ir pagalbinės transporto paslaugos", "20" ],
    [ "Teisinės paslaugos", "21" ],
    [ "Personalo įdarbinimo ir tiekimo paslaugos", "22" ],
    [ "Tyrimų ir apsaugos paslaugos, išskyrus šarvuotų automobilių paslaugas", "23" ],
    [ "Švietimo ir profesinio mokymo paslaugos", "24" ],
    [ "Sveikatos ir socialinės paslaugos", "25" ],
    [ "Rekreacinės, kultūrinės ir sporto paslaugos", "26" ],
    [ "Kitos paslaugos", "27" ]
  ].freeze

  DEFAULTS = {
    "keywords" => { value: "", description: "Raktažodžiai, pagal kuriuos atrenkami pirkimai", type: "text" },
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
    "digest_emails" => { value: "", description: "El. pašto adresai kasdienei santraukai (atskirti kableliais)", type: "text" }
  }.freeze

  OPTION_SETS = {
    "status" => STATUS_OPTIONS,
    "contract_type" => CONTRACT_TYPE_OPTIONS,
    "procedure" => PROCEDURE_OPTIONS,
    "cpc_category" => CPC_CATEGORY_OPTIONS
  }.freeze

  belongs_to :user, optional: true

  validates :key, presence: true, uniqueness: { scope: :user_id }
  validates :setting_type, presence: true

  TYPES = %w[text select date date_range number number_range multiselect].freeze

  validates :setting_type, inclusion: { in: TYPES }

  def self.get(key, user:)
    where(user: user).find_by(key: key)&.value
  end

  def self.set(key, value, user:, description: nil, setting_type: nil)
    setting = where(user: user).find_or_initialize_by(key: key)
    setting.value = value
    setting.description = description unless description.nil?
    setting.setting_type = setting_type || setting.setting_type || default_type_for(key)
    setting.save
    setting
  end

  def self.as_hash(user:)
    where(user: user).pluck(:key, :value).to_h
  end

  def self.initialize_defaults(user:)
    DEFAULTS.each do |key, config|
      setting = where(user: user).find_or_initialize_by(key: key)
      setting.value = config[:value] if setting.new_record?
      setting.description ||= config[:description]
      setting.setting_type ||= config[:type]
      setting.save!
    end
  end

  def self.default_type_for(key)
    DEFAULTS.dig(key, :type) || "text"
  end

  def self.options_for(key)
    OPTION_SETS.fetch(key.to_s, [])
  end

  def self.option_label_for(key, value)
    return if value.blank?

    options_for(key).to_h.key(value)
  end

  def self.keyword_list_for(user)
    get("keywords", user: user)
      .to_s
      .split(/[\n,;]/)
      .map(&:strip)
      .reject(&:blank?)
      .uniq
  end
end
