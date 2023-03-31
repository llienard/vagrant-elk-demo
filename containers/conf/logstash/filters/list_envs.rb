# the value of `params` is the value of the hash passed to `script_params`
# in the logstash configuration
def register(params)
	@source_field = params["source"]
	@target_field = params["target"]
	@delimiter = params["delimiter"] != nil ? params["delimiter"] : ","

end

# the filter method receives an event and must return a list of events.
# Dropping an event means not including it in the return array,
# while creating new ones only requires you to add a new instance of
# LogStash::Event to the returned array
def filter(event)

    value = event.get(@source_field)

	if value
		logger.info("environments:", value)
		result = []
		values = value.split(@delimiter, -1).map { |v| v.strip  }
		values.each { |environment|
			logger.info("env value splitted:", environment)
			o = {}
			if /^([^(:]*)\s*(?:\(([^)]*)\))?\s*:\s*([^(]*)?\s*(?:\(([^)]*)\))?$/ =~ environment.strip
				o[:name] = "#{$1}".strip
				o[:target] = "#{$2}".strip
				o[:url] = "#{$3}".strip
				o[:details] = "#{$4}".strip
			else
				o[:name] = environment.strip
				event.tag('_listenvs_patternerror')
			end
			
			result.append(o)
	 	}
		event.set(@target_field, result)
	end
	return [event]
end

# To test this script run the following docker command :
# docker run --rm -v $(pwd)/conf/logstash/filters/:/etc/logstash/filters docker.elastic.co/logstash/logstash:8.3.2 logstash -e "filter { ruby { path => '/etc/logstash/filters/list_envs.rb' } } " -t
test "extract multiple envs with datas" do
	parameters do
		{ 
			"source" => "[datas][field]",
			"target" => "[envs]",
			"delimiter" => "\n"
		}
	end

	in_event { 
		{ 
			"datas" => {
				"field": "PROD (Client) : \nMAINTENANCE (Client) : \nREC  (Client) : https://myportal-int.heppner-group.com (GCP)\nINT (Qomity) : (VM)"
			} 
		}
 	}

	expect("1 event sent") do |events|
		events.size == 1
	end

	expect("events is an array") do |events|
		events.first.get('envs') != nil && events.first.get('envs').kind_of?(Array)
	end

	expect("4 events extracted") do |events|
		events.first.get("envs").size == 4
	end

	expect("events are well filled") do |events|
		events.first.get("envs").at(0)['name'] == "PROD"
		events.first.get("envs").at(0)['target'] == "Client"

		events.first.get("envs").at(1)['name'] == "MAINTENANCE"
		events.first.get("envs").at(1)['target'] == "Client"

		events.first.get("envs").at(2)['name'] == "REC"
		events.first.get("envs").at(2)['target'] == "Client"
		events.first.get("envs").at(2)['url'] == "https://myportal-int.heppner-group.com"
		events.first.get("envs").at(2)['details'] == "GCP"

		events.first.get("envs").at(3)['name'] == "INT"
		events.first.get("envs").at(3)['target'] == "Qomity"
		events.first.get("envs").at(3)['details'] == "VM"
	end

end

test "extract single event with version" do
	parameters do
		{ 
			"source" => "[datas][field]",
			"target" => "[envs]",
			"delimiter" => "\n"
		}
	end

	in_event { 
		{ 
			"datas" => {
				"field": "PROD (Client) : https://monsite.com"
			} 
		}
 	}

	expect("1 event sent") do |events|
		events.size == 1
	end

	expect("envs is an array") do |events|
		events.first.get('envs') != nil && events.first.get('envs').kind_of?(Array)
	end

	expect("1 env extracted") do |events|
		events.first.get("envs").size == 1
	end

	expect("environement is well filled") do |events|
		events.first.get("envs").at(0)['type'] == "PROD"
		events.first.get("envs").at(0)['target'] == "Client"
		events.first.get("envs").at(0)['url'] == "https://monsite.com"
	end

end

test "PROD (Client): {EOL}MAINTENANCE (Client) : {EOL}REC  (Client:) : {EOL}INT (Qomity) : (VM)" do
	parameters do
		{ 
			"source" => "[datas][field]",
			"target" => "[envs]",
			"delimiter" => "{EOL}"
		}
	end

	in_event { 
		{ 
			"datas" => {
				"field": "PROD (Client): {EOL}MAINTENANCE (Client) : {EOL}REC  (Client:) : {EOL}INT (Qomity) : (VM)"
			} 
		}
 	}

	expect("1 event sent") do |events|
		events.size == 1
	end

	expect("envs is an array") do |events|
		events.first.get('envs') != nil && events.first.get('envs').kind_of?(Array)
	end

	expect("1 env extracted") do |events|
		events.first.get("envs").size == 4
	end

	expect("environement is well filled") do |events|
		events.first.get("envs").at(0)['type'] == "PROD"
		events.first.get("envs").at(0)['target'] == "Client"

		events.first.get("envs").at(1)['type'] == "MAINTENANCE"
		events.first.get("envs").at(1)['target'] == "Client"

		events.first.get("envs").at(2)['type'] == "REC"
		events.first.get("envs").at(2)['target'] == "Client"

		events.first.get("envs").at(3)['type'] == "INT"
		events.first.get("envs").at(3)['target'] == "Qomity"
		events.first.get("envs").at(3)['details'] == "VM"
	end

end