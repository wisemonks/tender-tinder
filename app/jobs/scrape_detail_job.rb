class ScrapeDetailJob < ApplicationJob
  queue_as :default

  def perform(procurement_id)
    procurement = Procurement.find_by(id: procurement_id)
    return unless procurement

    scraper = Scrapers::PublicProcurementService.new
    scraper.scrape_detail(external_id: procurement.external_id, detail_url: procurement.detail_url)
  end
end
