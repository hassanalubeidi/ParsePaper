require "parse_paper/version"
require_relative "parse_paper/PDF.rb"
require_relative "parse_paper/question.rb"
require_relative "parse_paper/serializer.rb"
require_relative "parse_paper/meta_data.rb"

module ParsePaper
	def self.parse(url)
		load = ParsePaper::PDF_.new(url).to_s
		get_meta_data = ParsePaper::MetaData::get_questions(load)
		serialize = ParsePaper::Serializer.new(get_meta_data).to_json
		return serialize
	end
end
