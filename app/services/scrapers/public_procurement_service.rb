module Scrapers
  class PublicProcurementService
    BASE_URL = "https://viesiejipirkimai.lt"
    LIST_URL = "#{BASE_URL}/epps/viewCFTSAction.do"

    attr_reader :client, :settings, :user

    def initialize(settings: {}, user: nil)
      @settings = settings
      @user = user

      @client = Faraday.new do |f|
        f.request :url_encoded
        f.request :retry, max: 3, interval: 0.5
        f.adapter Faraday.default_adapter
        f.headers["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
        f.headers["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
        f.headers["Accept-Language"] = "lt,en;q=0.9"
      end
    end

    def scrape_list(page: 1, max_pages: nil, inline_details: true)
      current_page = page
      scraped_count = 0
      total_pages = nil

      loop do
        Rails.logger.info "Scraping list page #{current_page}#{total_pages ? " of ~#{total_pages}" : ''}"

        response = fetch_list_page(current_page)
        break unless response.success?

        doc = Nokogiri::HTML(response.body)

        if total_pages.nil?
          total_pages = extract_total_pages(doc)
          Rails.logger.info "Found approximately #{total_pages} total pages to scrape" if total_pages
        end

        rows = parse_list_rows(doc)
        break if rows.empty?

        rows.each do |row_data|
          process_list_row(row_data, inline_details: inline_details)
          scraped_count += 1
        end

        if current_page % 10 == 0
          Rails.logger.info "Progress: Scraped #{scraped_count} procurements from #{current_page} pages"
        end

        break unless has_next_page?(doc)
        break if max_pages && current_page >= max_pages

        current_page += 1
        sleep(1)
      end

      Rails.logger.info "✓ Completed: Scraped #{scraped_count} procurements from #{current_page} pages"
      scraped_count
    end

    def scrape_detail(external_id:, detail_url:)
      Rails.logger.info "Scraping detail for procurement #{external_id}"

      response = fetch_detail_page(detail_url)
      return unless response.success?

      doc = Nokogiri::HTML(response.body)
      detail_data = parse_detail_page(doc)

      procurement = Procurement.find_or_initialize_by(external_id: external_id)
      procurement.assign_attributes(detail_data.merge(url: detail_url, raw_html: doc.to_s))

      if procurement.save
        Rails.logger.info "Successfully saved procurement #{external_id}"
      else
        Rails.logger.error "Failed to save procurement #{external_id}: #{procurement.errors.full_messages}"
      end

      procurement
    end

    private

    def fetch_list_page(page)
      publication_from = format_date_param(settings["publication_from_date"])
      publication_to = format_date_param(settings["publication_to_date"])
      submission_from = format_date_param(settings["submission_from_date"])
      submission_to = format_date_param(settings["submission_to_date"])

      params = {
        "mode" => "search",
        "isFTS" => "true",
        "type" => "cftFTS",
        "isPopup" => "false",
        "popupMode" => "",
        "viewMode" => "",
        "d-3680175-p" => page.to_s,
        "cftId" => "",
        "title" => "",
        "uniqueId" => "",
        "contractAuthority" => "",
        "description" => "",
        "status" => settings["status"].to_s,
        "contractType" => settings["contract_type"].to_s,
        "procedure" => settings["procedure"].to_s,
        "cpcCategory" => settings["cpc_category"].to_s,
        "submissionFromDate" => submission_from,
        "submissionUntilDate" => submission_to,
        "tenderOpeningFromDate" => "",
        "tenderOpeningUntilDate" => "",
        "publicationFromDate" => publication_from,
        "publicationUntilDate" => publication_to,
        "cpvLabels" => "",
        "estimatedValueMin" => settings["estimated_value_min"].to_s,
        "estimatedValueMax" => settings["estimated_value_max"].to_s
      }

      client.post(LIST_URL, params)
    rescue => e
      Rails.logger.error "Error fetching list page #{page}: #{e.message}"
      Faraday::Response.new(status: 500)
    end

    def format_date_param(date_string)
      return "" if date_string.blank?

      Date.parse(date_string).strftime("%d/%m/%Y")
    rescue
      ""
    end

    def fetch_detail_page(url)
      full_url = url.start_with?("http") ? url : "#{BASE_URL}#{url}"
      client.get(full_url)
    rescue => e
      Rails.logger.error "Error fetching detail page #{url}: #{e.message}"
      Faraday::Response.new(status: 500)
    end

    def parse_list_rows(doc)
      rows = []
      search_results = doc.css("div.tablesaw-overflow.SearchResults")
      return rows if search_results.empty?

      table = search_results.first.css("#T01 tbody tr")
      table.each do |row|
        cells = row.css("td")
        next if cells.empty?

        title_cell = cells[1]
        title_link = title_cell&.css("a")&.first

        row_data = {
          external_id: cells[2]&.text&.strip,
          title: title_link&.text&.strip || title_cell&.text&.strip,
          authority_name: cells[3]&.text&.strip,
          publication_date: parse_datetime(cells[5]&.text&.strip),
          deadline_date: parse_datetime(cells[6]&.text&.strip),
          procedure_type: cells[7]&.text&.strip,
          status: cells[8]&.text&.strip,
          estimated_value: parse_decimal(cells[11]&.text&.strip),
          detail_url: title_link&.[]("href")
        }

        rows << row_data if row_data[:external_id].present?
      end

      rows
    end

    def parse_date(date_string)
      return nil if date_string.blank?

      Date.parse(date_string)
    rescue
      nil
    end

    def has_next_page?(doc)
      pagination = doc.css("div.Pagination6").first
      return false unless pagination

      next_button = pagination.css("button#nextNav").first
      return false unless next_button

      !next_button["disabled"]
    end

    def extract_total_pages(doc)
      pagination = doc.css("div.Pagination6").first
      return nil unless pagination

      last_button = pagination.css("button#lastNav").first
      if last_button && last_button["href"]
        href = last_button["href"]
        return Regexp.last_match(1).to_i if href =~ /d-\d+-p=(\d+)/
      end

      nil
    end

    def process_list_row(row_data, inline_details:)
      return unless row_data[:external_id].present?

      procurement = Procurement.find_or_initialize_by(external_id: row_data[:external_id])
      procurement.title = row_data[:title]
      procurement.authority_name = row_data[:authority_name]
      procurement.publication_date = row_data[:publication_date] if row_data.key?(:publication_date)
      procurement.deadline_date = row_data[:deadline_date] if row_data.key?(:deadline_date)
      procurement.procedure_type = row_data[:procedure_type] if row_data[:procedure_type].present?
      procurement.status = row_data[:status] if row_data[:status].present?
      procurement.estimated_value = row_data[:estimated_value] unless row_data[:estimated_value].nil?
      procurement.url = row_data[:detail_url] if row_data[:detail_url].present?

      return unless procurement.save
      return unless detail_refresh_needed?(procurement)

      if inline_details
        scrape_detail(external_id: procurement.external_id, detail_url: procurement.detail_url)
      else
        ScrapeDetailJob.perform_later(procurement.id)
      end
    end

    def detail_refresh_needed?(procurement)
      procurement.raw_html.blank? || procurement.description.blank? || procurement.contract_type.blank?
    end

    def parse_detail_page(doc)
      data = {}
      main_container = doc.css("#main-container").first
      return data unless main_container

      main_container.css("dl.row").each do |dl|
        dl.css("dt").each do |dt|
          key = dt.text.strip
          dd = dt.next_element
          next unless dd&.name == "dd"

          value = dd.text.strip

          case key
          when /Pirkimo vykdytojo pavadinimas/i
            data[:authority_name] = value
          when /Aprašymas|Pirkimo objekto apibūdinimas/i
            data[:description] = value
          when /Pirkimo objekto tipas/i
            data[:contract_type] = value
          when /Preliminari pirkimo vertė|Numatoma vertė/i
            data[:estimated_value] = parse_decimal(value)
          when /Būsena|Statusas/i
            data[:status] = value
          when /Paskelbimo data|Paskelbimo ir.*kvietimo data/i
            data[:publication_date] = parse_datetime(value) || parse_date(value)
          when /Pasiūlymų.*pateikimo terminas|Pasiūlymų arba paraiškų/i
            data[:deadline_date] = parse_datetime(value)
          when /Pirkimų suvestinės nuoroda/i
            data[:plan_reference] = value
          when /SPK kategorija/i
            data[:cpc_category] = value
          when /Pirkimo būdas/i
            data[:procedure_type] = value
          when /BVPŽ kodai/i
            data[:cpv_codes] = value
          when /Sutarties trukmė mėnesiais arba metais/i
            data[:contract_duration] = value
          when /Pasiūlymų vertinimo kriterijai/i
            data[:evaluation_criteria] = value
          end
        end
      end

      data
    end

    def parse_decimal(value)
      return nil if value.blank?

      value.gsub(/[^\d,.]/, "").gsub(",", ".").to_f
    end

    def parse_datetime(value)
      return nil if value.blank?

      DateTime.parse(value)
    rescue
      nil
    end
  end
end
