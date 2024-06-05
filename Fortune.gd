extends Node



# Generates and returns a random fortune from file

var path = "res://DialogPieces/"
var template_path = path+"DialogTemplate.txt"

var punctuation = [".", ":", ",", ";"]
var all_words = {}
var wordtypes = ["NOUN","PRESENTTENSEVERB","PROGRESSIVETENSEVERB","PASTTENSEVERB","PROPERNOUN","ADJECTIVE", "ADVERB"]


# Read each line in template_file, save return as 2D array
func load_template():
	var template_file = FileAccess.open(template_path, FileAccess.READ)
	var return_values = []
	while template_file.get_position() < template_file.get_length():
		# Read data
		var line = template_file.get_line().split(" ")
		return_values.append(line)
	return return_values
	
# Populate all_words dict with words of given type
func load_word(type):
	all_words[type] = []
	var word_file = FileAccess.open(path+type+".txt", FileAccess.READ)
	while word_file.get_position() < word_file.get_length():
		all_words[type].append(word_file.get_line())
	all_words[type].shuffle()

# Return one word of given type
func get_word(type):
	if type=="PROPERNOUN":
		return all_words[type].pop_front().strip_edges().capitalize()
	return all_words[type].pop_front().strip_edges().to_lower()

 # Fill empty spaces in template lines with words: line: array of strings
func fill_line(line):
	var alpha_regex = RegEx.new()
	alpha_regex.compile("[A-Z]")
	var vowel_regex = RegEx.new()
	vowel_regex.compile("[AEIOUaeiou]")
	
	var new_line = []
	new_line.resize(line.size())
	new_line.fill("")

	var w=0

	while w<line.size():
		# Skip a blank entry
		if line[w]=="":
			w += 1
			continue
		# Strip punctuation
		var punc = ""
		if line[w][-1] in punctuation:
			punc = line[w][-1]
		var stripped_word = line[w].rstrip(punc)
		# Remove placeholder words
		var wordmatch = alpha_regex.search(stripped_word)
		if wordmatch:
			if wordmatch.subject in wordtypes:
				new_line.insert(w, get_word(wordmatch.subject))
				new_line[w] += punc
				w += 1
				continue
		# Add Template words
		new_line.insert(w, line[w].to_lower())
		new_line[w] += punc
		w += 1

	# Create and return string line
	while "" in new_line:
		new_line.erase("")
	var string_line = ""
	var first_word = true
	for i in range(new_line.size()):
		var word = new_line[i]
		if first_word:
			word = word.capitalize()
			first_word = false
		if word.length()>2:
			if (word[-1]==word[-2] and word[-1] in punctuation):
				var new_size = word.length()-1
				word = word.left(new_size)
		if ((word=="a") or (word=="an")) and w<len(new_line)-1:
			var first_letter =new_line[i+1].strip(punctuation)[0]
			if vowel_regex.search_all(first_letter):
				word = "an"
			else: word = "a"
		string_line += (word+" ")

	return string_line


# Create New randomized fortune from template: 2 Paragraphs with 4 lines each
func create_fortune(): 
	var fortune = ""
	# Load Full Template
	for type in wordtypes:
		load_word(type)
	var all_sentences = load_template()
	# Categorize lines as tween or end
	var betweens = []
	var ends = []
	for sentence in all_sentences:
		if sentence[-1].strip_edges().ends_with("."):
			ends.append(sentence)
		else:
			betweens.append(sentence)

	# 2 Paragraphs
	betweens.shuffle()
	ends.shuffle()
	for p in range(2):
		var paragraph = ""
		# Get Three random betweens and 1 end
		for i in range(3):
			paragraph += str(fill_line(betweens.pop_front()))+"\n"
		paragraph += str(fill_line(ends.pop_front()))+"\n"
		fortune += paragraph + "\n"

	return fortune
