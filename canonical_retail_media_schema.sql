-- PostgreSQL 15+ canonical retail-media exposure schema
-- Design intent: vendor-neutral analytical model aligned to IAB/MRC measurement concepts.
CREATE SCHEMA IF NOT EXISTS ops;
CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS core;
CREATE SCHEMA IF NOT EXISTS secure;

CREATE TABLE IF NOT EXISTS ops.load_batch (
  load_batch_id       bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  source_system       varchar(50) NOT NULL,
  source_file         text NOT NULL,
  file_checksum       varchar(128),
  received_at         timestamptz NOT NULL DEFAULT now(),
  started_at          timestamptz,
  completed_at        timestamptz,
  raw_row_count       bigint,
  accepted_row_count  bigint,
  rejected_row_count  bigint,
  status              varchar(20) NOT NULL DEFAULT 'RECEIVED',
  error_message       text,
  UNIQUE(source_system, source_file, file_checksum)
);

-- The temporary/landing table may be physical or external. Values are text to preserve source fidelity.
CREATE UNLOGGED TABLE IF NOT EXISTS raw.unlimitail_impression (
  load_batch_id bigint NOT NULL REFERENCES ops.load_batch(load_batch_id),
  source_row_number bigint,
  source_file text,
  individual_id text, logentrytime text, impressionid text, partnerid text,
  advertiserid text, campaignid text, adgroupid text, privatecontractid text,
  audienceid text, creativeid text, adformat text, supplyvendor text,
  supplyvendorpublisherid text, dealid text, site text, referrercategories text,
  userhourofweek text, ipaddress text, countrylong text, region text, metro text,
  city text, devicetype text, osfamily text, os text, browser text, recency text,
  matchedlanguagecode text, mediacostinbucks text, feefeaturescost text,
  datausagetotalcost text, latitude text, longitude text, zip text,
  processedtime text, devicemake text, devicemodel text, renderingcontext text,
  carrier text, temperatureincelsius text, temperaturebucketstartincelsius text,
  temperaturebucketendincelsius text, advertisercurrency text,
  advertisercurrencyexchangeratefromusd text, impressionplacementid text,
  adstxtsellertype text, auctiontype text, supplyvendorname text,
  combinedidentifiertype text, volumecontrolpriority text,
  nativeplacementtypeid text, combinedidentifierform text,
  ttdnativecontexttypeid text, matchedgenre text, contentduration text,
  devicetypename text, osfamilyname text, osname text, browsername text,
  audienceimpressionmultiplier text, livestream text, supplytype text,
  advertisername text, campaignname text, adgroupname text, creativename text,
  contentproductionquality text, matchedcontentrating text, contentgenre1 text,
  contentgenre2 text, contentgenre3 text, contentgenre4 text, contentgenre5 text,
  streamingmedianetwork text, streamingmediachannel text,
  digitaloutofhomevenuetypeid text, digitaloutofhomevenuetypename text,
  digitaloutofhomescreenname text, inventorychannel text, inventorychannelname text,
  ingested_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY(load_batch_id, source_row_number)
);

