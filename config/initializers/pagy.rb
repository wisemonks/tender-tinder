# Pagy Configuration
require "pagy/extras/overflow"

# Default items per page
Pagy::DEFAULT[:limit] = 20

# Handle page overflow (return last page instead of error)
Pagy::DEFAULT[:overflow] = :last_page

# Enable metadata for infinite scroll
Pagy::DEFAULT[:metadata] = [ :count, :page, :limit, :pages, :last, :next ]
