namespace :scraper do
  desc "Debug POST request to see what's being sent"
  task debug_post: :environment do
    require 'faraday'
    require 'nokogiri'

    puts "🔍 Debugging POST request..."
    puts "=" * 80

    # Initialize service
    service = Scrapers::PublicProcurementService.new

    # Get settings
    settings = ScraperSetting.as_hash

    puts "\n📋 Current Settings:"
    settings.each { |k, v| puts "  #{k} = #{v.inspect}" }

    # Try to fetch the page
    puts "\n🌐 Attempting to fetch page..."

    begin
      response = service.send(:fetch_list_page, 1)

      puts "\n📊 Response Details:"
      puts "  Status: #{response.status}"
      puts "  Headers: #{response.headers.to_h.inspect}"

      if response.success?
        puts "\n✅ Success!"
        puts "  Body length: #{response.body.length} bytes"

        # Try to parse
        doc = Nokogiri::HTML(response.body)
        rows = service.send(:parse_list_rows, doc)
        puts "  Parsed rows: #{rows.count}"
      else
        puts "\n❌ Failed!"
        puts "  Body preview (first 500 chars):"
        puts response.body[0..500]
      end
    rescue => e
      puts "\n💥 Exception:"
      puts "  #{e.class}: #{e.message}"
      puts "  Backtrace:"
      e.backtrace.first(5).each { |line| puts "    #{line}" }
    end

    puts "\n" + "=" * 80
  end

  desc "Test POST request with manual Faraday client"
  task test_manual_post: :environment do
    require 'faraday'
    require 'uri'

    puts "🔍 Testing manual POST request..."
    puts "=" * 80

    url = "https://viesiejipirkimai.lt/epps/viewCFTSAction.do"

    # Simple params first
    params = {
      "mode" => "search",
      "isFTS" => "true",
      "type" => "cftFTS",
      "isPopup" => "false",
      "popupMode" => "",
      "viewMode" => "",
      "cftId" => "",
      "title" => "",
      "uniqueId" => "",
      "contractAuthority" => "",
      "description" => "",
      "status" => "",
      "contractType" => "cft.contract.type.services",
      "procedure" => "",
      "cpcCategory" => "7",
      "submissionFromDate" => "",
      "submissionUntilDate" => "",
      "tenderOpeningFromDate" => "",
      "tenderOpeningUntilDate" => "",
      "publicationFromDate" => "01/11/2025",
      "publicationUntilDate" => "",
      "cpvLabels" => "",
      "estimatedValueMin" => "",
      "estimatedValueMax" => ""
    }

    puts "\n📤 Sending POST request..."
    puts "URL: #{url}"
    puts "\nParams:"
    params.each { |k, v| puts "  #{k} = #{v.inspect}" }

    client = Faraday.new do |f|
      f.request :url_encoded
      f.request :retry, max: 2, interval: 0.5
      f.adapter Faraday.default_adapter

      f.headers['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
      f.headers['Accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
      f.headers['Accept-Language'] = 'lt,en;q=0.9'
    end

    begin
      response = client.post(url, params)

      puts "\n📊 Response:"
      puts "  Status: #{response.status}"
      puts "  Content-Type: #{response.headers['content-type']}"
      puts "  Body length: #{response.body.length}"

      if response.success?
        puts "\n✅ Request succeeded!"

        # Check for results
        doc = Nokogiri::HTML(response.body)
        table = doc.css("#T01 tbody tr")
        puts "  Found #{table.length} rows in results table"

        if table.any?
          puts "\n📋 First result:"
          first_row = table.first
          title = first_row.css("td")[1]&.text&.strip
          id = first_row.css("td")[2]&.text&.strip
          puts "  Title: #{title}"
          puts "  ID: #{id}"
        end
      else
        puts "\n❌ Request failed!"
        puts "\nResponse body preview:"
        puts response.body[0..1000]
      end
    rescue => e
      puts "\n💥 Exception: #{e.class}"
      puts "  Message: #{e.message}"
      puts "  Backtrace:"
      e.backtrace.first(10).each { |line| puts "    #{line}" }
    end

    puts "\n" + "=" * 80
  end
end
