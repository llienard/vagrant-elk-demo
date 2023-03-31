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
		result = []
		values = value.split(',', -1).map { |v| v.strip  }
		values.each { |techno|
			o = {}
			v = techno.split(':', -1)
			o[:name] = v.at(0).strip 
			if v.size > 1
				o[:version] = v.at(1).strip 
			end
			result.append(o)
	 	}
		event.set(@target_field, result)
	end
	return [event]
end

# To test this script run the following docker command :
# docker run --rm -v $(pwd)/conf/logstash/filters/:/etc/logstash/filters docker.elastic.co/logstash/logstash:8.3.2 logstash -e "filter { ruby { path => '/etc/logstash/filters/list_technos.rb' } } " -t
test "extract multiple languages with versions" do
	parameters do
		{ 
			"source" => "[datas][field]",
			"target" => "[languages]",
		}
	end

	in_event { 
		{ 
			"datas" => {
				"field": "JAVA:8, JS:6, jQuery, NodeJS:16"
			} 
		}
 	}

	expect("1 event sent") do |events|
		events.size == 1
	end

	expect("languages is an array") do |events|
		events.first.get('languages') != nil && events.first.get('languages').kind_of?(Array)
	end

	expect("2 languages extracted") do |events|
		events.first.get("languages").size == 4
	end

	expect("languages are well filled") do |events|
		events.first.get("languages").at(0)['name'] == "JAVA"
		events.first.get("languages").at(0)['version'] == "8"

		events.first.get("languages").at(1)['name'] == "JS"
		events.first.get("languages").at(1)['version'] == "6"

		events.first.get("languages").at(2)['name'] == "jQuery"
		# events.first.get("languages").at(2)['version'] == "6"

		events.first.get("languages").at(3)['name'] == "NodeJS"
		events.first.get("languages").at(3)['version'] == "16"
	end

end

test "extract single language with version" do
	parameters do
		{ 
			"source" => "[datas][field]",
			"target" => "[languages]",
		}
	end

	in_event { 
		{ 
			"datas" => {
				"field": "JAVA:8"
			} 
		}
 	}

	expect("1 event sent") do |events|
		events.size == 1
	end

	expect("languages is an array") do |events|
		events.first.get('languages') != nil && events.first.get('languages').kind_of?(Array)
	end

	expect("1 language extracted") do |events|
		events.first.get("languages").size == 1
	end

	expect("JAVA 8 in languages") do |events|
		events.first.get("languages").at(0)['name'] == "JAVA"
		events.first.get("languages").at(0)['version'] == "8"
	end

end