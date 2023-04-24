# the value of `params` is the value of the hash passed to `script_params`
# in the logstash configuration
def register(params)
	@source_field = params["source"]
	@target_field = params["target"]
	@delimiter = params["delimiter"] != nil ? params["delimiter"] : ","
	@default_version = params["defaultVersion"] != nil ? params["defaultVersion"] : "?"
end

# the filter method receives an event and must return a list of events.
# Dropping an event means not including it in the return array,
# while creating new ones only requires you to add a new instance of
# LogStash::Event to the returned array
def filter(event)

    value = event.get(@source_field)

	if value
		result = {:list => []}
		values = value.split(',', -1).map { |v| v.strip  }
		values.each { |techno|
			v = techno.split(':', -1)
			name = v.at(0).strip 
			result[:list].append(name)
			result[name] = v.size > 1 ? v.at(1).strip : @default_version != nil ? @default_version : nil
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

	expect("languages is an object") do |events|
		events.first.get('languages') != nil && events.first.get('languages').kind_of?(Object)
	end

	expect("languages.list is an array") do |events|
		events.first.get('languages')['list'] && events.first.get('languages')['list'].kind_of?(Object)
	end

	expect("2 languages extracted") do |events|
		events.first.get('languages')['list'].size == 4
	end

	expect("languages are well filled") do |events|
		events.first.get('languages')['list'].include? "JAVA"
		events.first.get("languages")['JAVA'] == "8"

		events.first.get('languages')['list'].include? "JS"
		events.first.get("languages")['JS'] == "6"
		
		events.first.get('languages')['list'].include? "jQuery"
		
		events.first.get('languages')['list'].include? "NodeJS"
		events.first.get("languages")['NodeJS'] == "16"
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

	expect("languages is an object") do |events|
		events.first.get('languages') != nil && events.first.get('languages').kind_of?(Object)
	end

	expect("languages.list is an array") do |events|
		events.first.get('languages')['list'] && events.first.get('languages')['list'].kind_of?(Object)
	end

	expect("2 languages extracted") do |events|
		events.first.get('languages')['list'].size == 1
	end

	expect("languages are well filled") do |events|
		events.first.get('languages')['list'].include? "JAVA"
		events.first.get("languages")['JAVA'] == "8"
	end

end