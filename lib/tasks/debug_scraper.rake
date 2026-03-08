namespace :scraper do
  desc "Debug the scraper by checking HTML structure (without settings)"
  task debug: :environment do
    require "faraday"
    require "nokogiri"

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

  desc "Show what the current user filters would match locally"
  task test_settings: :environment do
    puts "🔥 Testing Local Procurement Filters"
    puts "=" * 80

    user = User.first

    if user.nil?
      puts "⚠️  Nerastas nė vienas vartotojas."
      puts "\n" + "=" * 80
      exit
    end

    puts "\n⚙️  Dabartiniai vartotojo nustatymai:"
    puts "-" * 80
    settings = ScraperSetting.as_hash(user: user)

    settings.each do |key, value|
      setting_record = user.scraper_settings.find_by(key: key)
      display_value = value.present? ? value : "(empty)"
      description = setting_record&.description || key
      puts "  #{description.ljust(40)} = #{display_value}"
    end

    puts "\n🗂️  Tikriname, ką parodytų lokalūs filtrai..."
    puts "-" * 80

    results = user.filtered_procurements.recent

    puts "✅ Lokalūs filtrai atrinko #{results.count} procurement(s)"

    if results.none?
      puts "⚠️  Nėra pirkimų, atitinkančių dabartines taisykles."
      puts "Pabandykite praplėsti filtrus arba pakeisti raktažodžius."
    else
      puts "\n📋 Pirmi #{[ results.count, 5 ].min} rezultatai:"
      puts "=" * 80

      results.limit(5).each_with_index do |procurement, idx|
        puts "\n#{idx + 1}. #{procurement.title}"
        puts "   ID: #{procurement.external_id}"
        puts "   Authority: #{procurement.authority_name}"
        puts "   Status: #{procurement.status}"
        puts "   Publication: #{procurement.publication_date}"
        puts "   Deadline: #{procurement.deadline_date}"
      end

      if results.count > 5
        puts "\n... ir dar #{results.count - 5} rezultatai(-ų)"
      end
    end

    puts "\n" + "=" * 80
    puts "✅ Done! Tai yra tai, ką matys vartotojas pagal savo taisykles."
    puts "=" * 80
  end
end
