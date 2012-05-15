require 'yaml'
require 'active_support'


def compare_yaml_hash(cf1, cf2, context = [])
  cf1.each do |key, value|
    unless cf2.key?(key)
      unless value.is_a?(Hash)
        puts context.join(' -> ') + ' -> ' + key + ': ' + value
      end
      next
    end

    if value.is_a?(Hash)
      compare_yaml_hash(value, cf2[key], (context << key))  
      next
    end
  end
  context.pop
end

def returning(value)
  yield(value)
  value
end

def convert_hash_to_ordered_hash_and_sort(object, deep = false)
# from http://seb.box.re/2010/1/15/deep-hash-ordering-with-ruby-1-8/
  if object.is_a?(Hash)
    # Hash is ordered in Ruby 1.9! 
    res = returning(RUBY_VERSION >= '1.9' ? Hash.new : ActiveSupport::OrderedHash.new) do |map|
      object.each {|k, v| map[k] = deep ? convert_hash_to_ordered_hash_and_sort(v, deep) : v }
    end
    return res.class[res.sort {|a, b| a[0].to_s <=> b[0].to_s } ]
  elsif deep && object.is_a?(Array)
    array = Array.new
    object.each_with_index {|v, i| array[i] = convert_hash_to_ordered_hash_and_sort(v, deep) }
    return array
  else
    return object
  end
end



# =========================================================
source = YAML.load_file("billgastro_gn.yml")
sourcelang = source.keys.first
source = source[sourcelang]

translation = YAML.load_file("billgastro_en.yml")
translationlang = translation.keys.first
translation = translation[translationlang]

puts ''
puts '=========== ADD TO TRANSLATED FILE =========='
puts ''
compare_yaml_hash(source, translation )

puts ''
puts '=========== REMOVE FOM TRANSLATED FILE =========='
puts ''
compare_yaml_hash(translation, source)



sourceordered = convert_hash_to_ordered_hash_and_sort(source, true)
output_source = Hash.new
output_source[sourcelang] = sourceordered

translationordered = convert_hash_to_ordered_hash_and_sort(translation, true)
output_translation = Hash.new
output_translation[translationlang] = translationordered

File.open('source.yml','w'){ |f| f.write output_source.to_yaml }
File.open('source.yml','w'){ |f| f.write output_translation.to_yaml }
