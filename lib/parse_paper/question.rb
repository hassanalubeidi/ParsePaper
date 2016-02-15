require 'open-uri'
require 'pdf-reader'
module ParsePaper
	class Question_
		attr_accessor :position, :level, :children, :parent, :deepest_nested, :text, :out_of, :topic, :marks_array
		def initialize(options = {})
			@position = options.fetch(:position)
			@level = options.fetch(:level, 1)
			@parent = options.fetch(:parent, nil)
			@children = options.fetch(:children, [])
			@deepest_nested = options.fetch(:deepest_nested, false)
			@text = options.fetch(:text, "")
			@out_of = options.fetch(:out_of, 0)
			@topic = options.fetch(:topic, {})
			@marks_array = options.fetch(:marks_array, [])
		end
		def deepest_nested?
			@children.count == 0
		end
	end
end