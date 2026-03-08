class ScrapeListJob < ApplicationJob
  queue_as :default

  def perform(page: 1, max_pages: nil, user_id: nil, inline_details: true)
    scraper = Scrapers::PublicProcurementService.new
    scraper.scrape_list(page: page, max_pages: max_pages, inline_details: inline_details)
  end
end
