class RestaurantOption < PlaceOption

  @search_table    = "restaurants-us"
  @search_category = "Food"

end

# def menu
#   if APP_CONFIG['openmenu']['apikey']
#     crosswalk_resp = Restaurant.om_client.crosswalk(:crosswalk => self.factual_id).parsed_response #look for a cross reference on openmenu
#     if(crosswalk_resp)
#       menu_uuid = crosswalk_resp["response"]["result"].first[1]["openmenu_id"]
#       self.class.om_client.menu(menu_uuid).parsed_response["omf"]["menus"]["menu"]
#     else
#       nil
#     end
#   end
# end
#
# private
#
# def self.om_client
#   @om_client ||= OpenMenu::Client.new(APP_CONFIG['openmenu']['apikey'])
# end
