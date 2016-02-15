require 'open-uri'
require 'rest_client'
require 'json'
module ParsePaper
	class PDF_
		def initialize(url)
			@url = url
		end
		def to_s
			return open(ParsePaper::PDFToTXT::load(@url)).read.to_s.force_encoding("utf-8")
		end
	end
	module PDFToTXT
		def self.load(url)
			open('testpaper.pdf', 'wb') do |file|
			  file << open(url).read
			  load_file = RestClient.post('https://conversiontools.io/api/files', :testpaper_pdf => File.new(file))
			  load_file = JSON.parse(load_file)

			  convert_file = RestClient.post('https://conversiontools.io/api/tasks',
			   :type => "convert.pdf2txt",
			   :file_id => load_file["file_id"]
			   )
			  convert_file = JSON.parse(convert_file)
			  task_id = convert_file["task_id"]

			  return done? task_id
			end
		end
		def self.done?(task_id)
			done = RestClient.get("https://conversiontools.io/api/tasks/#{task_id}")
			done = JSON.parse(done)
			if done["status"] == "SUCCESS" then
				return "https://conversiontools.io/api/files/#{done["file_id"]}"
			else
				sleep 2
				done?(task_id)
			end
		end
	end
end