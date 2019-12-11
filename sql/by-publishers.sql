CREATE TEMPORARY TABLE pubs AS
    SELECT id FROM gcd_publisher
        WHERE id IN (58, 74, 92, 112, 129, 7618, 7628, 7631);

CREATE TEMPORARY TABLE brand_groups AS
    SELECT bg.id FROM gcd_brand_group bg
        WHERE bg.parent_id IN (SELECT id FROM pubs) OR bg.id=2450;

CREATE TEMPORARY TABLE brands AS
    SELECT b.id FROM gcd_brand b
        INNER JOIN gcd_brand_use bu ON b.id=bu.emblem_id
        INNER JOIN gcd_publisher p on p.id=bu.publisher_id
            WHERE bu.publisher_id IN (SELECT id FROM pubs)
                OR b.id IN (771, 4367);

CREATE TEMPORARY TABLE series AS
    SELECT s.id FROM gcd_series s
        WHERE s.publisher_id IN (SELECT id FROM pubs)
            OR s.id IN (134, 176, 232, 233, 293, 321, 322);

CREATE TEMPORARY TABLE issues AS
    SELECT i.id FROM gcd_issue i WHERE i.series_id IN (SELECT id FROM series);

CREATE TEMPORARY TABLE stories AS
    SELECT t.id FROM gcd_story t WHERE t.issue_id IN (SELECT id FROM issues);

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
    FROM gcd_publisher p WHERE p.id IN (SELECT id FROM pubs) OR id=76;

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
        WHERE ip.parent_id IN (SELECT id FROM pubs)
            OR ip.id IN (29, 351, 352, 435, 436, 437, 639);

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
        WHERE (bu.publisher_id IN (SELECT id FROM pubs) OR id=76)
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
