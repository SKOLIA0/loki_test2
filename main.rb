require 'mysql2'

client = Mysql2::Client.new(host: 'db09', username: 'loki', password: 'v4WmZip2K67J6Iq7NXC', database: 'applicant_tests')
results = client.query('select id, candidate_office_name from hle_dev_test_nikolaj_slepchenko;')

results.each do |result|
  result_clean = result['candidate_office_name'].gsub(/\\\\|,\\/, '/').gsub('.', '')
  new_result_clean = result_clean.split('/')
  result_clean = ''

  new_result_clean.each.with_index do |piece, index|
    piece = piece.gsub('  ', ' ').strip
    if index == new_result_clean.size - 1 && new_result_clean.size > 1
      piece = "#{piece.strip} "
    elsif piece.index(',')
      pieces = piece.split(',')
      pieces.each.with_index do |piece, index|
        if index.zero?
          piece = " #{piece.downcase!} "
        else
          piece = " #{piece.insert(1, '(').insert(-1, ')')} "
        end
      end
      piece = pieces.join
    else
      piece = piece.downcase
    end

    if index == new_result_clean.size - 1
      result_clean.insert(0, piece)
    elsif index.zero?
      result_clean += " #{piece} "
    else
      result_clean += " and #{piece} "
    end
  end
  result_clean = result_clean.gsub('  ', ' ').strip
  result_clean = result_clean.gsub(/[Vv]illage [Vv]illage/, 'Village')
  result_clean = result_clean.gsub(/[Hh]wy/, 'Highway').gsub(/[Hh]ighway [Hh]ighway/, 'Highway')
  result_clean = result_clean.gsub(/[Cc]ounty [Cc]ounty/, 'County')
  result_clean = result_clean.gsub(/[Cc]ity [Cc]ity/, 'City')
  result_clean = result_clean.gsub(/[Tt]wp/, 'Township').gsub(/[Tt]ownship [Tt]ownship/, 'Township')
  result_clean = result_clean.gsub(/[Pp]ark [Pp]ark/, 'Park')
  result_clean = result_clean.gsub('\'', '\\\\\'')

  sentence_info = "The candidate is running for the #{result_clean} office."

  client.query("Update hle_dev_test_nikolaj_slepchenko set clean_name = '#{result_clean}', sentence = '#{sentence_info}' where id = #{result['id']}")

end
client.close