# ParsePaper
Gem built for SmartLearn. 

#Instalation
To include, just put `gem 'parse_paper', :git => 'https://github.com/hassanalubeidi/ParsePaper.git'` in your Gemfile.
Then run `bundle`

#Usage
Where the variable `pdf` is a link to a test-paper pdf, just call `ParsePaper::parse(pdf)` and a JSON breakdown of the test-paper will be returned, with question structure extracted.
Each question will be categorized using MonkeyLearn (Machine Learning API).


