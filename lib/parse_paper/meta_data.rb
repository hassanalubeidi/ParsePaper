require 'open-uri'
require 'pdf-reader'
require_relative "question.rb"
require 'monkeylearn'
module ParsePaper
	module MetaData
		def self.get_questions(testpaper)
			mainquestions_texts = find_main_questions(testpaper, "\(a\)", "\[Total: [1-99]\]") #cut testpaper into mainquestions. Helps with categorization
			questions = []
			if mainquestions_texts.count > 0 then
				classifications = find_topic(mainquestions_texts)
				puts classifications
				mainquestions_texts.each_with_index do |mainquestion_text, mainquestion_text_index|
					positions = get_positions(mainquestion_text)
					puts "question: #{mainquestion_text_index}"

					mainquestions = create_positions_tree(positions)
					marks_array = get_marks(mainquestion_text)
					puts marks_array.inspect
					marks_array_index = 0
					mainquestions.each do |mq|
						mq.text = mainquestion_text
						mq.topic = classifications[mainquestion_text_index]
						mq.marks_array = marks_array
						questions.push mq
					end

				end
				return questions
			end
		end
		
		#Private ---------------
		def self.find_topic(texts)
			Monkeylearn.configure do |c|
			  c.token = '5b2949dda44cb9a363b29c4ae19115e44fa2b3df'
			end
			r = Monkeylearn.classifiers.classify('cl_e4SMPHsZ', texts, sandbox: true, debug: true)
			return r.result
		end
		def self.create_positions_tree(positions)
			current_first_level_index = -1
			current_second_level_index = -1
			current_third_level_index = -1
			second_level = ["(a)", "(b)", "(c)", "(d)", "(e)", "(f)"] #adding (g) catches (g) state in chemistry questions 
			third_level = ["(i)", "(ii)", "(iii)", "(iv)", "(v)", "(vi)", "(vii)"]
			position_tree = []

			positions.each_with_index do |position, index|
				if second_level? position then
					if first_level? position then
						current_first_level_index += 1
						current_second_level_index = -1
						current_third_level_index = -1
						position_tree.push Question_.new(position: current_first_level_index + 1,
														 level: 1,
														 children: [],
														 out_of: 0)
					end
					
					current_second_level_index += 1
					current_third_level_index = -1
					$last_second_level_position = Question_.new(position: second_level[current_second_level_index],
									 						    parent: position_tree[current_first_level_index],
									 						    level: 2,
									 						    children: [],
									 						    out_of: 0)
					puts "---"
					puts position_tree.count
					puts position.inspect
					puts current_first_level_index
					puts "---"
					position_tree[current_first_level_index].children.push($last_second_level_position)
				elsif third_level? position then
					current_third_level_index += 1
					$last_third_level_position = Question_.new(position: third_level[current_third_level_index],
								 						   	   parent: $last_second_level_position,
								 						       level: 3,
								 						       out_of: 0)
					$last_second_level_position.children.push($last_third_level_position)

				end
			end
			return position_tree
		end

		def self.get_positions(testpaper) 
			testpaper.scan(/\([a-f]\)|\(i\)|\(ii\)|\(iii\)|\(iv\)|\(v\)/).reject(&:empty?)
		end
		def self.get_marks(text)
			return text.scan(/\[\d*\]/).map! {|t| t.scan(/\d*/).join.to_i}
		end
		def self.find_main_questions(text, start_regex, end_regex)
			mainquestions = []
			mainquestion = ""
			start = false
			text.split(/\r?\n|\r/).each do |line| 
				if start == false then
					start = line.scan(/OCR is an exempt Charity/).count > 0
				end
				
				if start then
					if line.scan(/\[Total: .*\d\]/).count > 0 then 
						mainquestions.push mainquestion
						mainquestion = ""
					else
						mainquestion += line
					end
				end
			end
			return mainquestions
		end
		
		def self.first_level?(pos)
			pos == "(a)"
		end
		def self.second_level?(pos)
			pos.scan(/\([a-f]\)/).count > 0
		end
		def self.third_level?(pos)
			pos.scan(/\(i\)|\(ii\)|\(iii\)|\(iv\)|\(v\)/).count > 0
		end
	end

end