CREATE OR REPLACE FUNCTION orthodrome_km(lat1 numeric, lon1 numeric, lat2 numeric, lon2 numeric)
RETURNS double precision
LANGUAGE plpgsql
AS $function$
--Orthodrome ("great circle") distance between two latitude/longitude points. This function uses the spherical law of cosines formula, rather than the seemingly more popular (probably because it's older) "haversine" formula. It is assumed the earth is a perfect sphere with a radius of 6,371km.
BEGIN
    return acos(sin(radians(lat1))*sin(radians(lat2))+cos(radians(lat1))*cos(radians(lat2))*cos(radians(lon2)-radians(lon1)))*6371;
END;
$function$