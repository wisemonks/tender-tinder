class SettingsController < ApplicationController
  # Status options from the form - [Label, Value] format
  STATUS_OPTIONS = [
    ["-Pasirinkite pirkimo būseną-", ""],
    ["Vertinimas", "cft.status.evaluation"],
    ["Sukurta", "cft.status.established"],
    ["Pasiūlymų teikimas", "cft.status.tender.submission"],
    ["Archyvuotas", "cft.status.archived"],
    ["Atšauktas", "cft.status.cancelled"],
    ["Laukiama susipažinimo su pasiūlymais", "cft.status.awaiting.tender.opening"],
    ["Nustatytas laimėtojas", "cft.status.award"],
    ["Nutrauktas", "cft.status.terminated"]
  ].freeze

  # Contract type options - [Label, Value] format
  CONTRACT_TYPE_OPTIONS = [
    ["-Pasirinkite pirkimo objekto tipą-", ""],
    ["Paslaugos", "cft.contract.type.services"],
    ["Darbai", "cft.contract.type.works"],
    ["Prekės", "cft.contract.type.supplies"]
  ].freeze

  # Procedure options - [Label, Value] format
  PROCEDURE_OPTIONS = [
    ["-Pasirinkite pirkimo būdą-", ""],
    ["Atviras konkursas", "cft.procedure.type.open"],
    ["Ribotas konkursas", "cft.procedure.type.restricted"],
    ["Neskelbiama apklausa", "cft.procedure.type.simplified"],
    ["Skelbiama apklausa", "cft.procedure.type.simplified.open"],
    ["Konkurencinis dialogas", "cft.procedure.type.competitive.dialogue"],
    ["Skelbiamos derybos", "cft.procedure.type.competitive.negotiation"],
    ["Neskelbiamos derybos", "cft.procedure.type.negotiated.without.publication"]
  ].freeze

  # CPC Category options - [Label, Value] format (complete list)
  CPC_CATEGORY_OPTIONS = [
    ["-Pasirinkite Svarbiausio produktų klasifikatoriaus (SPK) kategoriją-", ""],
    ["Techninės priežiūros ir remonto paslaugos", "1"],
    ["Sausumos transporto paslaugos, įskaitant šarvuotų automobilių paslaugas ir pasiuntinių paslaugas, išskyrus pašto pervežimą", "2"],
    ["Keleivių ir krovinių vežimo oro transportu paslaugos, išskyrus pašto vežimą", "3"],
    ["Pašto gabenimas sausuma ir oru", "4"],
    ["Telekomunikacijų paslaugos", "5"],
    ["Finansinės paslaugos: a) draudimo paslaugos, b) bankininkystės ir investicinės paslaugos", "6"],
    ["Kompiuterių ir susijusios paslaugos", "7"],
    ["Mokslinių tyrimų ir plėtros paslaugos", "8"],
    ["Apskaitos, audito ir fiskalinės paslaugos", "9"],
    ["Rinkos tyrimų ir viešosios nuomonės apklausų paslaugos", "10"],
    ["Vadybos konsultacinės paslaugos ir susijusios paslaugos", "11"],
    ["Architektūros paslaugos; inžinerijos paslaugos ir integruotos inžinerijos paslaugos...", "12"],
    ["Reklamos paslaugos", "13"],
    ["Pastatų valymo paslaugos ir nekilnojamojo turto valdymo paslaugos", "14"],
    ["Leidybos ir spausdinimo paslaugos už atlygį arba pagal sutartį", "15"],
    ["Nuotekų ir šiukšlių šalinimo paslaugos; sanitarijos ir panašios paslaugos", "16"],
    ["Viešbučių ir restoranų paslaugos", "17"],
    ["Geležinkelių transporto paslaugos", "18"],
    ["Vandens transporto paslaugos", "19"],
    ["Papildomosios ir pagalbinės transporto paslaugos", "20"],
    ["Teisinės paslaugos", "21"],
    ["Personalo įdarbinimo ir tiekimo paslaugos", "22"],
    ["Tyrimų ir apsaugos paslaugos, išskyrus šarvuotų automobilių paslaugas", "23"],
    ["Švietimo ir profesinio mokymo paslaugos", "24"],
    ["Sveikatos ir socialinės paslaugos", "25"],
    ["Rekreacinės, kultūrinės ir sporto paslaugos", "26"],
    ["Kitos paslaugos", "27"]
  ].freeze

  def show
    # Initialize defaults if settings don't exist
    ScraperSetting.initialize_defaults if ScraperSetting.count.zero?

    @settings = ScraperSetting.all.index_by(&:key)
    @status_options = STATUS_OPTIONS
    @contract_type_options = CONTRACT_TYPE_OPTIONS
    @procedure_options = PROCEDURE_OPTIONS
    @cpc_category_options = CPC_CATEGORY_OPTIONS
  end

  def update
    settings_params.each do |key, value|
      ScraperSetting.set(key, value)
    end

    redirect_to settings_path, notice: "Nustatymai sėkmingai išsaugoti"
  end

  private

  def settings_params
    params.require(:settings).permit(
      :status,
      :contract_type,
      :procedure,
      :cpc_category,
      :publication_from_date,
      :publication_to_date,
      :submission_from_date,
      :submission_to_date,
      :estimated_value_min,
      :estimated_value_max,
      :digest_emails
    )
  end
end
