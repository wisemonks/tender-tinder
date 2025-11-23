class ScrapeListJob < ApplicationJob
  queue_as :default

  def perform(page: 1, max_pages: nil)
    scraper = Scrapers::PublicProcurementService.new
    scraper.scrape_list(page: page, max_pages: max_pages)
  end
end