CREATE TABLE IF NOT EXISTS core.dim_advertiser (
  advertiser_key bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  source_system varchar(50) NOT NULL,
  advertiser_id varchar(200) NOT NULL,
  advertiser_name text,
  valid_from timestamptz NOT NULL DEFAULT now(), valid_to timestamptz,
  is_current boolean NOT NULL DEFAULT true,
  UNIQUE(source_system, advertiser_id)
);
CREATE TABLE IF NOT EXISTS core.dim_campaign (
  campaign_key bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  source_system varchar(50) NOT NULL,
  campaign_id varchar(200) NOT NULL,
  advertiser_key bigint NOT NULL REFERENCES core.dim_advertiser,
  campaign_name text,
  campaign_start_date date, campaign_end_date date,
  objective varchar(100), channel_scope varchar(50),
  UNIQUE(source_system, campaign_id)
);
CREATE TABLE IF NOT EXISTS core.dim_line_item (
  line_item_key bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  source_system varchar(50) NOT NULL,
  line_item_id varchar(200) NOT NULL,
  campaign_key bigint NOT NULL REFERENCES core.dim_campaign,
  line_item_name text,
  UNIQUE(source_system, line_item_id)
);
CREATE TABLE IF NOT EXISTS core.dim_creative (
  creative_key bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  source_system varchar(50) NOT NULL,
  creative_id varchar(200) NOT NULL,
  creative_name text, ad_format varchar(100), width_px integer, height_px integer,
  media_type varchar(50),
  UNIQUE(source_system, creative_id)
);
CREATE TABLE IF NOT EXISTS core.dim_audience (
  audience_key bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  source_system varchar(50) NOT NULL,
  audience_id varchar(200) NOT NULL,
  audience_name text, audience_provider text, audience_type varchar(100),
  UNIQUE(source_system, audience_id)
);
CREATE TABLE IF NOT EXISTS core.dim_publisher (
  publisher_key bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  domain text NOT NULL, publisher_name text,
  UNIQUE(domain)
);
CREATE TABLE IF NOT EXISTS core.dim_supply_partner (
  supply_partner_key bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  source_system varchar(50) NOT NULL,
  supply_partner_name text NOT NULL,
  UNIQUE(source_system, supply_partner_name)
);
CREATE TABLE IF NOT EXISTS core.dim_placement (
  placement_key bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  source_system varchar(50) NOT NULL,
  placement_natural_key text NOT NULL,
  placement_id text, publisher_key bigint REFERENCES core.dim_publisher,
  supply_partner_key bigint REFERENCES core.dim_supply_partner,
  supply_vendor_publisher_id text, inventory_channel varchar(100),
  rendering_context varchar(100), native_placement_type_id varchar(100),
  UNIQUE(source_system, placement_natural_key)
);
CREATE TABLE IF NOT EXISTS core.dim_device (
  device_key bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  device_natural_key varchar(64) NOT NULL UNIQUE,
  device_type_code varchar(50), device_type_name varchar(100),
  os_family_code varchar(50), os_family_name varchar(100),
  os_code varchar(50), os_name varchar(100), browser_code varchar(50),
  browser_name varchar(100), device_make varchar(200), device_model varchar(300),
  carrier varchar(200)
);
CREATE TABLE IF NOT EXISTS core.dim_geography (
  geography_key bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  geography_natural_key varchar(64) NOT NULL UNIQUE,
  country_name varchar(100), region_name varchar(200), metro_name varchar(200),
  city_name varchar(200), postal_code varchar(50), latitude numeric(9,6), longitude numeric(9,6)
);
CREATE TABLE IF NOT EXISTS core.fact_exposure (
  exposure_key bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  source_system varchar(50) NOT NULL,
  source_event_id varchar(200) NOT NULL,
  load_batch_id bigint NOT NULL REFERENCES ops.load_batch,
  exposure_ts timestamptz NOT NULL, processed_ts timestamptz,
  advertiser_key bigint NOT NULL REFERENCES core.dim_advertiser,
  campaign_key bigint NOT NULL REFERENCES core.dim_campaign,
  line_item_key bigint REFERENCES core.dim_line_item,
  creative_key bigint REFERENCES core.dim_creative,
  audience_key bigint REFERENCES core.dim_audience,
  placement_key bigint REFERENCES core.dim_placement,
  device_key bigint REFERENCES core.dim_device,
  geography_key bigint REFERENCES core.dim_geography,
  exposure_type varchar(30) NOT NULL DEFAULT 'IMPRESSION',
  served_impressions numeric(18,6) NOT NULL DEFAULT 1,
  viewable_impressions numeric(18,6), measurable_impressions numeric(18,6),
  invalid_traffic_impressions numeric(18,6),
  media_cost_usd numeric(20,10), feature_cost_usd numeric(20,10),
  data_cost_usd numeric(20,10), total_cost_usd numeric(20,10),
  advertiser_currency char(3), usd_to_advertiser_rate numeric(20,10),
  total_cost_advertiser_currency numeric(20,10),
  auction_type varchar(50), deal_id text, private_contract_id text,
  ads_txt_seller_type varchar(20), user_hour_of_week smallint,
  temperature_c numeric(8,3), referrer_categories text,
  combined_identifier_type varchar(100), identity_available boolean NOT NULL DEFAULT false,
  record_hash varchar(64) NOT NULL,
  UNIQUE(source_system, source_event_id),
  CHECK (served_impressions >= 0), CHECK (user_hour_of_week BETWEEN 0 AND 167 OR user_hour_of_week IS NULL)
);
CREATE INDEX IF NOT EXISTS ix_exposure_campaign_ts ON core.fact_exposure(campaign_key, exposure_ts);
CREATE INDEX IF NOT EXISTS ix_exposure_batch ON core.fact_exposure(load_batch_id);
CREATE INDEX IF NOT EXISTS ix_exposure_identity_avail ON core.fact_exposure(identity_available) WHERE identity_available;

-- Keep direct identifiers out of the analytical fact and apply restricted access.
CREATE TABLE IF NOT EXISTS secure.bridge_exposure_identity (
  exposure_key bigint PRIMARY KEY REFERENCES core.fact_exposure ON DELETE CASCADE,
  identity_type varchar(100), identity_token text,
  identity_hash varchar(128), match_status varchar(50),
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS ops.rejected_record (
  load_batch_id bigint NOT NULL REFERENCES ops.load_batch,
  source_row_number bigint, source_event_id text,
  rejection_code varchar(100) NOT NULL, rejection_detail text,
  rejected_at timestamptz NOT NULL DEFAULT now()
);
