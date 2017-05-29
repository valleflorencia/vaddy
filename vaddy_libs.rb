def build_query(query_hash = {})
  query_string = (query_hash||{}).map{|k,v|
    URI.encode(k.to_s) + "=" + URI.encode(v.to_s)
  }.join("&")
  return query_string 
end


def start_scan(request_url, start_query_hash)

  uri = URI.parse( request_url );

  response = Net::HTTP.post_form(uri, start_query_hash)
  result = JSON.parse(response.body)
  
  #puts result
  scan_id = result["scan_id"];
  return scan_id
end


def vaddy_check(request_url) 
  uri = URI.parse( request_url );

  retry_count = 0
  while retry_count < 200 do
    response = Net::HTTP.get(uri)
    result = JSON.parse(response)
    if( result["status"] != "scanning" ) then
      break;
    end
    retry_count = retry_count + 1
    puts "#{result["status"]} ... #{retry_count}"
    sleep(20)
  end

  if( result["alert_count"] == nil || result["alert_count"] > 0 ) then
    puts "----ERROR----"
    puts "Server : #{result["fqdn"]}"
    puts "Status : #{result["status"]}"
    puts "Vulnerabilities: #{result["alert_count"]}"
    puts "Report URL : #{result["scan_result_url"]}"
    #puts result
    return 1;
  else
    puts "SUCCESS. No problem."
    #puts result
    return 0;
  end
  return 1;
end


def search_crawl(request_url, search_keyword, base_info)
  query = base_info
  query["search_label"] = search_keyword

  query_string = build_query(query)
  request_url = request_url + "?" + query_string
  uri = URI.parse( request_url );

  response = Net::HTTP.get(uri)
  result = JSON.parse(response)

  if(result["total"] == 0) then
    return nil
  end

  return result["items"][0]["id"]
end
  


