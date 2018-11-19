class CreateUpdateStatusFunction < ActiveRecord::Migration[4.2]
  def up
    execute %{
      CREATE OR REPLACE FUNCTION update_status(in timestamp, in timestamp, out text) AS $$
        SELECT
          CASE
            WHEN ($2 - $1) < '5 minute'::interval THEN 'created'
            ELSE 'updated'
          END
      $$ LANGUAGE SQL;
    }
  end

  def down
    execute "DROP FUNCTION IF EXISTS update_status;"
  end
end
