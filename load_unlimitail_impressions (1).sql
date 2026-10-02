-- PostgreSQL transformation procedure: raw Unlimitail/TTD-style feed -> canonical schema
CREATE OR REPLACE PROCEDURE core.load_unlimitail_impressions(p_load_batch_id bigint)
LANGUAGE plpgsql AS $$
BEGIN
  UPDATE ops.load_batch SET started_at=now(), status='PROCESSING' WHERE load_batch_id=p_load_batch_id;

  INSERT INTO ops.rejected_record(load_batch_id, source_row_number, source_event_id, rejection_code, rejection_detail)
  SELECT load_batch_id, source_row_number, impressionid, 'MISSING_REQUIRED_FIELD',
         concat_ws('; ', CASE WHEN nullif(impressionid,'') IS NULL THEN 'IMPRESSIONID' END,
                          CASE WHEN nullif(logentrytime,'') IS NULL THEN 'LOGENTRYTIME' END,
                          CASE WHEN nullif(campaignid,'') IS NULL THEN 'CAMPAIGNID' END)
  FROM raw.unlimitail_impression
  WHERE load_batch_id=p_load_batch_id
    AND (nullif(impressionid,'') IS NULL OR nullif(logentrytime,'') IS NULL OR nullif(campaignid,'') IS NULL);

  INSERT INTO core.dim_advertiser(source_system, advertiser_id, advertiser_name)
  SELECT DISTINCT 'UNLIMITAIL', advertiserid, nullif(advertisername,'')
  FROM raw.unlimitail_impression
  WHERE load_batch_id=p_load_batch_id AND nullif(advertiserid,'') IS NOT NULL
  ON CONFLICT(source_system, advertiser_id) DO UPDATE SET advertiser_name=EXCLUDED.advertiser_name;

  INSERT INTO core.dim_campaign(source_system, campaign_id, advertiser_key, campaign_name)
  SELECT DISTINCT 'UNLIMITAIL', r.campaignid, a.advertiser_key, nullif(r.campaignname,'')
  FROM raw.unlimitail_impression r JOIN core.dim_advertiser a
    ON a.source_system='UNLIMITAIL' AND a.advertiser_id=r.advertiserid
  WHERE r.load_batch_id=p_load_batch_id AND nullif(r.campaignid,'') IS NOT NULL
  ON CONFLICT(source_system, campaign_id) DO UPDATE SET campaign_name=EXCLUDED.campaign_name, advertiser_key=EXCLUDED.advertiser_key;

  INSERT INTO core.dim_line_item(source_system, line_item_id, campaign_key, line_item_name)
  SELECT DISTINCT 'UNLIMITAIL', r.adgroupid, c.campaign_key, nullif(r.adgroupname,'')
  FROM raw.unlimitail_impression r JOIN core.dim_campaign c
    ON c.source_system='UNLIMITAIL' AND c.campaign_id=r.campaignid
  WHERE r.load_batch_id=p_load_batch_id AND nullif(r.adgroupid,'') IS NOT NULL
  ON CONFLICT(source_system, line_item_id) DO UPDATE SET line_item_name=EXCLUDED.line_item_name, campaign_key=EXCLUDED.campaign_key;

  INSERT INTO core.dim_creative(source_system, creative_id, creative_name, ad_format, width_px, height_px, media_type)
  SELECT DISTINCT 'UNLIMITAIL', creativeid, nullif(creativename,''), nullif(adformat,''),
    CASE WHEN adformat ~ '^[0-9]+x[0-9]+$' THEN split_part(adformat,'x',1)::int END,
    CASE WHEN adformat ~ '^[0-9]+x[0-9]+$' THEN split_part(adformat,'x',2)::int END,
    CASE WHEN lower(coalesce(inventorychannelname,'')) LIKE '%video%' THEN 'VIDEO' ELSE 'DISPLAY' END
  FROM raw.unlimitail_impression WHERE load_batch_id=p_load_batch_id AND nullif(creativeid,'') IS NOT NULL
  ON CONFLICT(source_system, creative_id) DO UPDATE SET creative_name=EXCLUDED.creative_name, ad_format=EXCLUDED.ad_format,
    width_px=EXCLUDED.width_px, height_px=EXCLUDED.height_px, media_type=EXCLUDED.media_type;

  INSERT INTO core.dim_audience(source_system, audience_id)
  SELECT DISTINCT 'UNLIMITAIL', audienceid FROM raw.unlimitail_impression
  WHERE load_batch_id=p_load_batch_id AND nullif(audienceid,'') IS NOT NULL
  ON CONFLICT DO NOTHING;

  INSERT INTO core.dim_publisher(domain)
  SELECT DISTINCT lower(regexp_replace(site, '^https?://(www\\.)?', ''))
  FROM raw.unlimitail_impression WHERE load_batch_id=p_load_batch_id AND nullif(site,'') IS NOT NULL
  ON CONFLICT DO NOTHING;

  INSERT INTO core.dim_supply_partner(source_system, supply_partner_name)
  SELECT DISTINCT 'UNLIMITAIL', coalesce(nullif(supplyvendorname,''), nullif(supplyvendor,''))
  FROM raw.unlimitail_impression WHERE load_batch_id=p_load_batch_id AND coalesce(nullif(supplyvendorname,''),nullif(supplyvendor,'')) IS NOT NULL
  ON CONFLICT DO NOTHING;

  INSERT INTO core.dim_placement(source_system, placement_natural_key, placement_id, publisher_key,
    supply_partner_key, supply_vendor_publisher_id, inventory_channel, rendering_context, native_placement_type_id)
  SELECT DISTINCT 'UNLIMITAIL', md5(concat_ws('|',coalesce(r.impressionplacementid,''),coalesce(r.site,''),
      coalesce(r.supplyvendorpublisherid,''),coalesce(r.inventorychannelname,''))), nullif(r.impressionplacementid,''),
      p.publisher_key, s.supply_partner_key, nullif(r.supplyvendorpublisherid,''), nullif(r.inventorychannelname,''),
      nullif(r.renderingcontext,''), nullif(r.nativeplacementtypeid,'')
  FROM raw.unlimitail_impression r
  LEFT JOIN core.dim_publisher p ON p.domain=lower(regexp_replace(r.site, '^https?://(www\\.)?', ''))
  LEFT JOIN core.dim_supply_partner s ON s.source_system='UNLIMITAIL' AND s.supply_partner_name=coalesce(nullif(r.supplyvendorname,''),nullif(r.supplyvendor,''))
  WHERE r.load_batch_id=p_load_batch_id
  ON CONFLICT(source_system, placement_natural_key) DO NOTHING;

  INSERT INTO core.dim_device(device_natural_key, device_type_code, device_type_name, os_family_code, os_family_name,
    os_code, os_name, browser_code, browser_name, device_make, device_model, carrier)
  SELECT DISTINCT md5(concat_ws('|',devicetype,devicetypename,osfamily,osfamilyname,os,osname,browser,browsername,devicemake,devicemodel,carrier)),
    nullif(devicetype,''),nullif(devicetypename,''),nullif(osfamily,''),nullif(osfamilyname,''),nullif(os,''),nullif(osname,''),
    nullif(browser,''),nullif(browsername,''),nullif(devicemake,''),nullif(devicemodel,''),nullif(carrier,'')
  FROM raw.unlimitail_impression WHERE load_batch_id=p_load_batch_id ON CONFLICT DO NOTHING;

  INSERT INTO core.dim_geography(geography_natural_key,country_name,region_name,metro_name,city_name,postal_code,latitude,longitude)
  SELECT DISTINCT md5(concat_ws('|',countrylong,region,metro,city,zip,latitude,longitude)), nullif(countrylong,''),nullif(region,''),
    nullif(metro,''),nullif(city,''),nullif(zip,''), CASE WHEN latitude ~ '^-?[0-9]+(\\.[0-9]+)?$' THEN latitude::numeric END,
    CASE WHEN longitude ~ '^-?[0-9]+(\\.[0-9]+)?$' THEN longitude::numeric END
  FROM raw.unlimitail_impression WHERE load_batch_id=p_load_batch_id ON CONFLICT DO NOTHING;

  INSERT INTO core.fact_exposure(source_system,source_event_id,load_batch_id,exposure_ts,processed_ts,advertiser_key,campaign_key,
    line_item_key,creative_key,audience_key,placement_key,device_key,geography_key,served_impressions,media_cost_usd,
    feature_cost_usd,data_cost_usd,total_cost_usd,advertiser_currency,usd_to_advertiser_rate,total_cost_advertiser_currency,
    auction_type,deal_id,private_contract_id,ads_txt_seller_type,user_hour_of_week,temperature_c,referrer_categories,
    combined_identifier_type,identity_available,record_hash)
  SELECT 'UNLIMITAIL',r.impressionid,p_load_batch_id,r.logentrytime::timestamptz,nullif(r.processedtime,'')::timestamptz,
    a.advertiser_key,c.campaign_key,li.line_item_key,cr.creative_key,au.audience_key,pl.placement_key,d.device_key,g.geography_key,
    coalesce(nullif(r.audienceimpressionmultiplier,'')::numeric,1),nullif(r.mediacostinbucks,'')::numeric,
    nullif(r.feefeaturescost,'')::numeric,nullif(r.datausagetotalcost,'')::numeric,
    coalesce(nullif(r.mediacostinbucks,'')::numeric,0)+coalesce(nullif(r.feefeaturescost,'')::numeric,0)+coalesce(nullif(r.datausagetotalcost,'')::numeric,0),
    nullif(r.advertisercurrency,''),nullif(r.advertisercurrencyexchangeratefromusd,'')::numeric,
    (coalesce(nullif(r.mediacostinbucks,'')::numeric,0)+coalesce(nullif(r.feefeaturescost,'')::numeric,0)+coalesce(nullif(r.datausagetotalcost,'')::numeric,0))
       * nullif(r.advertisercurrencyexchangeratefromusd,'')::numeric,
    nullif(r.auctiontype,''),nullif(r.dealid,''),nullif(r.privatecontractid,''),nullif(r.adstxtsellertype,''),
    nullif(r.userhourofweek,'')::smallint,nullif(r.temperatureincelsius,'')::numeric,nullif(r.referrercategories,''),
    nullif(r.combinedidentifiertype,''), nullif(r.individual_id,'') IS NOT NULL,
    encode(digest(concat_ws('|',r.impressionid,r.logentrytime,r.campaignid,r.creativeid,r.site),'sha256'),'hex')
  FROM raw.unlimitail_impression r
  JOIN core.dim_advertiser a ON a.source_system='UNLIMITAIL' AND a.advertiser_id=r.advertiserid
  JOIN core.dim_campaign c ON c.source_system='UNLIMITAIL' AND c.campaign_id=r.campaignid
  LEFT JOIN core.dim_line_item li ON li.source_system='UNLIMITAIL' AND li.line_item_id=r.adgroupid
  LEFT JOIN core.dim_creative cr ON cr.source_system='UNLIMITAIL' AND cr.creative_id=r.creativeid
  LEFT JOIN core.dim_audience au ON au.source_system='UNLIMITAIL' AND au.audience_id=r.audienceid
  LEFT JOIN core.dim_placement pl ON pl.source_system='UNLIMITAIL' AND pl.placement_natural_key=md5(concat_ws('|',coalesce(r.impressionplacementid,''),coalesce(r.site,''),coalesce(r.supplyvendorpublisherid,''),coalesce(r.inventorychannelname,'')))
  LEFT JOIN core.dim_device d ON d.device_natural_key=md5(concat_ws('|',r.devicetype,r.devicetypename,r.osfamily,r.osfamilyname,r.os,r.osname,r.browser,r.browsername,r.devicemake,r.devicemodel,r.carrier))
  LEFT JOIN core.dim_geography g ON g.geography_natural_key=md5(concat_ws('|',r.countrylong,r.region,r.metro,r.city,r.zip,r.latitude,r.longitude))
  WHERE r.load_batch_id=p_load_batch_id AND nullif(r.impressionid,'') IS NOT NULL AND nullif(r.logentrytime,'') IS NOT NULL
  ON CONFLICT(source_system,source_event_id) DO NOTHING;

  INSERT INTO secure.bridge_exposure_identity(exposure_key,identity_type,identity_token,identity_hash,match_status)
  SELECT f.exposure_key, nullif(r.combinedidentifiertype,''), nullif(r.individual_id,''),
         CASE WHEN nullif(r.individual_id,'') IS NOT NULL THEN encode(digest(r.individual_id,'sha256'),'hex') END,
         CASE WHEN nullif(r.individual_id,'') IS NULL THEN 'UNAVAILABLE' ELSE 'PROVIDED' END
  FROM raw.unlimitail_impression r JOIN core.fact_exposure f
    ON f.source_system='UNLIMITAIL' AND f.source_event_id=r.impressionid
  WHERE r.load_batch_id=p_load_batch_id AND nullif(r.individual_id,'') IS NOT NULL
  ON CONFLICT(exposure_key) DO NOTHING;

  UPDATE ops.load_batch b SET completed_at=now(), status='COMPLETED',
    raw_row_count=(SELECT count(*) FROM raw.unlimitail_impression WHERE load_batch_id=p_load_batch_id),
    accepted_row_count=(SELECT count(*) FROM core.fact_exposure WHERE load_batch_id=p_load_batch_id),
    rejected_row_count=(SELECT count(*) FROM ops.rejected_record WHERE load_batch_id=p_load_batch_id)
  WHERE b.load_batch_id=p_load_batch_id;
EXCEPTION WHEN OTHERS THEN
  UPDATE ops.load_batch SET completed_at=now(),status='FAILED',error_message=SQLERRM WHERE load_batch_id=p_load_batch_id;
  RAISE;
END $$;
