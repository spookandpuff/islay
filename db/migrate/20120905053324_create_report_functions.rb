class CreateReportFunctions < ActiveRecord::Migration
  def up
    execute %{
      CREATE OR REPLACE FUNCTION movement_dir(in numeric, in numeric, out text) AS $$
        SELECT
          CASE
            WHEN $1 = $2 THEN 'none'
            WHEN $1 > $2 THEN 'up'
            WHEN $1 < $2 THEN 'down'
          END
      $$ LANGUAGE SQL;

      CREATE OR REPLACE FUNCTION movement_dir(in double precision, in double precision, out text) AS $$
        SELECT
          CASE
            WHEN $1 = $2 THEN 'none'
            WHEN $1 > $2 THEN 'up'
            WHEN $1 < $2 THEN 'down'
          END
      $$ LANGUAGE SQL;

      CREATE OR REPLACE FUNCTION within_this(in text, in timestamp, out boolean) AS $$
        SELECT
          CASE
            WHEN DATE_TRUNC($1, $2) = DATE_TRUNC($1, NOW()) THEN true
            ELSE false
          END
      $$ LANGUAGE SQL;

      CREATE OR REPLACE FUNCTION is_revenue(in text, out boolean) AS $$
        SELECT
          CASE
            WHEN $1 NOT IN ('pending', 'cancelled') THEN true
            ELSE false
          END
      $$ LANGUAGE SQL;

      CREATE OR REPLACE FUNCTION within_last(in text, in timestamp, out boolean) AS $$
        SELECT
          CASE
            WHEN DATE_TRUNC($1, $2) = DATE_TRUNC($1, NOW() - ('1 ' || $1)::interval) THEN true
            ELSE false
          END
      $$ LANGUAGE SQL;

      CREATE OR REPLACE FUNCTION within_dates(in text, in text, in timestamp, out boolean) AS $$
        SELECT
          CASE
            WHEN DATE_TRUNC('day', $3) >= $1 ::timestamp
            AND DATE_TRUNC('day', $3) <= $2 ::timestamp THEN true
            ELSE false
          END
      $$ LANGUAGE SQL
    }
  end

  def down
    execute %{
      DROP FUNCTION IF EXISTS movement_dir(numeric, numeric);
      DROP FUNCTION IF EXISTS movement_dir(double precision, double precision);
      DROP FUNCTION IF EXISTS within_this(text, timestamp);
      DROP FUNCTION IF EXISTS is_revenue(text);
      DROP FUNCTION IF EXISTS within_last(text, timestamp);
      DROP FUNCTION IF EXISTS within_dates(text, text, timestamp)
    }
  end
end
