class EnablePostgresExtensions < ActiveRecord::Migration[7.2]
  def change
    # Enable UUID generation support
    # Useful for generating unique identifiers for records
    enable_extension 'uuid-ossp' unless extension_enabled?('uuid-ossp')
    
    # Enable trigram support for fuzzy text searching
    # Useful for searching video captions and descriptions
    enable_extension 'pg_trgm' unless extension_enabled?('pg_trgm')
    
    # Enable pgcrypto for additional cryptographic functions
    # Useful for generating random tokens and secure hashes
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')
  end
end