-- Set these ids to determine the scope of data abstraction.
--
-- Within the extraction scope, all connections (reprints, series bonds, etc.)
-- among objects within the scope will be extracted, as will all shared
-- objects (brand groups) that are used within the scope.

-- Everything under these master publishers will be extracted.
CREATE TEMPORARY TABLE initial_pubs AS
    SELECT id FROM gcd_publisher WHERE id IN (
        58,     -- Centaur
        74,     -- Fox
        92,     -- Holyoke
        112,    -- Chesler / Dynamic
        129,    -- Temerson / Helnit / Continental
        7618,   -- Worth Carnahan
        7628,   -- Comics Magazine Company
        7631);  -- Ultem

-- These additional series, plus the publisher/branding objects that they use,
-- but no other series included in those publishers/brands, will be extracted.
CREATE TEMPORARY TABLE extra_series AS
    SELECT s.id FROM gcd_series s WHERE s.id IN (
        134,    -- Speed Comics (Harvey, 1941 series)
        176,    -- Champ Comics (Harvey, 1940 series)
        232,    -- Pocket Comics (Harvey, 1941 series)
        233,    -- Spitfire Comics (Harvey, 1941 series)
        293,    -- Green Hornet Comics (Harvey, 1941 series)
        321,    -- All-New Comics (Harvey, 1943 series)
        322);   -- All-New Short Story Comics (Harvey, 1943 series)

-- More "initial" tables, to use to gather all things under initial pubs.

CREATE TEMPORARY TABLE initial_series AS
    SELECT s.id FROM gcd_series s
        INNER JOIN initial_pubs ip ON s.publisher_id=ip.id;

CREATE TEMPORARY TABLE initial_issues AS
    SELECT i.id FROM gcd_issue i
        INNER JOIN initial_series ise ON i.series_id=ise.id;

CREATE TEMPORARY TABLE initial_stories AS
    SELECT t.id FROM gcd_story t
        INNER JOIN initial_issues ii ON t.issue_id=ii.id;

-- More "extra" tables, to use to gether all things related to extra series.

CREATE TEMPORARY TABLE extra_pubs AS
        SELECT DISTINCT s.publisher_id AS id
            FROM gcd_series s INNER JOIN extra_series es ON s.id=es.id;

CREATE TEMPORARY TABLE extra_issues AS
    SELECT i.id
        FROM gcd_issue i INNER JOIN extra_series es ON i.series_id=es.id;

CREATE TEMPORARY TABLE extra_ind_pubs AS
    SELECT DISTINCT i.indicia_publisher_id as id
        FROM gcd_issue i INNER JOIN extra_issues ei ON i.id=ei.id
            WHERE i.indicia_publisher_id IS NOT NULL;

CREATE TEMPORARY TABLE extra_brands AS
    SELECT DISTINCT i.brand_id AS id
        FROM gcd_issue i INNER JOIN extra_issues ei ON i.id=ei.id
            WHERE i.brand_id IS NOT NULL;

CREATE TEMPORARY TABLE extra_brand_uses AS
    SELECT bu.id FROM gcd_brand_use bu
        INNER JOIN extra_brands eb ON eb.id=bu.emblem_id
        INNER JOIN extra_pubs ep ON ep.id=bu.publisher_id;

CREATE TEMPORARY TABLE extra_brand_groups AS 
    SELECT DISTINCT bg.id from gcd_brand_group bg
        INNER JOIN extra_pubs ep on bg.parent_id=ep.id
        INNER JOIN gcd_brand_emblem_group beg ON beg.brandgroup_id=bg.id
        INNER JOIN extra_brands eb on beg.brand_id=eb.id;

CREATE TEMPORARY TABLE extra_brand_emblem_groups AS
    SELECT beg.id from gcd_brand_emblem_group beg
        INNER JOIN extra_brand_groups ebg ON beg.brandgroup_id=ebg.id
        INNER JOIN extra_brands eb ON beg.brand_id=eb.id;

-- ALL IDS --

CREATE TEMPORARY TABLE pubs AS
    SELECT p.id FROM gcd_publisher p
        WHERE p.id IN (SELECT id FROM initial_pubs)
            OR p.id IN (SELECT id FROM extra_pubs);

CREATE TEMPORARY TABLE brand_groups AS
    SELECT bg.id FROM gcd_brand_group bg
        WHERE bg.parent_id IN (SELECT id FROM initial_pubs)
            OR bg.id IN (SELECT id FROM extra_brand_groups);

