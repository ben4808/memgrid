# This script takes the data files from the Princeton WordNet project (http://wordnet.princeton.edu/wordnet/download/current-version/)
# and converts it into a big .sql seed file to load the initial definition data when setting up the site. This approach should be more
# durable and not rely on the now-discontinued Google Dictionary API.

# This assumes you have extracted the WordNet 3.1 package (dict directory, no need to compile) into your home directory before running.

data_path = "/home/bzoon/dict/"
data_files = %w(data.adj data.adv data.noun data.verb)

def escape_quotes (str)
  str.gsub("'", "''")
end

# Read in data
defs = {}
data_files.each do |file|
  IO.readlines(data_path + file).each do |line|
    next if line[0] == " "

    definition = line.split(" | ")[1]
    tokens = line.split()
    num_words = tokens[3].to_i
    num_words.times do |i|
      word = tokens[4 + 2*i]
      defs[word] = [] unless defs.has_key? word
      defs[word] << definition unless defs[word].include? definition
    end
  end
end

# Generate output
output = File.open("word_seeds.sql", "w")
output.write("delete from words;\n")
values = []
defs.each do |k, v|
  if values.size >= 100
    output.write("insert into words (word, first_def, definition) values " + values.join(", ") + ";\n")
    values = []
  end

  word = escape_quotes(k)
  short_defs = []
  long_def = "<b>#{word}</b><br><ol>"
  v.each do |d|
    definition = escape_quotes(d)
    short_defs << definition.split(";")[0]
    long_def += "<li>#{definition}"
  end
  long_def += "</ol>"
  values << ("('" + word + "', '" + short_defs.join("|") + "', '" + long_def + "')")
end
output.close()

