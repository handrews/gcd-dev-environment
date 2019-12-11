LOAD DATA INFILE '/var/lib/mysql-files/publisher.tsv'
    INTO TABLE gcd_publisher;

LOAD DATA INFILE '/var/lib/mysql-files/indicia-publisher.tsv'
    INTO TABLE gcd_indicia_publisher;

LOAD DATA INFILE '/var/lib/mysql-files/brand-group.tsv'
    INTO TABLE gcd_brand_group;

LOAD DATA INFILE '/var/lib/mysql-files/brand.tsv'
    INTO TABLE gcd_brand;

LOAD DATA INFILE '/var/lib/mysql-files/brand-emblem-group.tsv'
    INTO TABLE gcd_brand_emblem_group;

LOAD DATA INFILE '/var/lib/mysql-files/brand-use.tsv'
    INTO TABLE gcd_brand_use;

LOAD DATA INFILE '/var/lib/mysql-files/series.tsv'
    INTO TABLE gcd_series (
        id,
        name,
        sort_name,
        format,
        color,
        dimensions,
        paper_stock,
        binding,
        publishing_format,
        notes,
        year_began,
        year_ended,
        year_began_uncertain,
        year_ended_uncertain,
        is_current,
        publication_dates,
        issue_count,
        tracking_notes,
        has_barcode,
        has_indicia_frequency,
        has_isbn,
        has_issue_title,
        has_volume,
        has_rating,
        is_comics_publication,
        is_singleton,
        has_gallery,
        created,
        modified,
        deleted,
        country_id,
        -- first_issue_id,
        language_id,
        -- last_issue_id,
        publication_type_id,
        publisher_id,
        has_about_comics);

LOAD DATA INFILE '/var/lib/mysql-files/issue.tsv'
    INTO TABLE gcd_issue;

UPDATE gcd_series s SET s.first_issue_id=(
    SELECT i.id FROM gcd_issue i WHERE i.series_id=s.id
        ORDER BY i.sort_code ASC LIMIT 1);

UPDATE gcd_series s SET s.last_issue_id=(
    SELECT i.id FROM gcd_issue i WHERE i.series_id=s.id
        ORDER BY i.sort_code DESC LIMIT 1);

LOAD DATA INFILE '/var/lib/mysql-files/story.tsv'
    INTO TABLE gcd_story;

LOAD DATA INFILE '/var/lib/mysql-files/series-bond.tsv'
    INTO TABLE gcd_series_bond;

LOAD DATA INFILE '/var/lib/mysql-files/reprint.tsv'
    INTO TABLE gcd_reprint;

LOAD DATA INFILE '/var/lib/mysql-files/reprint-to-issue.tsv'
    INTO TABLE gcd_reprint_to_issue;

LOAD DATA INFILE '/var/lib/mysql-files/reprint-from-issue.tsv'
    INTO TABLE gcd_reprint_from_issue;

LOAD DATA INFILE '/var/lib/mysql-files/issue-reprint.tsv'
    INTO TABLE gcd_issue_reprint;