CREATE TEMPORARY TABLE brands AS
    SELECT b.id FROM gcd_brand b
        INNER JOIN gcd_brand_use bu ON b.id=bu.emblem_id
        INNER JOIN initial_pubs ip on ip.id=bu.publisher_id;
INSERT INTO brands SELECT id FROM extra_brands;

CREATE TEMPORARY TABLE series AS
    SELECT s.id FROM gcd_series s
        WHERE s.id IN (SELECT id FROM initial_series)
            OR s.id IN (SELECT id FROM extra_series);

CREATE TEMPORARY TABLE issues AS
    SELECT i.id FROM gcd_issue i
        WHERE i.series_id IN (SELECT id FROM series);

CREATE TEMPORARY TABLE stories AS
    SELECT t.id FROM gcd_story t
        WHERE t.issue_id IN (SELECT id FROM issues);

-- We need duplicates for series bonds and reprints
-- Mysql won't allow opening the same table twice in differet subqueries
CREATE TEMPORARY TABLE series2 AS SELECT id FROM series;
CREATE TEMPORARY TABLE issues2 AS SELECT id FROM issues;
CREATE TEMPORARY TABLE stories2 AS SELECT id FROM stories;

-- Output --

SELECT
        p.id,
        p.name,
        p.year_began,
        p.year_ended,
        p.year_began_uncertain,
        p.year_ended_uncertain,
        p.notes,
        p.url,
        p.created,
        p.modified,
        p.deleted,
        p.brand_count,
        p.indicia_publisher_count,
        p.series_count,
        p.issue_count,
        p.country_id
    INTO OUTFILE '/var/lib/mysql-files/publisher.tsv'
    FROM gcd_publisher p WHERE p.id IN (SELECT id FROM pubs);

SELECT
        ip.id,
        ip.name,
        ip.year_began,
        ip.year_ended,
        ip.year_began_uncertain,
        ip.year_ended_uncertain,
        ip.notes,
        ip.url,
        ip.created,
        ip.modified,
        ip.deleted,
        ip.is_surrogate,
        ip.issue_count,
        ip.country_id,
        ip.parent_id
    INTO OUTFILE '/var/lib/mysql-files/indicia-publisher.tsv'
    FROM gcd_indicia_publisher ip
        WHERE ip.parent_id IN (SELECT id FROM initial_pubs)
            OR ip.id IN (SELECT id FROM extra_ind_pubs);

SELECT
        bg.id,
        bg.name,
        bg.year_began,
        bg.year_ended,
        bg.year_began_uncertain,
        bg.year_ended_uncertain,
        bg.notes,
        bg.url,
        bg.created,
        bg.modified,
        bg.deleted,
        bg.issue_count,
        bg.parent_id
    INTO OUTFILE '/var/lib/mysql-files/brand-group.tsv'
    FROM gcd_brand_group bg WHERE bg.id IN (SELECT id FROM brand_groups);

SELECT
        b.id,
        b.name,
        b.year_began,
        b.year_ended,
        b.year_began_uncertain,
        b.year_ended_uncertain,
        b.notes,
        b.url,
        b.created,
        b.modified,
        b.deleted,
        b.issue_count
    INTO OUTFILE '/var/lib/mysql-files/brand.tsv'
    FROM gcd_brand b WHERE b.id IN (SELECT id FROM brands);

SELECT beg.id, beg.brand_id, beg.brandgroup_id
    INTO OUTFILE '/var/lib/mysql-files/brand-emblem-group.tsv'
    FROM gcd_brand_emblem_group beg
        WHERE beg.brandgroup_id IN (SELECT id FROM brand_groups)
            AND beg.brand_id IN (SELECT id FROM brands);

SELECT
        bu.id,
        bu.year_began,
        bu.year_ended,
        bu.year_began_uncertain,
        bu.year_ended_uncertain,
        bu.notes,
        bu.created,
        bu.modified,
        bu.emblem_id,
        bu.publisher_id
    INTO OUTFILE '/var/lib/mysql-files/brand-use.tsv'
    FROM gcd_brand_use bu
        WHERE bu.publisher_id IN (SELECT id FROM pubs)
            AND bu.emblem_id IN (SELECT id FROM brands);

