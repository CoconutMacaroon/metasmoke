json.merge! user.as_json
json.username CGI::unescapeHTML(user.username)
json.merge!(moderator_sites: user.moderator_sites.map { |ms| ms.site.as_json })