class EnablePostgresExtensions < ActiveRecord::Migration[8.1]
  # Disable transactional migrations to handle extension installation gracefully
  disable_ddl_transaction!

  def up
    # Enable pg_trgm for fuzzy text search (required)
    enable_extension "pg_trgm" unless extension_enabled?("pg_trgm")

    # Try to enable pgvector for semantic search (optional)
    unless extension_enabled?("pgvector")
      begin
        execute "CREATE EXTENSION IF NOT EXISTS pgvector"
        puts "✓ pgvector extension enabled - semantic search available"
      rescue ActiveRecord::StatementInvalid => e
        puts "⚠ WARNING: pgvector extension not available. Semantic search will be disabled."
        puts "  To install pgvector: https://github.com/pgvector/pgvector#installation"
      end
    end
  end

  def down
    disable_extension "pg_trgm" if extension_enabled?("pg_trgm")

    if extension_enabled?("pgvector")
      begin
        execute "DROP EXTENSION IF EXISTS pgvector"
      rescue ActiveRecord::StatementInvalid
        # Ignore errors
      end
    end
  end
end