-- Need to exclude forward references to gcd_issue --
SELECT
        s.id,
        s.name,
        s.sort_name,
        s.format,
        s.color,
        s.dimensions,
        s.paper_stock,
        s.binding,
        s.publishing_format,
        s.notes,
        s.year_began,
        s.year_ended,
        s.year_began_uncertain,
        s.year_ended_uncertain,
        s.is_current,
        s.publication_dates,
        s.issue_count,
        s.tracking_notes,
        s.has_barcode,
        s.has_indicia_frequency,
        s.has_isbn,
        s.has_issue_title,
        s.has_volume,
        s.has_rating,
        s.is_comics_publication,
        s.is_singleton,
        s.has_gallery,
        s.created,
        s.modified,
        s.deleted,
        s.country_id,
        -- s.first_issue_id,
        s.language_id,
        -- s.last_issue_id,
        s.publication_type_id,
        s.publisher_id,
        s.has_about_comics
    INTO OUTFILE '/var/lib/mysql-files/series.tsv'
    FROM gcd_series s WHERE s.id IN (SELECT id FROM series);

SELECT
        i.id,
        i.number,
        i.title,
        i.no_title,
        i.volume,
        i.no_volume,
        i.display_volume_with_number,
        i.isbn,
        i.no_isbn,
        i.valid_isbn,
        i.variant_name,
        i.barcode,
        i.no_barcode,
        i.rating,
        i.no_rating,
        i.publication_date,
        i.key_date,
        i.on_sale_date,
        i.on_sale_date_uncertain,
        i.sort_code,
        i.indicia_frequency,
        i.no_indicia_frequency,
        i.price,
        i.page_count,
        i.page_count_uncertain,
        i.editing,
        i.no_editing,
        i.notes,
        i.indicia_pub_not_printed,
        i.no_brand,
        i.is_indexed,
        i.created,
        i.modified,
        i.deleted,
        i.brand_id,
        i.indicia_publisher_id,
        i.series_id,
        i.variant_of_id,
        i.volume_not_printed
    INTO OUTFILE '/var/lib/mysql-files/issue.tsv'
    FROM gcd_issue i WHERE i.id IN (SELECT id FROM issues);

SELECT
        t.id,
        t.title,
        t.title_inferred,
        t.feature,
        t.sequence_number,
        t.page_count,
        t.page_count_uncertain,
        t.script,
        t.pencils,
        t.inks,
        t.colors,
        t.letters,
        t.editing,
        t.no_script,
        t.no_pencils,
        t.no_inks,
        t.no_colors,
        t.no_letters,
        t.no_editing,
        t.job_number,
        t.genre,
        t.characters,
        t.synopsis,
        t.reprint_notes,
        t.notes,
        t.created,
        t.modified,
        t.deleted,
        t.issue_id,
        t.type_id,
        t.first_line
    INTO OUTFILE '/var/lib/mysql-files/story.tsv'
    FROM gcd_story t WHERE t.id IN (SELECT id FROM stories);

SELECT
        sb.id,
        sb.notes,
        sb.reserved,
        sb.bond_type_id,
        sb.origin_id,
        sb.origin_issue_id,
        sb.target_id,
        sb.target_issue_id
    INTO OUTFILE '/var/lib/mysql-files/series-bond.tsv'
    FROM gcd_series_bond sb
        WHERE (origin_id IN (SELECT id FROM series)
               OR origin_issue_id IN (SELECT id FROM issues))
            AND (target_id IN (SELECT id FROM series2)
                 OR target_issue_id IN (SELECT id FROM issues2));

SELECT r.id, r.notes, r.reserved, r.origin_id, r.target_id
     INTO OUTFILE '/var/lib/mysql-files/reprint.tsv'
    FROM gcd_reprint r
        WHERE origin_id IN (SELECT id FROM stories)
            AND target_id IN (SELECT id FROM stories2);

SELECT rti.id, rti.notes, rti.reserved, rti.origin_id, rti.target_issue_id
    INTO OUTFILE '/var/lib/mysql-files/reprint-to-issue.tsv'
    FROM gcd_reprint_to_issue rti
        WHERE origin_id IN (SELECT id FROM stories)
            AND target_issue_id IN (SELECT id FROM issues);

SELECT rfi.id, rfi.notes, rfi.reserved, rfi.origin_issue_id, rfi.target_id
    INTO OUTFILE '/var/lib/mysql-files/reprint-from-issue.tsv'
    FROM gcd_reprint_from_issue rfi
        WHERE origin_issue_id IN (SELECT id FROM issues)
            AND target_id IN (SELECT id FROM stories);

SELECT ir.id, ir.notes, ir.reserved, ir.origin_issue_id, ir.target_issue_id
    INTO OUTFILE '/var/lib/mysql-files/issue-reprint.tsv'
    FROM gcd_issue_reprint ir
        WHERE origin_issue_id IN (SELECT id FROM issues)
            AND target_issue_id IN (SELECT id FROM issues2);
