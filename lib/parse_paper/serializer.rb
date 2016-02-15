module ParsePaper
	class Serializer
		require 'json'

		def initialize(questions)
			@questions = questions
		end

		def to_json
			mainquestions_hashes(@questions).to_json
		end

		private
		def mainquestions_hashes(questions_array)
			output = Hash.new
			output[:mainquestions] = []
			questions = []
			questions_array.each do |question|
				if question.level == 1 then #is a mainquestion
					mainquestion_output = Hash.new
					mainquestion_output[:questions] = questions_hashes(question.children, question.marks_array)
					mainquestion_output[:objectives] = [question.topic]
					mainquestion_output[:html] = "question.text"
					output[:mainquestions].push mainquestion_output
				end
			end
			return output
		end
		def questions_hashes(questions, marks_array, marks_array_index = 0)
			output = []
			questions.each do |question|
				if question.deepest_nested? 
					position = "#{question.parent.position}#{question.position}"
					last_question = true
					output_question = Hash.new 
					output_question[:position] = position
					output_question[:html] = ""
					output_question[:total_marks] = marks_array[marks_array_index]
					output.push output_question
					marks_array_index += 1
				else
					output.push(*questions_hashes(question.children, marks_array, marks_array_index))
					marks_array_index += questions_hashes(question.children, marks_array, marks_array_index).count
				end
			end

			return output
		end
	end
end