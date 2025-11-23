namespace :scraper do
  desc "Debug the scraper by checking HTML structure (without settings)"
  task debug: :environment do
    require 'faraday'
    require 'nokogiri'

    puts "🔍 Debugging scraper..."
    puts "=" * 50

    service = Scrapers::PublicProcurementService.new
    response = service.send(:fetch_list_page, 1)

    if response.success?
      puts "✅ Successfully fetched page"
      puts "Response size: #{response.body.length} bytes"

      doc = Nokogiri::HTML(response.body)

      # Check for search results container
      search_results = doc.css("div.tablesaw-overflow.SearchResults")
      puts "\nSearch Results containers found: #{search_results.length}"

      if search_results.any?
        puts "✅ Found SearchResults div"

        # Check for table
        table = search_results.first.css("#T01")
        puts "Table #T01 found: #{table.any?}"

        if table.any?
          rows = table.css("tbody tr")
          puts "Rows in tbody: #{rows.length}"

          if rows.any?
            puts "\n📊 First row structure:"
            first_row = rows.first
            first_row.css("td").each_with_index do |td, i|
              data_column = td["data-column"]
              text = td.text.strip[0..50]
              puts "  Column #{i}: [data-column='#{data_column}'] = #{text}"
            end
          else
            puts "❌ No rows found in tbody"
          end
        else
          puts "❌ Table #T01 not found"
          puts "\nAvailable IDs:"
          doc.css("[id]").first(10).each do |el|
            puts "  - ##{el['id']}"
          end
        end
      else
        puts "❌ SearchResults div not found"
        puts "\nAvailable classes with 'search' or 'result':"
        doc.css("[class*='search'], [class*='result'], [class*='Search'], [class*='Result']").first(10).each do |el|
          puts "  - .#{el['class']}"
        end
      end

      # Save HTML for inspection
      File.write("tmp/debug_page.html", response.body)
      puts "\n💾 Full HTML saved to: tmp/debug_page.html"
      puts "You can open this file in a browser to inspect the structure"

    else
      puts "❌ Failed to fetch page"
      puts "Status: #{response.status}"
    end

    puts "\n" + "=" * 50
  end

  desc "Test scraper with current ScraperSettings and show first page results"
  task test_settings: :environment do
    puts "🔥 Testing Scraper with Current Settings"
    puts "=" * 80

    # Show current settings
    puts "\n⚙️  Current ScraperSettings:"
    puts "-" * 80
    settings = ScraperSetting.as_hash

    if settings.empty?
      puts "⚠️  No settings found! Run: rails runner 'ScraperSetting.initialize_defaults'"
      puts "\n" + "=" * 80
      exit
    end

    settings.each do |key, value|
      setting_record = ScraperSetting.find_by(key: key)
      display_value = value.present? ? value : "(empty)"
      description = setting_record&.description || key
      puts "  #{description.ljust(40)} = #{display_value}"
    end

    # Fetch and parse first page with settings
    puts "\n🌐 Fetching first page with these settings..."
    puts "-" * 80

    service = Scrapers::PublicProcurementService.new
    response = service.send(:fetch_list_page, 1)

    unless response.success?
      puts "❌ Failed to fetch page (Status: #{response.status})"
      puts "\n" + "=" * 80
      exit
    end

    doc = Nokogiri::HTML(response.body)
    rows = service.send(:parse_list_rows, doc)

    puts "✅ Successfully fetched and parsed page"
    puts "📊 Found #{rows.count} procurement(s) matching your settings\n"

    if rows.empty?
      puts "⚠️  No results found with current settings."
      puts "Try adjusting your ScraperSettings to get more results."
    else
      puts "\n📋 First #{[rows.count, 5].min} result(s):"
      puts "=" * 80

      rows.first(5).each_with_index do |row, idx|
        puts "\n#{idx + 1}. #{row[:title]}"
        puts "   ID: #{row[:external_id]}"
        puts "   Authority: #{row[:authority_name]}"
        puts "   Status: #{row[:status]}"
        puts "   Publication: #{row[:publication_date]}"
        puts "   Deadline: #{row[:deadline_date]}"
      end

      if rows.count > 5
        puts "\n... and #{rows.count - 5} more result(s)"
      end
    end

    # Save full HTML for inspection
    File.write("tmp/debug_with_settings.html", response.body)
    puts "\n💾 Full HTML saved to: tmp/debug_with_settings.html"

    puts "\n" + "=" * 80
    puts "✅ Done! This is what ScrapeListJob will scrape with your current settings."
    puts "=" * 80
  end
end
